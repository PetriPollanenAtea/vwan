locals {
  rcg_metadata_files = fileset(
    var.firewall_rule_collection_groups_path,
    "**/_rcg.yml"
  )

  rcg_directories = {
    for file in local.rcg_metadata_files :
    replace(dirname(file), "\\", "/") => replace(file, "\\", "/")
  }

  rcg_raw = {
    for rcg_directory, metadata_file
    in local.rcg_directories :
    rcg_directory => {
      /*metadata = yamldecode(
        file(
          "${var.firewall_rule_collection_groups_path}/${metadata_file}"
        )
      )*/
      metadata = try(
        yamldecode(
          file(
            "${var.firewall_rule_collection_groups_path}/${metadata_file}"
          )
        ),
        null
      )

      collections = {
        for collection_file in fileset(
          "${var.firewall_rule_collection_groups_path}/${rcg_directory}",
          "*.yml"
        ) :
        trimsuffix(
          collection_file,
          ".yml"
          ) => yamldecode(
          file(
            "${var.firewall_rule_collection_groups_path}/${rcg_directory}/${collection_file}"
          )
        )
        if collection_file != "_rcg.yml"
      }
    }
  }

  rule_collection_groups = {
    for rcg_directory, rcg
    in local.rcg_raw :
    rcg_directory => {
      name     = rcg.metadata.name
      policy   = rcg.metadata.policy
      priority = rcg.metadata.priority
      network_rule_collections = {
        for collection_key, collection
        in rcg.collections :
        collection_key => {
          name     = collection.name
          priority = collection.priority
          action   = collection.action
          rules = [
            for rule in collection.rules : {
              name = rule.name
              description = try(
                rule.description,
                null
              )
              protocols = rule.protocols
              source_addresses = try(
                rule.source_addresses,
                []
              )
              source_ip_groups = [
                for ipg
                in try(
                  rule.source_ip_groups,
                  []
                ) :
                local.ip_group_ids[
                  replace(ipg, "\\", "/")
                ]
              ]
              destination_addresses = try(
                rule.destination_addresses,
                []
              )
              destination_ip_groups = [
                for ipg
                in try(
                  rule.destination_ip_groups,
                  []
                ) :
                local.ip_group_ids[
                  replace(ipg, "\\", "/")
                ]
              ]
              destination_fqdns = try(
                rule.destination_fqdns,
                []
              )
              destination_ports = rule.destination_ports
            }
          ]
        }
        if startswith(
          collection.name,
          "network-"
        )
      }
      /**/
      application_rule_collections = {
        for collection_key, collection
        in rcg.collections :
        collection_key => {
          name     = collection.name
          priority = collection.priority
          action   = collection.action
          rules = [
            for rule in collection.rules : {
              name = rule.name
              description = try(
                rule.description,
                null
              )
              source_addresses = try(
                rule.source_addresses,
                []
              )
              source_ip_groups = [
                for ipg
                in try(
                  rule.source_ip_groups,
                  []
                ) :
                local.ip_group_ids[
                  replace(ipg, "\\", "/")
                ]
              ]
              destination_fqdns = try(
                rule.destination_fqdns,
                []
              )
              destination_fqdn_tags = try(
                rule.destination_fqdn_tags,
                []
              )
              web_categories = try(
                rule.web_categories,
                []
              )
              terminate_tls = try(
                rule.terminate_tls,
                false
              )
              protocols = [
                for protocol
                in rule.protocols : {
                  type = protocol.type
                  port = protocol.port
                }
              ]
            }
          ]
        }

        if startswith(
          collection.name,
          "application-"
        )
      }

      nat_rule_collections = {
        for collection_key, collection
        in rcg.collections :
        collection_key => {
          name     = collection.name
          priority = collection.priority
          action = try(
            collection.action,
            "Dnat"
          )
          rules = [
            for rule in collection.rules : {
              name = rule.name
              description = try(
                rule.description,
                null
              )
              protocols = rule.protocols
              source_addresses = try(
                rule.source_addresses,
                []
              )
              source_ip_groups = [
                for ipg
                in try(
                  rule.source_ip_groups,
                  []
                ) :
                local.ip_group_ids[
                  replace(ipg, "\\", "/")
                ]
              ]
              destination_address = rule.destination_address
              destination_ports   = rule.destination_ports
              translated_address = try(
                rule.translated_address,
                null
              )
              translated_fqdn = try(
                rule.translated_fqdn,
                null
              )
              translated_port = tostring(
                rule.translated_port
              )
            }
          ]
        }
        if startswith(
          collection.name,
          "nat-"
        )
      }
    }
  }
}
