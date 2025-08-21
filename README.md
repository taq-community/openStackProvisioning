# SOP

## `shinyproxy-openstack-terraform` Deploy shinyproxy on arbutus using terraform

1. Base setup

Updates the package list and installs required software: Docker, Java (for ShinyProxy), jq, ufw (firewall), and NGINX (reverse proxy).
Creates a user `sviss` with sudo and docker rights, and sets up SSH access with a provided key.

2. Configuration files written

- `/etc/nginx/sites-available/shinyproxy`:` NGINX reverse proxy config to forward traffic from cloud.taq.info (port 80) to ShinyProxy (port 8080).
- `/etc/shinyproxy/application_deploy.yml`: Main ShinyProxy configuration:
- Defines authentication (simple with three users: tuan, julie, steve).
- Sets logging, ports, and UI parameters.

```bash
cd openStackProvisioning

# Load credentials
source def-langloiv-prod-openrc.sh

# Apply terraforming
terraform apply \
  -var os_auth_url=$OS_AUTH_URL \
  -var os_region=$OS_REGION_NAME \
  -var os_project_name=$OS_PROJECT_NAME \
  -var os_username=$OS_USERNAME \
  -var os_password=$OS_PASSWORD \
  -var os_domain=$OS_USER_DOMAIN_NAME
```

### Security group

SSH connection secured by private ssh key with no CIDR strategy.
See `ssh_cidr` variable.
