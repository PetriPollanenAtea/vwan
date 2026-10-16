# Azure Virtual WAN Infrastructure

This repository contains the Terraform implementation for deploying and managing the Azure Virtual WAN networking environment.

The solution provides a regional hub-and-spoke network architecture based on Azure Virtual WAN, secured Virtual Hubs, Azure Firewall, site-to-site VPN connectivity, centralized routing, DNS, logging, and monitoring.

Infrastructure configuration is separated from Terraform logic wherever practical by using YAML configuration files. This allows hubs, VPN sites, firewall policies, routing, and related resources to be changed without restructuring the Terraform implementation.

---

## Architecture Overview

The environment is based on Azure Virtual WAN with regional Virtual Hubs.

Each regional hub provides centralized connectivity for:

- Azure Virtual Networks
- Site-to-site VPN connections
- Other Virtual WAN hubs
- Internet traffic
- Private network traffic

Azure Firewall is deployed into the Virtual WAN hubs to provide centralized traffic inspection and policy enforcement.

A simplified architecture is:

    Azure Virtual WAN
            |
            +-----------------------+
            |                       |
            v                       v
       EMEA vHub              Americas vHub
            |                       |
      Azure Firewall           Azure Firewall
            |                       |
       +----+----+              +---+----+
       |         |              |        |
      VNets   VPN Sites        VNets   VPN Sites


Routing Intent directs Internet and private traffic through the regional Azure Firewall.

---

# Repository Structure

The repository follows a root-module architecture where Terraform resources are divided into functional files.

Example:

    .
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── providers.tf
    ├── versions.tf
    │
    ├── main-virtual-wan.tf
    ├── main-virtual-hubs.tf
    ├── main-firewalls.tf
    ├── main-firewall-policies.tf
    ├── main-vpn-gateways.tf
    ├── main-vpn-sites.tf
    ├── main-vpn-connections.tf
    ├── main-routing.tf
    ├── main-monitoring.tf
    │
    ├── locals-firewalls.tf
    ├── locals-routing.tf
    ├── locals-validation.tf
    │
    └── config/
        ├── firewalls.yml
        ├── firewall-rules.yml
        ├── vpn-sites.yml
        └── routing.yml

The exact files may vary as the implementation evolves.

---

# Main Components

## Azure Virtual WAN

Azure Virtual WAN provides the global network container and connects the regional Virtual Hubs.

The Virtual WAN is the foundation for:

- hub-to-hub connectivity
- regional routing
- site-to-site VPN connectivity
- VNet connectivity
- secured Virtual Hub integration

---

## Virtual Hubs

Regional Virtual Hubs provide connectivity and routing services for each deployment region.

Each hub can contain:

- Azure Firewall
- VPN Gateway
- VNet connections
- route tables
- routing intent
- site-to-site VPN connections

Regional configuration is defined through Terraform configuration and YAML data.

---

## Azure Firewall

Azure Firewall is deployed using the `AZFW_Hub` deployment model and attached directly to a Virtual WAN hub.

Firewall policies are managed separately from the firewall resources, enabling centralized management of:

- network rules
- application rules
- NAT rules
- threat intelligence
- DNS configuration

The firewall SKU tier can be configured independently for each firewall.

---

# Public IP Address Architecture

Azure Firewall public IP addressing is designed around regional Public IP Prefixes.

The objective is to maintain a predictable and contiguous public IP range for each regional firewall rather than relying on individually generated Virtual WAN public addresses.

The deployment model is:

    Public IP Prefix
          |
          +-- Public IP 01
          +-- Public IP 02
          +-- Public IP 03
          +-- Public IP 04
                  |
                  v
             AZFW_Hub

A separate Public IP Prefix is created in each Azure region containing a secured Virtual Hub.

Individual Standard SKU static Public IP resources are then allocated from the prefix.

This makes the firewall's public addresses part of a contiguous Azure Public IP Prefix that can be shared with external parties as a single known range.

