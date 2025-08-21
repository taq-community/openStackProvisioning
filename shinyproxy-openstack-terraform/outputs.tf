output "ssh_command" {
  value = "ssh sviss@${openstack_networking_floatingip_v2.fip.address}"
}
