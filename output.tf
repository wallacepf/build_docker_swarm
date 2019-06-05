output "ip" {
    count = "${var.num_mgr}"
    value = ["${esxi_guest.docker-mgr${count.index}.ip_address}"]
}