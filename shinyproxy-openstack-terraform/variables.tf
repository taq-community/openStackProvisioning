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
  type    = string
  default = "184.162.122.126/32"
}

variable "flavor_name" {
  type        = string
  default     = "p8-12gb"
  description = "OpenStack flavor name for the instance"
}

variable "image_id" {
  type        = string
  default     = "241de10b-becc-4d4d-a622-61695e5cb94f"
  description = "OpenStack image ID for the instance"
}

# ShinyProxy user credentials
variable "shinyproxy_user1" {
  type        = string
  default     = "tuan"
  description = "First ShinyProxy user name"
}

variable "shinyproxy_password1" {
  type        = string
  sensitive   = true
  description = "First ShinyProxy user password"
}

variable "shinyproxy_user2" {
  type        = string
  default     = "julie"
  description = "Second ShinyProxy user name"
}

variable "shinyproxy_password2" {
  type        = string
  sensitive   = true
  description = "Second ShinyProxy user password"
}

variable "shinyproxy_user3" {
  type        = string
  default     = "steve"
  description = "Third ShinyProxy user name (admin)"
}

variable "shinyproxy_password3" {
  type        = string
  sensitive   = true
  description = "Third ShinyProxy user password (admin)"
}

variable "existing_floating_ip" {
  type        = string
  description = "The existing floating IP address to associate with the instance"
}
