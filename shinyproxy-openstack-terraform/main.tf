
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
  flavor_name     = var.flavor_name
  image_id        = var.image_id
  key_pair        = openstack_compute_keypair_v2.kp.name
  security_groups = [openstack_networking_secgroup_v2.sg.name]

  network {
    uuid = data.openstack_networking_network_v2.internal.id
  }

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    shinyproxy_user1     = var.shinyproxy_user1
    shinyproxy_password1 = var.shinyproxy_password1
    shinyproxy_user2     = var.shinyproxy_user2
    shinyproxy_password2 = var.shinyproxy_password2
    shinyproxy_user3     = var.shinyproxy_user3
    shinyproxy_password3 = var.shinyproxy_password3
    ssh_public_key       = file(var.public_key_path)
  })
}

data "openstack_networking_floatingip_v2" "existing_floating_ip" {
  address = var.existing_floating_ip
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip_association" {
  floating_ip = data.openstack_networking_floatingip_v2.existing_floating_ip.address
  instance_id = openstack_compute_instance_v2.vm.id
}
