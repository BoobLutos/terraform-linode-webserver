# Unit tests that run without a Linode account: the provider is mocked.
# Run with: terraform test

mock_provider "linode" {
  # Linode IDs are numeric strings; the default mock values are random text.
  mock_resource "linode_firewall" {
    defaults = {
      id = "2001"
    }
  }
}

variables {
  name        = "pilot"
  environment = "dev"
  region      = "se-sto"
  subnet_id   = 1234
}

run "ssh_closed_by_default" {
  command = plan

  assert {
    condition     = length(linode_firewall.this.inbound) == 1
    error_message = "Only the HTTP/HTTPS rule should exist when admin_ssh_cidrs is empty."
  }

  assert {
    condition     = linode_firewall.this.inbound_policy == "DROP"
    error_message = "Firewall must deny inbound traffic by default."
  }
}

run "ssh_open_to_admin_cidrs" {
  command = plan

  variables {
    admin_ssh_cidrs = ["203.0.113.10/32"]
  }

  assert {
    condition     = length(linode_firewall.this.inbound) == 2
    error_message = "Expected an SSH rule when admin_ssh_cidrs is set."
  }

  assert {
    condition     = linode_firewall.this.inbound[1].ipv4 == tolist(["203.0.113.10/32"])
    error_message = "SSH rule must be limited to admin_ssh_cidrs."
  }
}

run "rejects_ssh_from_anywhere" {
  command = plan

  variables {
    admin_ssh_cidrs = ["0.0.0.0/0"]
  }

  expect_failures = [var.admin_ssh_cidrs]
}

run "required_tags_present" {
  command = plan

  assert {
    condition = alltrue([
      contains(linode_instance.this.tags, "env:dev"),
      contains(linode_instance.this.tags, "managed-by:terraform"),
    ])
    error_message = "Instance must carry env and managed-by tags."
  }

  assert {
    condition     = linode_instance.this.label == "pilot-dev"
    error_message = "Instance label should be <name>-<environment>."
  }
}

run "rejects_unknown_environment" {
  command = plan

  variables {
    environment = "qa"
  }

  expect_failures = [var.environment]
}
