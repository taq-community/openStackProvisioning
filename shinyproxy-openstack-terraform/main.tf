
data "openstack_networking_network_v2" "external" {
  name = "Public-Network"
}

data "openstack_networking_network_v2" "internal" {
  name = "def-langloiv-prod-network"
}

resource "openstack_networking_secgroup_v2" "sg" {
  name        = var.secgroup_name
  description = "ShinyProxy SG"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_cidr
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

resource "openstack_compute_keypair_v2" "kp" {
  name       = var.keypair_name
  public_key = file(var.public_key_path)
}

resource "openstack_compute_instance_v2" "vm" {
  name            = var.server_name
  flavor_name     = "p8-12gb"
  image_id        = "241de10b-becc-4d4d-a622-61695e5cb94f"
  key_pair        = openstack_compute_keypair_v2.kp.name
  security_groups = [openstack_networking_secgroup_v2.sg.name]

  network {
    uuid = data.openstack_networking_network_v2.internal.id
  }

  user_data = file("${path.module}/cloud-init.yaml")
}

# IP publique
resource "openstack_networking_floatingip_v2" "fip" {
  pool = data.openstack_networking_network_v2.external.name
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  port_id     = openstack_compute_instance_v2.vm.network[0].port
}

output "public_ip" {
  value = openstack_networking_floatingip_v2.fip.address
}

output "shinyproxy_url" {
  value = "http://${openstack_networking_floatingip_v2.fip.address}"
}
