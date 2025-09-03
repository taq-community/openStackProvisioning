# SOP – Deploying ShinyProxy on Arbutus with Terraform

## Project Folder `shinyproxy-openstack-terraform`

This folder contains the Terraform code to provision a VM on **Arbutus (OpenStack)** and deploy **ShinyProxy** with the **BARQUE Shiny App** behind **NGINX**.

---

## 1) Base Setup (via cloud-init)

- Installs: **Docker**, **default-jre** (for ShinyProxy), **jq**, **ufw**, **nginx**.  
- Creates user **`sviss`** (groups: `sudo`, `docker`) and configures SSH key-based access.

---

## 2) Configuration Files (written on the VM)

- **NGINX reverse proxy**  
  `/etc/nginx/sites-available/shinyproxy`  
  - Forwards `http://cloud.taq.info:443` → `http://127.0.0.1:8080` (ShinyProxy)

- **ShinyProxy configuration**  
  `/etc/shinyproxy/application_deploy.yml` → moved to `/etc/shinyproxy/application.yml`  
  - Auth: `simple` (users: `tuan`, `julie`, `steve`; `steve` in `admin`)  
  - App spec: **BARQUE** (`container-image: barque-app:prod`)  
  - Logging, port `8080`, UI options

---

## 3) Deployment Procedure

From your workstation:

```bash
cd openStackProvisioning

# Load OpenStack credentials
source def-langloiv-prod-openrc.sh

# Launch infrastructure
terraform apply \
  -var os_auth_url=$OS_AUTH_URL \
  -var os_region=$OS_REGION_NAME \
  -var os_project_name=$OS_PROJECT_NAME \
  -var os_username=$OS_USERNAME \
  -var os_password=$OS_PASSWORD \
  -var os_domain=$OS_USER_DOMAIN_NAME

# Associate manually the floating ip with shinyproxy-1 server
```

Terraform will provision the VM and pass the **cloud-init** that:
1. Installs deps and services
2. Installs ShinyProxy and config
3. Clones `barqueShinyApp` and builds `barque-app:prod`
4. Enables NGINX site and reloads services

---

## 4) Security Group

- **SSH** is restricted to key-based auth with CIDR lock

---

## 5) Post‑Deploy Checks

On the VM:

```bash
# Docker
sudo systemctl status docker

# ShinyProxy
sudo systemctl status shinyproxy
sudo journalctl -u shinyproxy -n 100 --no-pager

# NGINX
sudo nginx -t
sudo systemctl status nginx

# Open ports (expect 80 listening)
sudo ss -ltnp | grep -E ':80|:8080'
```

From your browser:

- Visit **http://cloud.taq.info**.  
- Log in with one of the configured users (e.g., `steve`).

---

## 6) Expected Result

- **ShinyProxy** accessible at **`http://cloud.taq.info`**  
- **BARQUE** app visible and launchable from ShinyProxy

---

## 7) Troubleshooting (quick tips)

- **ShinyProxy not up**: check `/var/log/shinyproxy/shinyproxy.log`, ensure Java installed and port 8080 free.  
- **NGINX 502/404**: `nginx -t`, verify symlink `/etc/nginx/sites-enabled/shinyproxy`, then `sudo systemctl reload nginx`.  
- **App missing**: confirm Docker image `barque-app:prod` exists (`docker images`), and `application.yml` has correct `container-image`.  
- **Auth issues**: verify users/groups in `/etc/shinyproxy/application.yml`; restart ShinyProxy.

---
