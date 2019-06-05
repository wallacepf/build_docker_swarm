data "ignition_user" "cluster_user" {
    name = "core"
    ssh_authorized_keys = ["${file("~/.ssh/id_rsa.pub")}"]
}

data "ignition_config" "coreos" {
    users = ["${data.ignition_user.cluster_user.id}"]
}

provider "esxi" {
  version       = "~> 1.3"
  esxi_hostname = "${var.esxi_hostname}"
  esxi_hostport = "${var.esxi_hostport}"
  esxi_username = "${var.esxi_username}"
  esxi_password = "${var.esxi_password}"
}

resource "esxi_guest" "docker-mgr" {
  count = "${var.num_mgr}"
  guest_name         = "docker-mgr${count.index}"
  disk_store         = "${var.disk_store}"
  memsize            = "2048"
  numvcpus           = "2"

  guestinfo = {
    coreos.config.data.encoding = "base64"
    coreos.config.data = "${base64encode(data.ignition_config.etcd0.rendered)}"
  }

  ovf_source         = "../images/coreos_production_vmware_ova.ova"

  network_interfaces = [
    {virtual_network = "Transit Network"}
  ]
  power            = "on"

  connection {
    host     = "${self.ip_address}"
    agent    = "false"
    user     = "core"
    private_key = "${file("~/.ssh/id_rsa")}"
    timeout = "60s"
  }


  provisioner "remote-exec" {
    inline = [
        "echo success",
        "update_engine_client -update"
    ]
  }
}