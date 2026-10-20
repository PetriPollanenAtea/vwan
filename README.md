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

# CI/CD with GitHub Actions

GitHub Actions is used to validate, plan, and deploy the Azure Virtual WAN platform.

The Terraform root module is located under:

    platform/

The CI/CD design uses two workflows:

    .github/workflows/
    ├── platform-plan.yml
    └── platform-deploy.yml

The workflows authenticate to Azure using OpenID Connect (OIDC) workload identity federation.

No Azure client secret is required.

The authentication flow is:

    GitHub Actions
          |
          | OIDC token
          v
    Microsoft Entra ID
          |
          | Federated identity credential
          v
    Entra application / service principal
          |
          | Azure RBAC
          v
    Azure subscription

Microsoft Entra workload identity federation allows an external workload such as GitHub Actions to authenticate using an externally issued token instead of storing an application secret or certificate.

---

# GitHub Actions Workflows

## Platform Plan Workflow

The platform plan workflow is stored in:

    .github/workflows/platform-plan.yml

It is triggered by pull requests targeting the `main` branch when files under the platform deployment are changed.

The workflow performs:

    Checkout
       |
       v
    Terraform fmt
       |
       v
    Terraform validate
       |
       v
    Azure OIDC login
       |
       v
    Terraform init
       |
       v
    Terraform plan
       |
       v
    Upload plan artifact

The workflow operates against:

    ./platform