Example:

    Regional Public IP Prefix
        203.0.113.0/29

    Firewall Public IP resources
        203.0.113.0
        203.0.113.1
        203.0.113.2
        203.0.113.3

The actual addresses are allocated by Azure.

> Azure Firewall does not consume a Public IP Prefix resource directly. Individual Public IP resources are created from the prefix and associated with the firewall.

---

## Firewall Configuration

Firewall definitions are stored in YAML.

Example:

    firewalls:

      emea:
        name: azfw-emea
        hub: emea
        policy: emea

        sku_tier: Premium
        threat_intel_mode: Alert

        public_ip_prefix:
          name: ippre-azfw-emea-001
          prefix_length: 29
          firewall_ip_count: 4

      americas:
        name: azfw-americas
        hub: americas
        policy: americas

        sku_tier: Premium
        threat_intel_mode: Alert

        public_ip_prefix:
          name: ippre-azfw-americas-001
          prefix_length: 29
          firewall_ip_count: 4

Terraform uses the referenced Virtual Hub to determine the resource group and Azure region for the firewall Public IP Prefix.

This ensures that:

- the Public IP Prefix
- individual Public IP resources
- Virtual Hub
- Azure Firewall

are deployed into the appropriate Azure region.

---

# Firewall Policies

Azure Firewall Policies are defined independently from Azure Firewall instances.

This separates the firewall infrastructure lifecycle from security policy configuration.

Firewall Policy contains the rule collection groups used to manage:

- network rules
- application rules
- NAT rules

Rule collection groups and rules can be defined through YAML configuration and transformed into Terraform resources.

---

# Site-to-Site VPN

Site-to-site VPN connectivity is provided by Azure Virtual WAN VPN Gateways.

VPN configuration includes:

- VPN sites
- site links
- VPN connections
- link configuration
- BGP configuration where required
- static routing where required

VPN sites are attached to the appropriate regional Virtual Hub.

The configuration model supports multiple links where required for resilient connectivity.

---

# Routing

Routing is controlled by Azure Virtual WAN.

The solution can use:

- Virtual Hub route tables
- VNet connection route propagation
- VPN route propagation
- static routes
- BGP-learned routes
- Routing Intent

Routing Intent is used to direct private and Internet traffic through Azure Firewall.

Conceptually:

    Internet Traffic
           |
           v
      Azure Firewall
           |
           v
       Virtual Hub


    Private Traffic
           |
           v
      Azure Firewall
           |
           v
       Virtual Hub

This provides centralized traffic inspection within each regional networking hub.

---

# DNS

DNS configuration is designed together with Azure Firewall and the Virtual WAN topology.

Where Azure Firewall DNS Proxy is enabled, workloads can use the firewall as the DNS forwarding path while the firewall forwards queries to the configured DNS servers.

DNS architecture should be considered together with:

- regional Virtual Hubs
- Azure VNets
- on-premises DNS
- private DNS resolution
- Azure Private DNS
- firewall policy

---

# Logging

Azure Firewall diagnostic logs are sent to Log Analytics using Azure Monitor Diagnostic Settings.

The deployment enables relevant resource-specific firewall log categories, including:

    AZFWNetworkRule
    AZFWApplicationRule
    AZFWNatRule
    AZFWDnsQuery
    AZFWFqdnResolveFailure
    AZFWThreatIntel
    AZFWIdpsSignature

Firewall metrics are collected using:

    AllMetrics

The diagnostic setting is associated with the Azure Firewall resource rather than with the Virtual Hub.

---

# Configuration Validation

The root module validates configuration before infrastructure deployment.

Validation covers relevant relationships and configuration constraints such as:

- required firewall properties
- Virtual Hub references
- Firewall Policy references
- supported firewall SKU tiers
- Public IP Prefix configuration
- Public IP Prefix capacity
- requested firewall public IP count
- duplicate resource names

Invalid configuration causes Terraform planning or deployment to fail before the affected infrastructure is created.

