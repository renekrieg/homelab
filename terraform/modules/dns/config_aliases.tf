locals {
  records = {
    "sw1" = {
      "name" : "sw-1"
      "type" : "A"
      "ip" : "10.10.10.10"
      "aliases" : ["cbs350", "KR-PRV-SW-1"]
    },
    "sw-2" = {
      "name" : "sw-2"
      "type" : "CNAME"
      "ip" : "172.16.100.2"
      "aliases" : ["cbs220", "KR-PRV-SW-2"]
    }
  }
  records_flatten = flatten([
    for records_key, records in local.records : [
      for i, alias in records.aliases : {
        type          = records.type
        ip_address    = records.ip
        domain_prefix = records.name
        c_name        = alias
      }
    ]
  ])
}
