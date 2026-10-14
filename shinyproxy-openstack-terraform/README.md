# ShinyProxy OpenStack Terraform Deployment

Terraform configuration that deploys a ShinyProxy server on the **new Arbutus cloud** (OpenStack), with automated SSL (Let's Encrypt) and Docker-based application hosting. Currently hosts the **Metabarcoding Avatittini** app (metabarMap).

## Architecture

```mermaid
graph TB
    Users[Users/Clients] -->|HTTPS| FloatingIP

    subgraph "Arbutus OpenStack Cloud"
        FloatingIP[Floating IP<br/>pre-allocated]
        SG[Security Group sg-shinyproxy<br/>SSH :22 restricted, HTTP :80, HTTPS :443]
        KeyPair[Key Pair id_compute_cloud]

        subgraph "VM shinyproxy-1 (Ubuntu 24.04, p8-12gb)"
            Nginx[Nginx<br/>SSL termination, 100M body limit]
            ShinyProxy[ShinyProxy :8080<br/>users: steve admin, avatittini-user]
            Docker[Docker Engine<br/>port range 20000+]
            App[metabarmap:v1.2.0-avatittini<br/>loaded locally]
            Logs[/var/log/shinyproxy]
        end
    end

    FloatingIP --> Nginx
    SG -.->|rules| Nginx
    KeyPair -.->|SSH auth| Nginx
    Nginx -->|127.0.0.1:8080| ShinyProxy
    ShinyProxy --> Docker --> App
    ShinyProxy --> Logs
```

## What gets created

- Security group `sg-shinyproxy` (SSH from `ssh_cidr` only, HTTP/HTTPS from anywhere)
- Key pair from `public_key_path`
- Instance `shinyproxy-1` (flavor `flavor_name`, image `image_id`) on the internal network
- Association of a **pre-allocated** floating IP to the instance

Cloud-init then installs Docker, Java, Nginx, Certbot and ShinyProxy 3.2.4, writes `application.yml` and the custom login page, enables UFW and obtains the certificate for `domain`.

### ShinyProxy configuration

- Authentication: `simple`, two users, both in group `avatittini`
  - `steve` (also `admin`), password from `shinyproxy_password3`
  - `avatittini-user`, password from `shinyproxy_password4`
- App `metabarmap-avatittini` uses the image `metabarmap:v1.2.0-avatittini`, which is **not** built by cloud-init (see [After deployment](#after-deployment)).
- Container logs in `/var/log/shinyproxy/container-logs`, container port range starting at 20000.

## Variables

Required (no default):

| Variable | Description |
|---|---|
| `image_id` | Glance image ID (Ubuntu 24.04: `5a78426d-99b8-4014-b269-52a1c6d58f24`) |
| `ssh_cidr` | CIDR allowed to SSH, e.g. `x.x.x.x/32` |
| `external_network_name` | e.g. `Public-Network` |
| `internal_network_name` | e.g. `def-langloiv-prod-network` |
| `existing_floating_ip` | Floating IP already allocated to the project |
| `certbot_email` | Let's Encrypt contact email |
| `shinyproxy_password3` | Password of `steve` (sensitive) |
| `shinyproxy_password4` | Password of `avatittini-user` (sensitive) |
| `os_auth_url`, `os_region`, `os_project_name`, `os_username`, `os_password`, `os_domain` | Declared but unused: authentication comes from `OS_*` environment variables. Set them to `""`. |

Optional: `flavor_name` (`p8-12gb`), `server_name` (`shinyproxy-1`), `secgroup_name` (`sg-shinyproxy`), `keypair_name` / `public_key_path` (`id_compute_cloud`, use an **absolute** path since Terraform does not expand `~`), `domain` (`cloud.taqc.info`).

Pass the passwords as environment variables instead of writing them to a file:

```bash
export TF_VAR_shinyproxy_password3='...'
export TF_VAR_shinyproxy_password4='...'
```

## Prerequisites

1. **Floating IP** allocated in the project: `openstack floating ip create Public-Network`
2. **DNS**: `domain` must resolve to that floating IP *before* `apply`, otherwise Certbot fails.
3. **Authentication on the new Arbutus cloud** uses SSO + MFA, which the Terraform provider does not support. Use an application credential instead:
   ```bash
   # log in with SSO (see the Arbutus Migration Guide for the RC file changes), then:
   openstack application credential create terraform-shinyproxy -f json   # keep the secret, it is shown once
   unset OS_USERNAME OS_PASSWORD OS_IDENTITY_PROVIDER OS_PROTOCOL OS_PROJECT_ID OS_PROJECT_NAME OS_PROJECT_DOMAIN_ID OS_PROJECT_DOMAIN_NAME OS_USER_DOMAIN_NAME
   export OS_AUTH_URL=https://identity.arbutus.alliancecan.ca/
   export OS_REGION_NAME=RegionOne
   export OS_INTERFACE=public
   export OS_AUTH_TYPE=v3applicationcredential
   export OS_APPLICATION_CREDENTIAL_ID='...'
   export OS_APPLICATION_CREDENTIAL_SECRET='...'
   ```
4. Terraform >= 1.5 and a local SSH public key.

## Usage

```bash
cd shinyproxy-openstack-terraform
terraform init
terraform plan  -var-file=arbutus.tfvars -state=arbutus.tfstate
terraform apply -var-file=arbutus.tfvars -state=arbutus.tfstate
```

Cloud-init takes a few minutes after `apply`. Check with `ssh sviss@<floating-ip> cloud-init status`, then open `https://cloud.taqc.info`.

> The state file contains the ShinyProxy passwords in clear text. Keep it safe and use the same `-state` option for every command (`plan`, `apply`, `destroy`, `state list`).

### Files that must never be committed

`.gitignore` already excludes `*.tfstate`, `*.tfstate.*`, `*.tfvars`, `*.tfvars.*`, `tfplan`, `*.tfplan`, `*-openrc.sh` and `.terraform*`. Keep state, variables and credentials out of git.

## After deployment

The application image is not built on the VM. Build it locally from the metabarMap release (with the private CSV files included in `inst/extdata`), then load it on the VM:

```bash
docker save metabarmap:v1.2.0-avatittini | gzip | ssh sviss@<floating-ip> 'gunzip | docker load'
```

Until the image is loaded, the login works but launching the app fails.

## Outputs

- `instance_name`, `instance_id`
- `floating_ip`: public IP of the instance
- `ssh_command`: SSH command (private key derived from `public_key_path`)
- `shinyproxy_url`: `https://<domain>`