---

# Terraform State

Terraform remote state should be stored in an Azure Storage Account using the AzureRM backend.

Example:

    terraform {
      backend "azurerm" {}
    }

Backend configuration should be supplied by the deployment pipeline or environment-specific backend configuration.

Credentials and secrets must not be stored in this repository.

---

# Deployment

Initialize Terraform:

    terraform init

Validate the configuration:

    terraform validate

Review the deployment:

    terraform plan

Deploy:

    terraform apply

Production changes should normally be executed through the project's GitHub Actions workflow rather than directly from an administrator workstation.

---

# GitHub Actions

GitHub Actions is used for Terraform validation, planning, and deployment.

A typical workflow consists of:

    Checkout
        |
        v
    Azure authentication
        |
        v
    Terraform init
        |
        v
    Terraform validate
        |
        v
    Terraform plan
        |
        v
    Review / approval
        |
        v
    Terraform apply

Azure authentication should use workload identity federation where possible rather than long-lived client secrets.

---

# Making Changes

Configuration changes should normally be made through the YAML configuration rather than by adding environment-specific values directly into Terraform resources.

The general workflow is:

1. Create a feature branch.
2. Modify the appropriate YAML or Terraform configuration.
3. Run Terraform formatting and validation.
4. Create a pull request.
5. Review the Terraform plan.
6. Merge the approved change.
7. Deploy using the GitHub Actions workflow.

Always review the Terraform plan carefully when modifying:

- Virtual Hubs
- Azure Firewall
- Firewall Public IP addresses
- VPN Gateways
- VPN connections
- route tables
- Routing Intent

Changes to these resources can affect production network connectivity.

---

# Important Design Principles

The implementation follows these main principles:

### Configuration-driven deployment

Environment-specific networking configuration is kept separate from reusable Terraform logic wherever practical.

### Regional independence

Regional Virtual Hubs, firewalls, VPN connectivity, and Public IP Prefixes can be managed independently.

### Centralized inspection

Private and Internet traffic can be routed through Azure Firewall using Virtual WAN Routing Intent.

### Predictable firewall addressing

Firewall Public IP addresses are allocated from regional Public IP Prefixes to provide contiguous and predictable public address ranges.

### Policy separation

Azure Firewall Policy is managed separately from the Azure Firewall infrastructure lifecycle.

### Validation before deployment

Terraform validation is used to detect configuration errors and invalid references before Azure resources are modified.

### Infrastructure as Code

Azure network configuration should be made through Terraform and the repository wherever the resource or feature is under IaC management.

---

# Operational Considerations

Changes to the following components should be treated as potentially connectivity-affecting:

- Azure Firewall
- firewall public IP addresses
- Public IP Prefixes
- Virtual Hub routing
- Routing Intent
- VPN Gateways
- VPN connections
- BGP settings
- static routes
- DNS configuration

For production environments, potentially disruptive changes should be planned and performed during an appropriate maintenance window.

---

# Troubleshooting

When troubleshooting a deployment, start with:

    terraform validate

and:

    terraform plan

For Azure networking issues, verify:

1. Resource provisioning state
2. Virtual Hub routing
3. Routing Intent
4. Firewall Policy and rule collections
5. Azure Firewall logs
6. VPN connection status
7. BGP-learned routes
8. VNet effective routes
9. DNS resolution
10. Network Security Group rules where applicable

Azure Firewall diagnostic logs in Log Analytics provide the primary source for investigating traffic that is allowed or denied by firewall policy.

---

# Security

Do not store the following in this repository:

- VPN pre-shared keys
- service principal secrets
- certificates
- storage account keys
- access tokens
- other credentials

Sensitive values should be provided through approved Azure and GitHub secret-management mechanisms.

---

# Ownership

This repository contains the Infrastructure as Code implementation for the Azure Virtual WAN networking environment.

Changes should be performed through the repository and reviewed through the normal pull-request and deployment process.