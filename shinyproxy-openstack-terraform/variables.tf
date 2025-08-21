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

variable "network_name" {
  type    = string
  default = "private"
}

variable "external_network" {
  type    = string
  default = "public"
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
  default = "0.0.0.0/0"
}
