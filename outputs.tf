output "instance_id" {
  description = "ID of the Linode instance."
  value       = linode_instance.this.id
}

output "label" {
  description = "Label of the Linode instance."
  value       = linode_instance.this.label
}

output "public_ipv4" {
  description = "Public IPv4 addresses of the instance."
  value       = linode_instance.this.ipv4
}

output "firewall_id" {
  description = "ID of the Cloud Firewall protecting the instance."
  value       = linode_firewall.this.id
}