Changes anywhere under:

    platform/**

trigger validation and planning.

This is intentional because much of the platform configuration is stored in YAML files rather than directly in Terraform resources.

For example, changes to:

    platform/config/firewalls.yml
    platform/config/vpn-sites.yml
    platform/config/vpn-connections.yml

must result in a Terraform plan even if no `.tf` file changed.

The plan workflow uses the GitHub environment:

    platform-plan

No Terraform apply is performed by this workflow.

---

## Platform Deployment Workflow

The platform deployment workflow is stored in:

    .github/workflows/platform-deploy.yml

The workflow is manually triggered with:

    Actions
      -> Platform - Deploy
      -> Run workflow

It supports:

    plan
    apply

The apply process is:

    Terraform validate
         |
         v
    Terraform plan
         |
         v
    Save deployment plan
         |
         v
    platform-production environment
         |
         v
    Required approval
         |
         v
    Terraform apply

The apply stage uses the Terraform plan produced earlier in the same workflow.

It does not generate a new plan after deployment approval.

This ensures that the plan reviewed before approval is the plan passed to Terraform apply.

---

# GitHub Environments

Two GitHub environments are required:

    platform-plan
    platform-production

Create them from:

    GitHub repository
      -> Settings
      -> Environments
      -> New environment

---

## platform-plan

Create an environment named:

    platform-plan

This environment is used by Terraform plan jobs.

Recommended configuration:

    Required reviewers: disabled

The environment should be able to authenticate to Azure using the Entra application configured for Terraform.

---

## platform-production

Create another environment named:

    platform-production

This environment protects Terraform apply operations.

Recommended configuration:

    Required reviewers: enabled
    Prevent self-review: enabled
    Deployment branch: main

The intent is that infrastructure changes cannot be applied until an authorized reviewer approves the GitHub environment deployment.

The production workflow contains:

    environment: platform-production

which causes GitHub to apply the protection rules configured on that environment.

---

# Azure Authentication

The workflows authenticate to Azure using GitHub OIDC and Microsoft Entra workload identity federation.

The deployment does not require:

    AZURE_CLIENT_SECRET

Instead, GitHub requests an OIDC token and Microsoft Entra ID exchanges that trusted token for an Azure access token.

The Entra configuration consists of:

1. Microsoft Entra application registration
2. Service principal
3. Azure RBAC assignments
4. GitHub federated identity credentials
5. GitHub environment configuration

---

# Create the Microsoft Entra Application

If a Terraform deployment application does not already exist, create one.

In the Azure portal:

    Microsoft Entra ID
      -> App registrations
      -> New registration

Example name:

    github-vwan-terraform

For a normal organization-internal Terraform deployment, select the account type appropriate for the organization's Entra tenant.

After creating the application, record:

    Application (client) ID
    Directory (tenant) ID

The application registration defines the identity used by GitHub Actions.

A corresponding service principal represents that application inside the tenant and is the identity to which Azure RBAC permissions are assigned.

---

# Configure Azure RBAC

The Entra application's service principal must have Azure RBAC permissions for the resources managed by Terraform.

Assign permissions at the smallest practical scope.

For example:

    Subscription
       |
       +-- Terraform deployment identity
             |
             +-- Resource groups managed by Terraform
             |
             +-- Terraform state storage

The exact RBAC roles depend on the resources managed by the platform.

The identity must have sufficient permissions to:

- manage the Azure resources included in the Terraform deployment;
- read existing resources referenced by Terraform;
- access the Terraform state backend.

Avoid assigning broader permissions than required.

---

# Terraform State Permissions

Terraform state is stored using the AzureRM backend.

The backend configuration is intentionally partial:

    terraform {
      backend "azurerm" {}
    }

The GitHub workflow supplies the backend configuration during:

    terraform init

The workflows use:

    use_azuread_auth=true

The GitHub/Entra deployment identity therefore also requires the appropriate Azure RBAC access to the Terraform state Storage Account or Blob container.

No Storage Account access key should be stored in the repository.

---

# Configure GitHub OIDC Federation

GitHub must be configured as a trusted external identity for the Entra application.

In the Azure portal:

    Microsoft Entra ID
      -> App registrations
      -> github-vwan-terraform
      -> Certificates & secrets
      -> Federated credentials
      -> Add credential

Select the GitHub Actions scenario for deploying Azure resources.

Configure the GitHub repository information.

Organization:

    PetriPollanenAtea

Repository:

    vwan

Two federated credentials are recommended because the repository uses two GitHub environments.

---

## Federated Credential for Platform Plan

Create the first federated credential for:

    GitHub organization:
    PetriPollanenAtea

    Repository:
    vwan

    Entity type:
    Environment

    GitHub environment:
    platform-plan

Example federated credential name:

    github-vwan-platform-plan

This credential authorizes workflow jobs running in the `platform-plan` GitHub environment to authenticate as the Entra application.

---

## Federated Credential for Platform Production

Create another federated credential for:

    GitHub organization:
    PetriPollanenAtea

    Repository:
    vwan

    Entity type:
    Environment

    GitHub environment:
    platform-production

Example name:

    github-vwan-platform-production

This credential authorizes jobs running in the protected `platform-production` GitHub environment.

The production trust relationship is therefore:

    PetriPollanenAtea/vwan
             |
             v
    platform-production
             |
             v
    GitHub OIDC token
             |
             v
    Microsoft Entra federated credential
             |
             v
    Terraform deployment application
             |
             v
    Azure RBAC

GitHub environment protection should therefore be treated as part of the production deployment security boundary.

---

# Federated Credential Properties

GitHub and Entra validate the claims in the OIDC token against the federated identity credential.

For standard GitHub-to-Azure federation, the audience used for the exchange is:

    api://AzureADTokenExchange

The federated credential subject must correspond to the GitHub repository and entity configured for the workflow.

When GitHub environments are used, create the credential specifically for the environment rather than broadly trusting every branch of the repository.

The GitHub environment names used in the federated credentials must correspond to the environments referenced by the workflow:

    environment: platform-plan

and:

    environment: platform-production

If these values do not correspond to the federated trust configuration, Azure OIDC authentication fails.

---

# GitHub Azure Configuration

Configure the following values for the GitHub environments:

    AZURE_CLIENT_ID
    AZURE_TENANT_ID
    AZURE_SUBSCRIPTION_ID

Where:

    AZURE_CLIENT_ID
        Application (client) ID of the Entra application

    AZURE_TENANT_ID
        Directory (tenant) ID of the Entra tenant

    AZURE_SUBSCRIPTION_ID
        Azure subscription containing the deployed resources

These values are consumed by the Azure Login action.

The workflow uses:

    - name: Azure Login
      uses: azure/login@v2
      with:
        client-id: ${{ secrets.AZURE_CLIENT_ID }}
        tenant-id: ${{ secrets.AZURE_TENANT_ID }}
        subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

No client secret is supplied.

---

# GitHub Workflow OIDC Permissions

The workflow must be allowed to request a GitHub OIDC token.

The workflow therefore includes:

    permissions:
      contents: read
      id-token: write

The `id-token: write` permission allows the GitHub workflow to request the OIDC token used during Azure authentication.

This does not itself grant access to Azure.

Azure access is granted only after Microsoft Entra ID validates the GitHub OIDC token against the configured federated credential and the resulting Entra identity has the required Azure RBAC permissions.

---

# GitHub Variables

The following GitHub Actions variables are used by the workflows:

    TERRAFORM_VERSION

    TFSTATE_RESOURCE_GROUP
    TFSTATE_STORAGE_ACCOUNT
    TFSTATE_CONTAINER
    TFSTATE_PLATFORM_KEY

Example:

    TERRAFORM_VERSION       = 1.14.6

    TFSTATE_RESOURCE_GROUP  = rg-terraform-state
    TFSTATE_STORAGE_ACCOUNT = <storage-account-name>
    TFSTATE_CONTAINER       = tfstate
    TFSTATE_PLATFORM_KEY    = vwan/platform.tfstate

These can be configured from:

    Repository
      -> Settings
      -> Secrets and variables
      -> Actions
      -> Variables

Environment-specific values can alternatively be configured directly on the corresponding GitHub environment.

---

# Test OIDC Authentication

OIDC authentication should be tested before troubleshooting Terraform.

A simple GitHub Actions test can be used:

    name: Test Azure OIDC

    on:
      workflow_dispatch:

    permissions:
      contents: read
      id-token: write

    jobs:

      test:
        runs-on: ubuntu-latest

        environment: platform-plan

        steps:

          - name: Azure Login
            uses: azure/login@v2
            with:
              client-id: ${{ secrets.AZURE_CLIENT_ID }}
              tenant-id: ${{ secrets.AZURE_TENANT_ID }}
              subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

          - name: Verify Azure context
            uses: azure/cli@v2
            with:
              inlineScript: |
                az account show

If this workflow succeeds, the following path has been validated independently of Terraform:

    GitHub environment
         |
         v
    GitHub OIDC
         |
         v
    Entra federated credential
         |
         v
    Entra application/service principal
         |
         v
    Azure subscription

Only after this succeeds should Terraform backend or provider authentication be troubleshooted.

---

# OIDC Troubleshooting

When Azure Login fails, verify the configuration in this order.

## 1. GitHub workflow permissions

Confirm:

    permissions:
      id-token: write
      contents: read

## 2. Environment name

Confirm that the workflow uses the expected environment:

    environment: platform-plan

or:

    environment: platform-production

and that the corresponding federated credential exists in Entra.

## 3. Repository identity

Confirm the federated credential references:

    Organization:
    PetriPollanenAtea

    Repository:
    vwan

## 4. Entra application identifiers

Verify:

    AZURE_CLIENT_ID
    AZURE_TENANT_ID
    AZURE_SUBSCRIPTION_ID

against the intended Entra application, tenant, and Azure subscription.

## 5. Azure RBAC

Successful authentication does not guarantee authorization.

If Azure Login succeeds but Terraform receives authorization errors, verify Azure RBAC assignments for the service principal.

## 6. Terraform state access

If Terraform can authenticate to Azure but `terraform init` fails against the AzureRM backend, verify the identity's RBAC access to the Terraform state Storage Account or container.

---

# CI/CD Security Model

The intended security model is:

    Pull Request
          |
          v
    platform-plan
          |
          +-- OIDC federation
          +-- Terraform validation
          +-- Terraform plan
          |
          X
       No apply


    Manual deployment
          |
          v
    Terraform plan
          |
          v
    platform-production
          |
          +-- main branch restriction
          +-- required reviewer
          +-- prevent self-review
          |
          v
    OIDC federation
          |
          v
    Terraform apply

The production environment should be more tightly protected than the planning environment.

No long-lived Azure client secret should be required by either workflow.

---

# Initial CI/CD Setup Checklist

Before running the platform workflows, verify:

- [ ] Microsoft Entra application exists
- [ ] Application (client) ID recorded
- [ ] Directory (tenant) ID recorded
- [ ] Service principal has required Azure RBAC permissions
- [ ] Terraform state Storage Account access is configured
- [ ] GitHub environment `platform-plan` exists
- [ ] GitHub environment `platform-production` exists
- [ ] `platform-production` has required reviewers configured
- [ ] `platform-production` is restricted to `main`
- [ ] Federated credential exists for `platform-plan`
- [ ] Federated credential exists for `platform-production`
- [ ] `AZURE_CLIENT_ID` is configured
- [ ] `AZURE_TENANT_ID` is configured
- [ ] `AZURE_SUBSCRIPTION_ID` is configured
- [ ] Terraform backend variables are configured
- [ ] `TERRAFORM_VERSION` is configured
- [ ] OIDC test workflow succeeds
- [ ] Terraform plan workflow succeeds

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