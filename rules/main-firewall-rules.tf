resource "azurerm_firewall_policy_rule_collection_group" "this" {
  for_each = local.rule_collection_groups
  name = each.value.name
  firewall_policy_id = local.firewall_policy_ids[
    each.value.policy
  ]
  priority = each.value.priority

  lifecycle {
    #
    # RCG priorities must be unique
    #
    precondition {
      condition = length(
        local.rcg_priority_conflicts
      ) == 0
      error_message = format(
        "Duplicate Rule Collection Group priorities detected: %s",
        jsonencode(
          local.rcg_priority_conflicts
        )
      )
    }
    
    #
    # Collection priorities must be unique
    #
    precondition {
      condition = length(
        try(
          local.duplicate_rule_collection_priorities[
            each.key
          ],
          {}
        )
      ) == 0
      error_message = format(
        "Duplicate rule collection priorities in RCG '%s': %s",
        each.value.name,
        jsonencode(
          try(
            local.duplicate_rule_collection_priorities[
              each.key
            ],
            {}
          )
        )
      )
    }

    #
    # Collection priorities must be valid
    #
    precondition {
      condition = alltrue([
        for collection
        in local.firewall_rule_collections :
        collection.priority >= 100 &&
        collection.priority <= 65000
        if collection.rcg_key == each.key
      ])
      error_message = format(
        "RCG '%s' contains a rule collection priority outside the allowed range 100-65000.",
        each.value.name
      )
    }

    #
    # Rule names must be unique within collections
    #
    precondition {
      condition = alltrue([
        for collection
        in local.firewall_rule_collections :
        length(collection.rules) ==
        length(
          distinct([
            for rule in collection.rules :
            rule.name
          ])
        )
        if collection.rcg_key == each.key
      ])
      error_message = format(
        "RCG '%s' contains duplicate firewall rule names within one or more rule collections.",
        each.value.name
      )
    }
  }

  #
  # Network Rule Collections
  #
  dynamic "network_rule_collection" {
    for_each = each.value.network_rule_collections
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action
      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name = rule.value.name
          description = rule.value.description
          protocols = rule.value.protocols
          source_addresses = rule.value.source_addresses
          source_ip_groups = rule.value.source_ip_groups
          destination_addresses = rule.value.destination_addresses
          destination_ip_groups = rule.value.destination_ip_groups
          destination_fqdns = rule.value.destination_fqdns
          destination_ports = rule.value.destination_ports
        }
      }
    }
  }

  #
  # Application Rule Collections
  #
  dynamic "application_rule_collection" {
    for_each = each.value.application_rule_collections
    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action
      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name = rule.value.name
          description = rule.value.description
          source_addresses = rule.value.source_addresses
          source_ip_groups = rule.value.source_ip_groups
          destination_fqdns = rule.value.destination_fqdns
          destination_fqdn_tags = rule.value.destination_fqdn_tags
          web_categories = rule.value.web_categories
          terminate_tls = rule.value.terminate_tls
          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }

  #
  # NAT Rule Collections
  #
  dynamic "nat_rule_collection" {
    for_each = each.value.nat_rule_collections
    content {
      name     = nat_rule_collection.value.name
      priority = nat_rule_collection.value.priority
      action   = nat_rule_collection.value.action
      dynamic "rule" {
        for_each = nat_rule_collection.value.rules
        content {
          name = rule.value.name
          description = rule.value.description
          protocols = rule.value.protocols
          source_addresses = rule.value.source_addresses
          source_ip_groups = rule.value.source_ip_groups
          destination_address = rule.value.destination_address
          destination_ports = rule.value.destination_ports
          translated_address = rule.value.translated_address
          translated_fqdn = rule.value.translated_fqdn
          translated_port = rule.value.translated_port
        }
      }
    }
  }
}