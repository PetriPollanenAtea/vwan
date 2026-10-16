locals {
  firewalls_missing_required_properties = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => {
      name   = firewall.name
      hub    = firewall.hub
      policy = firewall.policy
    }

    if(
      firewall.name == null ||
      firewall.hub == null ||
      firewall.policy == null
    )
  }

  firewall_prefixes_missing_required_properties = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => firewall.public_ip_prefix

    if(
      firewall.public_ip_prefix.name == null ||
      firewall.public_ip_prefix.prefix_length == null ||
      firewall.public_ip_prefix.firewall_ip_count == null
    )
  }

  firewalls_with_undefined_hubs = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => firewall.hub

    if(
      firewall.hub != null &&
      !contains(
        keys(local.virtual_hubs),
        firewall.hub
      )
    )
  }

  firewalls_with_undefined_policies = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => firewall.policy

    if(
      firewall.policy != null &&
      !contains(
        keys(local.firewall_policy_ids),
        firewall.policy
      )
    )
  }

  invalid_firewall_sku_tiers = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => firewall.sku_tier

    if !contains(
      [
        "Standard",
        "Premium"
      ],
      firewall.sku_tier
    )
  }

  invalid_firewall_threat_intel_modes = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => firewall.threat_intel_mode

    if !contains(
      [
        "Alert",
        "Deny",
        "Off"
      ],
      firewall.threat_intel_mode
    )
  }

  invalid_firewall_prefix_lengths = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => (
      firewall.public_ip_prefix.prefix_length
    )

    if(
      firewall.public_ip_prefix.prefix_length != null &&
      (
        !can(
          floor(
            firewall.public_ip_prefix.prefix_length
          )
        ) ||
        firewall.public_ip_prefix.prefix_length < 0 ||
        firewall.public_ip_prefix.prefix_length > 31 ||
        floor(
          firewall.public_ip_prefix.prefix_length
        ) != firewall.public_ip_prefix.prefix_length
      )
    )
  }

  invalid_firewall_public_ip_counts = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => (
      firewall.public_ip_prefix.firewall_ip_count
    )

    if(
      firewall.public_ip_prefix.firewall_ip_count != null &&
      (
        !can(
          floor(
            firewall.public_ip_prefix.firewall_ip_count
          )
        ) ||
        firewall.public_ip_prefix.firewall_ip_count < 1 ||
        floor(
          firewall.public_ip_prefix.firewall_ip_count
        ) != firewall.public_ip_prefix.firewall_ip_count
      )
    )
  }

  firewall_prefix_capacity_errors = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => {
      prefix_length = (
        firewall.public_ip_prefix.prefix_length
      )

      firewall_ip_count = (
        firewall.public_ip_prefix.firewall_ip_count
      )

      prefix_capacity = pow(
        2,
        32 - firewall.public_ip_prefix.prefix_length
      )
    }

    if(
      firewall.public_ip_prefix.prefix_length != null &&
      firewall.public_ip_prefix.firewall_ip_count != null &&
      firewall.public_ip_prefix.prefix_length >= 0 &&
      firewall.public_ip_prefix.prefix_length <= 31 &&
      firewall.public_ip_prefix.firewall_ip_count >
      pow(
        2,
        32 - firewall.public_ip_prefix.prefix_length
      )
    )
  }

  firewalls_exceeding_public_ip_limit = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => (
      firewall.public_ip_prefix.firewall_ip_count
    )

    if(
      firewall.public_ip_prefix.firewall_ip_count != null &&
      firewall.public_ip_prefix.firewall_ip_count > 80
    )
  }

  firewall_names = [
    for firewall in values(local.firewalls) :
    lower(firewall.name)
    if firewall.name != null
  ]

  duplicate_firewall_names = toset([
    for name in local.firewall_names :

    name

    if length([
      for candidate in local.firewall_names :
      candidate
      if candidate == name
    ]) > 1
  ])

  firewall_prefix_names = [
    for firewall in values(local.firewalls) :
    lower(firewall.public_ip_prefix.name)
    if firewall.public_ip_prefix.name != null
  ]

  duplicate_firewall_prefix_names = toset([
    for name in local.firewall_prefix_names :

    name

    if length([
      for candidate in local.firewall_prefix_names :
      candidate
      if candidate == name
    ]) > 1
  ])

  generated_firewall_public_ip_names = [
    for public_ip in values(local.firewall_public_ips) :
    lower(public_ip.name)
  ]

  duplicate_generated_public_ip_names = toset([
    for name in local.generated_firewall_public_ip_names :

    name

    if length([
      for candidate
      in local.generated_firewall_public_ip_names :

      candidate

      if candidate == name
    ]) > 1
  ])
}