output "ip" {
  value = [
      "${esxi_guest.docker-mgr.*.ip_address}",
      "${esxi_guest.docker-wrk.*.ip_address}",
    ]
}
