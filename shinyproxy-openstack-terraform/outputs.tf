output "instance_name" {
  description = "Name of the created instance"
  value       = openstack_compute_instance_v2.vm.name
}

output "instance_id" {
  description = "ID of the created instance"
  value       = openstack_compute_instance_v2.vm.id
}

output "floating_ip" {
  description = "The floating IP address assigned to the instance"
  value       = data.openstack_networking_floatingip_v2.existing_floating_ip.address
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.public_key_path} sviss@${data.openstack_networking_floatingip_v2.existing_floating_ip.address}"
}

output "shinyproxy_url" {
  description = "URL to access ShinyProxy application"
  value       = "https://cloud.taq.info"
}