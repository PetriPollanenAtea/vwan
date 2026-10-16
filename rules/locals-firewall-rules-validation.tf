locals {
  firewall_rule_collections = flatten([
    for rcg_key, rcg
    in local.rule_collection_groups : [
      concat(
        [
          for collection_key, collection
          in rcg.network_rule_collections : {
            rcg_key         = rcg_key
            rcg_name        = rcg.name
            policy          = rcg.policy
            collection_key  = collection_key
            collection      = collection.name
            collection_type = "network"
            priority        = collection.priority
            rules           = collection.rules
          }
        ],
        [
          for collection_key, collection
          in rcg.application_rule_collections : {
            rcg_key         = rcg_key
            rcg_name        = rcg.name
            policy          = rcg.policy
            collection_key  = collection_key
            collection      = collection.name
            collection_type = "application"
            priority        = collection.priority
            rules           = collection.rules
          }
        ],
        [
          for collection_key, collection
          in rcg.nat_rule_collections : {
            rcg_key         = rcg_key
            rcg_name        = rcg.name
            policy          = rcg.policy
            collection_key  = collection_key
            collection      = collection.name
            collection_type = "nat"
            priority        = collection.priority
            rules           = collection.rules
          }
        ]
      )
    ]
  ])
}

locals {
  duplicate_rule_collection_priorities = {
    for rcg_key, rcg
    in local.rule_collection_groups :
    rcg_key => {
      for priority in distinct([
        for collection in local.firewall_rule_collections :
        collection.priority
        if collection.rcg_key == rcg_key
      ]) :
      tostring(priority) => [
        for collection in local.firewall_rule_collections :
        "${collection.collection_type}:${collection.collection}"
        if(
          collection.rcg_key == rcg_key &&
          collection.priority == priority
        )
      ]
      if length([
        for collection in local.firewall_rule_collections :
        collection
        if(
          collection.rcg_key == rcg_key &&
          collection.priority == priority
        )
      ]) > 1
    }
  }
}

locals {
  rule_collection_priority_conflicts = {
    for rcg_key, conflicts
    in local.duplicate_rule_collection_priorities :
    rcg_key => conflicts
    if length(conflicts) > 0
  }
}

check "rule_collection_priorities_unique" {
  assert {
    condition = (
      length(
        local.rule_collection_priority_conflicts
      ) == 0
    )
    error_message = format(
      "Duplicate Firewall rule collection priorities detected: %s",
      jsonencode(
        local.rule_collection_priority_conflicts
      )
    )
  }
}

locals {
  invalid_rule_collection_priorities = {
    for collection in local.firewall_rule_collections :
    "${collection.rcg_key}/${collection.collection}" =>
    collection.priority
    if(
      collection.priority < 100 ||
      collection.priority > 65000
    )
  }
}

check "rule_collection_priority_range" {
  assert {
    condition = (
      length(
        local.invalid_rule_collection_priorities
      ) == 0
    )
    error_message = format(
      "Firewall rule collection priorities must be between 100 and 65000: %s",
      jsonencode(
        local.invalid_rule_collection_priorities
      )
    )
  }
}

locals {
  firewall_rcgs = [
    for rcg_key, rcg
    in local.rule_collection_groups : {
      key      = rcg_key
      name     = rcg.name
      policy   = rcg.policy
      priority = rcg.priority
    }
  ]
}

locals {
  rcg_priority_conflicts = {
    for key in distinct([
      for rcg in local.firewall_rcgs :
      "${rcg.policy}/${rcg.priority}"
    ]) :
    key => [
      for rcg in local.firewall_rcgs :
      rcg.name
      if "${rcg.policy}/${rcg.priority}" == key
    ]
    if length([
      for rcg in local.firewall_rcgs :
      rcg
      if "${rcg.policy}/${rcg.priority}" == key
    ]) > 1
  }
}

check "rcg_priorities_unique" {
  assert {
    condition = (
      length(
        local.rcg_priority_conflicts
      ) == 0
    )
    error_message = format(
      "Duplicate Rule Collection Group priorities detected within Firewall Policies: %s",
      jsonencode(
        local.rcg_priority_conflicts
      )
    )
  }
}

locals {
  duplicate_firewall_rule_names = {
    for collection in local.firewall_rule_collections :
    "${collection.rcg_key}/${collection.collection}" => {
      for rule_name in distinct([
        for rule in collection.rules :
        rule.name
      ]) :
      rule_name => length([
        for rule in collection.rules :
        rule
        if rule.name == rule_name
      ])
      if length([
        for rule in collection.rules :
        rule
        if rule.name == rule_name
      ]) > 1
    }
    if length(
      distinct([
        for rule in collection.rules :
        rule.name
      ])
    ) != length(collection.rules)
  }
}

check "firewall_rule_names_unique" {
  assert {
    condition = (
      length(
        local.duplicate_firewall_rule_names
      ) == 0
    )
    error_message = format(
      "Duplicate Firewall rule names detected: %s",
      jsonencode(
        local.duplicate_firewall_rule_names
      )
    )
  }
}