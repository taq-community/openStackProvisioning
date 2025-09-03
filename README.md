# ShinyProxy Deployment on Arbutus OpenStack

This repository contains Terraform configurations and documentation for deploying ShinyProxy on the Arbutus OpenStack cloud platform, providing a scalable web application hosting environment for R Shiny applications.

## Overview

The `shinyproxy-openstack-terraform` directory contains infrastructure-as-code for provisioning and configuring:
- OpenStack VM with automated setup via cloud-init
- ShinyProxy application server with Docker backend
- Nginx reverse proxy with SSL termination
- BARQUE Shiny application deployment

## Architecture Components

### Base Infrastructure Setup
- **Compute**: Ubuntu VM with 8 vCPUs and 12GB RAM (`p8-12gb` flavor)
- **Networking**: Internal and public network configuration with floating IP
- **Security**: SSH key-based authentication and firewall rules
- **Storage**: Automated log management and application data persistence

### Application Stack
- **Docker Engine**: Container runtime for Shiny applications
- **Java Runtime**: Required for ShinyProxy operation
- **System Tools**: `jq`, `ufw` for configuration and security management
- **User Management**: `sviss` user with Docker and sudo privileges

### Service Configuration

**Nginx Reverse Proxy** (`/etc/nginx/sites-available/shinyproxy`)
- SSL termination for `cloud.taq.info`
- Request forwarding to ShinyProxy on port 8080
- 100MB client body size limit for file uploads

**ShinyProxy Configuration** (`/etc/shinyproxy/application.yml`)
- Simple authentication with three users: `tuan`, `julie`, `steve` (admin)
- BARQUE application container specification
- Logging configuration and UI customization
- Docker port range allocation starting from 20000

## Deployment Instructions

### Prerequisites
Ensure you have OpenStack credentials loaded in your environment:

```bash
cd openStackProvisioning
source def-langloiv-prod-openrc.sh
```

### Infrastructure Provisioning
Deploy the complete stack using Terraform:

```bash
terraform apply \
  -var os_auth_url=$OS_AUTH_URL \
  -var os_region=$OS_REGION_NAME \
  -var os_project_name=$OS_PROJECT_NAME \
  -var os_username=$OS_USERNAME \
  -var os_password=$OS_PASSWORD \
  -var os_domain=$OS_USER_DOMAIN_NAME
```

### Automated Setup Process
The cloud-init script automatically handles:
1. **Package Installation**: Docker, Java, Nginx, Certbot, system utilities
2. **User Configuration**: SSH keys, group membership, permissions
3. **Service Setup**: ShinyProxy installation and configuration
4. **Application Deployment**: BARQUE app container build from GitHub
5. **SSL Certificate**: Let's Encrypt certificate provisioning
6. **Network Security**: Firewall configuration and service enablement

## Security Configuration

**Network Security**
- SSH access restricted by IP CIDR with key-based authentication
- HTTP (80) and HTTPS (443) ports open for web access
- Internal communication secured within OpenStack network

**Application Security**
- User authentication required for ShinyProxy access
- Admin-level permissions for administrative functions
- Container isolation for application execution

## Verification and Testing

### System Health Checks
Execute these commands on the deployed VM:

```bash
# Verify Docker service
sudo systemctl status docker

# Check ShinyProxy status and logs
sudo systemctl status shinyproxy
sudo journalctl -u shinyproxy -n 100 --no-pager

# Validate Nginx configuration
sudo nginx -t
sudo systemctl status nginx

# Confirm port availability
sudo ss -ltnp | grep -E ':80|:8080'
```

### Application Access
1. Navigate to **https://cloud.taq.info**
2. Authenticate using configured credentials (e.g., username: `steve`)
3. Verify BARQUE application availability and functionality

## Expected Outcomes

Upon successful deployment:
- **ShinyProxy Portal**: Accessible at `https://cloud.taq.info`
- **BARQUE Application**: Available through ShinyProxy interface
- **SSL Security**: Automated certificate management via Let's Encrypt
- **Container Management**: Docker-based application isolation and scaling

## Troubleshooting Guide

**ShinyProxy Issues**
- Check application logs: `/var/log/shinyproxy/shinyproxy.log`
- Verify Java installation and port 8080 availability
- Restart service: `sudo systemctl restart shinyproxy`

**Nginx Configuration Problems**
- Test configuration: `sudo nginx -t`
- Verify site enablement: check `/etc/nginx/sites-enabled/shinyproxy` symlink
- Reload configuration: `sudo systemctl reload nginx`

**Application Deployment Issues**
- Confirm Docker image existence: `docker images | grep barque-app`
- Validate ShinyProxy configuration in `application.yml`
- Check container logs for runtime errors

**Authentication Problems**
- Review user configuration in `/etc/shinyproxy/application.yml`
- Verify group assignments and permissions
- Restart ShinyProxy after configuration changes
