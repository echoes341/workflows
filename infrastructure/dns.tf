resource "dns_a_record_set" "pg" {
  zone = "ross.in."
  name = "pg"

  addresses = ["192.168.1.102"]
}
