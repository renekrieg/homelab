#!/bin/bash

# Author: Besmir Zanaj, 2024
# This is a very raw script to backup configs (no logs and no stats) from a technitium server
# to another
#
# first create two tokens: one on the source server and another one on the destination one
# fill out the vars below
# create a cronjob with this script on the destinaton host
# eg:
# 30 */6 * * * /path-to/technitium-sync.sh

set -euxo pipefail

# Load environment variables
if [[ -f .env ]]; then
    source .env
else
    echo ".env file not found. Aborting." >&2
    exit 1
fi

src_dns_server="$SRC_DNS_SERVER"
dst_dns_server="$DST_DNS_SERVER"
src_dns_serverdomain="$SRC_DNS_SERVERDOMAIN"
dst_dns_serverdomain="$DST_DNS_SERVERDOMAIN"
src_dns_token="$SRC_DNS_TOKEN"
dst_dns_token="$DST_DNS_TOKEN"
backup_file="/tmp/technitium-backup.zip"
# update the dhcp scope as per your local settings
dhcp_scope_names=(VLAN10 VLAN20 VLAN30 VLAN40 VLAN50 VLAN60 VLAN90 VLAN100 VLAN255)

# Ensure required tools are installed
command -v curl >/dev/null 2>&1 || {
    echo "curl is not installed. Aborting." >&2
    exit 1
}

# Check the primary server's health before running the script
echo "Checking primary Technitium server status"
status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://$src_dns_server:5380)

if [[ "$status_code" -ne 200 ]]; then
    echo "Primary DNS server is not available. Skipping backup"
    exit 1
else
    echo "Getting the backup archive from the primary server"
    curl -s "http://$src_dns_server:5380/api/settings/backup?token=$src_dns_token&blockLists=true&logs=false&scopes=true&stats=false&zones=true&allowedZones=true&blockedZones=true&dnsSettings=true&logSettings=true&authConfig=true&apps=true" -o $backup_file
fi

# restore_backup
if [[ -f "$backup_file" ]]; then
    echo "Restoring the backup on $HOSTNAME"
    curl -s --form file="@$backup_file" "http://$dst_dns_server:5380/api/settings/restore?token=$dst_dns_token&blockLists=true&logs=true&scopes=true&stats=true&apps=true&zones=true&allowedZones=true&blockedZones=true&dnsSettings=true&logSettings=true&deleteExistingFiles=true&authConfig=true" --output /dev/null

    # wait for server to come back
    echo "Waiting for 10 seconds for the destination server to start up"
    sleep 10

    # set dnsServerDomain on destination server
    echo "Updating DNS server Domain in destination server"
    curl -X POST "http://$dst_dns_server:5380/api/settings/set?token=$dst_dns_token&dnsServerDomain=$dst_dns_serverdomain"

    # disable DHCP on the destination server
    echo "disabling DHCP in destination server"
    for scope in "${dhcp_scope_names[@]}"; do
        curl -X POST "http://$dst_dns_server:5380/api/dhcp/scopes/disable?token=$dst_dns_token&name=$scope"
        sleep 1
    done

    # cleanup
    echo "Cleaning up temporary files"
    rm -rf $backup_file
fi
