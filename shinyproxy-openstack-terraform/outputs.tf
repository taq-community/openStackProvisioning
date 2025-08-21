output "ssh_command" {
  value = "ssh user@${openstack_networking_floatingip.fip.address}"
}
