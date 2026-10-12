output "firewall_policies" {
  value = {
    for key, id
    in local.firewall_policy_ids :
    key => id
  }
}

/*
output "rcg_directories" {
  value = local.rcg_directories
}
*/

output "rcg_metadata_files" {
  value = fileset(
    var.firewall_rule_collection_groups_path,
    "**/_rcg.yml"
  )
}
