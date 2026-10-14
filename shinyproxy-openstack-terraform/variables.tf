variable "os_auth_url" {
  type = string
}

variable "os_region" {
  type = string
}

variable "os_project_name" {
  type = string
}

variable "os_username" {
  type = string
}

variable "os_password" {
  type      = string
  sensitive = true
}

variable "os_domain" {
  type = string
}

variable "keypair_name" {
  type    = string
  default = "id_compute_cloud"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_compute_cloud.pub"
}

variable "server_name" {
  type    = string
  default = "shinyproxy-1"
}

variable "secgroup_name" {
  type    = string
  default = "sg-shinyproxy"
}

# Restrict as needed (0.0.0.0/0 for tests)
variable "ssh_cidr" {
  type = string
}

variable "flavor_name" {
  type        = string
  default     = "p8-12gb"
  description = "OpenStack flavor name for the instance"
}

variable "image_id" {
  type        = string
  description = "OpenStack image ID for the instance"
}

# ShinyProxy user credentials
variable "shinyproxy_password3" {
  type        = string
  sensitive   = true
  description = "Third ShinyProxy user password (admin)"
}

variable "shinyproxy_password4" {
  type        = string
  sensitive   = true
  description = "avatittini-user password"
}

variable "external_network_name" {
  type = string
}

variable "internal_network_name" {
  type = string
}

variable "domain" {
  type    = string
  default = "cloud.taqc.info"
}

variable "certbot_email" {
  type = string
}

variable "existing_floating_ip" {
  type        = string
  description = "The existing floating IP address to associate with the instance"
}
