# Network Infrastructure
resource "technitium_record" "a_records" {
  for_each        = { for i, record in local.records_flatten : i => record if record.type == "A" }
  domain          = "${each.value.domain_prefix}.${var.zone}"
  type            = "A"
  ttl             = var.ttl
  ptr             = true
  ip_address      = each.value.ip_address
  create_ptr_zone = true
}

resource "technitium_record" "my_cname" {
  for_each = { for i, record in local.records_flatten : i => record if record.type == "CNAME" }
  domain   = "${each.value.domain_prefix}.${var.zone}"
  type     = "CNAME"
  cname    = each.value.c_name
  ttl      = var.ttl
}
