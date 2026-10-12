locals {
  label = "${var.name}-${var.environment}"

  # Linode tags are plain strings, so key/value pairs use a "key:value" convention.
  tags = distinct(concat(
    ["env:${var.environment}", "managed-by:terraform", "app:${var.name}"],
    var.extra_tags,
  ))
}

resource "linode_firewall" "this" {
  label = "${local.label}-fw"
  tags  = local.tags

  # Deny by default; only the rules below are allowed in.
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80,443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  dynamic "inbound" {
    for_each = length(var.admin_ssh_cidrs) > 0 ? [1] : []
    content {
      label    = "allow-ssh-admin"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = "22"
      ipv4     = var.admin_ssh_cidrs
    }
  }
}

resource "linode_instance" "this" {
  label           = local.label
  region          = var.region
  type            = var.instance_type
  image           = var.image
  authorized_keys = var.authorized_keys
  backups_enabled = var.backups_enabled
  tags            = local.tags

  # Attach the firewall at creation so the instance is never exposed without it.
  firewall_id = linode_firewall.this.id

  # Use classic config-profile interfaces so the public + VPC interfaces below
  # work regardless of the account's default interface setting.
  interface_generation = "legacy_config"

  interface {
    purpose = "public"
  }

  interface {
    purpose   = "vpc"
    subnet_id = var.subnet_id
  }

  dynamic "metadata" {
    for_each = var.user_data == "" ? [] : [1]
    content {
      user_data = base64encode(var.user_data)
    }
  }

  lifecycle {
    # Changing cloud-init only matters at first boot; don't rebuild the server for it.
    ignore_changes = [metadata]
  }
}
