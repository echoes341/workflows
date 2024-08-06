resource "dns_a_record_set" "pg" {
  zone = "ross.in."
  name = "pg"

  addresses = [var.ip_pg]
}
