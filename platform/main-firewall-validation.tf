resource "terraform_data" "firewall_validation" {
  input = local.firewalls

  lifecycle {
    precondition {
      condition = (
        length(
          local.firewalls_missing_required_properties
        ) == 0
      )

      error_message = format(
        "Firewall definitions are missing required properties: %s",
        jsonencode(
          local.firewalls_missing_required_properties
        )
      )
    }

    precondition {
      condition = (
        length(
          local.firewall_prefixes_missing_required_properties
        ) == 0
      )

      error_message = format(
        "Each firewall must define public_ip_prefix.name, prefix_length and firewall_ip_count: %s",
        jsonencode(
          local.firewall_prefixes_missing_required_properties
        )
      )
    }

    precondition {
      condition = (
        length(
          local.firewalls_with_undefined_hubs
        ) == 0
      )

      error_message = format(
        "Firewalls reference undefined Virtual Hubs: %s",
        jsonencode(
          local.firewalls_with_undefined_hubs
        )
      )
    }

    precondition {
      condition = (
        length(
          local.firewalls_with_undefined_policies
        ) == 0
      )

      error_message = format(
        "Firewalls reference undefined Firewall Policies: %s",
        jsonencode(
          local.firewalls_with_undefined_policies
        )
      )
    }

    precondition {
      condition = (
        length(
          local.invalid_firewall_sku_tiers
        ) == 0
      )

      error_message = format(
        "Firewall sku_tier must be Standard or Premium: %s",
        jsonencode(
          local.invalid_firewall_sku_tiers
        )
      )
    }

    precondition {
      condition = (
        length(
          local.invalid_firewall_threat_intel_modes
        ) == 0
      )

      error_message = format(
        "Firewall threat_intel_mode must be Alert, Deny or Off: %s",
        jsonencode(
          local.invalid_firewall_threat_intel_modes
        )
      )
    }

    precondition {
      condition = (
        length(
          local.invalid_firewall_prefix_lengths
        ) == 0
      )

      error_message = format(
        "Public IP Prefix length must be an integer between 0 and 31: %s",
        jsonencode(
          local.invalid_firewall_prefix_lengths
        )
      )
    }

    precondition {
      condition = (
        length(
          local.invalid_firewall_public_ip_counts
        ) == 0
      )

      error_message = format(
        "firewall_ip_count must be a positive integer: %s",
        jsonencode(
          local.invalid_firewall_public_ip_counts
        )
      )
    }

    precondition {
      condition = (
        length(
          local.firewall_prefix_capacity_errors
        ) == 0
      )

      error_message = format(
        "Requested firewall_ip_count exceeds the Public IP Prefix capacity: %s",
        jsonencode(
          local.firewall_prefix_capacity_errors
        )
      )
    }

    precondition {
      condition = (
        length(
          local.firewalls_exceeding_public_ip_limit
        ) == 0
      )

      error_message = format(
        "A secured-hub firewall cannot use more than 80 customer-provided Public IP addresses: %s",
        jsonencode(
          local.firewalls_exceeding_public_ip_limit
        )
      )
    }

    precondition {
      condition = (
        length(
          local.duplicate_firewall_names
        ) == 0
      )

      error_message = format(
        "Duplicate Azure Firewall names detected: %s",
        jsonencode(
          local.duplicate_firewall_names
        )
      )
    }

    precondition {
      condition = (
        length(
          local.duplicate_firewall_prefix_names
        ) == 0
      )

      error_message = format(
        "Duplicate Firewall Public IP Prefix names detected: %s",
        jsonencode(
          local.duplicate_firewall_prefix_names
        )
      )
    }

    precondition {
      condition = (
        length(
          local.duplicate_generated_public_ip_names
        ) == 0
      )

      error_message = format(
        "Duplicate generated Firewall Public IP names detected: %s",
        jsonencode(
          local.duplicate_generated_public_ip_names
        )
      )
    }
  }
}