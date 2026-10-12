locals {
  routing_intents = {
    for hub_key, hub
    in local.virtual_hubs :
    hub_key => hub.routing_intent
    if length(
      keys(
        try(
          hub.routing_intent,
          {}
        )
      )
    ) > 0
  }
}