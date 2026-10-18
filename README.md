# terraform-linode-webserver

Creates a single Linode instance behind a deny-by-default Cloud Firewall, with a public interface and a private interface in a VPC subnet.

Publishes to HCP Terraform's private registry as `app.terraform.io/<ORG>/webserver/linode`.

## What it creates

- `linode_firewall`: inbound policy `DROP`; allows TCP 80/443 from anywhere, and TCP 22 only from `admin_ssh_cidrs` (closed when the list is empty).
- `linode_instance`: attached to the firewall at creation, with a public interface plus a VPC interface on `subnet_id`. Tagged `env:<environment>`, `managed-by:terraform`, `app:<name>`.

## Usage

```hcl
module "web" {
  source  = "app.terraform.io/<ORG>/webserver/linode"
  version = "~> 1.0"

  name            = "pilot"
  environment     = "dev"
  region          = "se-sto"
  subnet_id       = 12345
  authorized_keys = ["ssh-ed25519 AAAA... you@laptop"]
  admin_ssh_cidrs = ["203.0.113.10/32"]
}
```

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string | — | App name, used in labels and tags |
| `environment` | string | — | `dev`, `staging` or `prod` |
| `region` | string | — | Must match the subnet's region |
| `subnet_id` | number | — | VPC subnet for the private interface |
| `instance_type` | string | `g6-nanode-1` | Linode plan |
| `image` | string | `linode/ubuntu24.04` | OS image |
| `authorized_keys` | list(string) | `[]` | SSH public keys for root |
| `admin_ssh_cidrs` | list(string) | `[]` | IPv4 CIDRs allowed to SSH; `0.0.0.0/0` is rejected |
| `backups_enabled` | bool | `false` | Linode Backup service (extra cost) |
| `user_data` | string | `""` | cloud-init, first boot only |
| `extra_tags` | list(string) | `[]` | Additional tags |

## Outputs

`instance_id`, `label`, `public_ipv4`, `firewall_id`.

## Releasing

Merge to `main`, then push a semver tag (`v1.0.0`). HCP Terraform publishes it automatically.

##
