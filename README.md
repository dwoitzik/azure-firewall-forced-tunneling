# Azure Firewall: Forced Tunneling (Cycle Error Fix)

[![CI](https://github.com/dwoitzik/azure-firewall-forced-tunneling/actions/workflows/tf-linter.yml/badge.svg)](https://github.com/dwoitzik/azure-firewall-forced-tunneling/actions/workflows/tf-linter.yml)

A minimal, targeted Infrastructure as Code (IaC) template demonstrating how to implement Azure Firewall Forced Tunneling (`0.0.0.0/0`) while completely avoiding the infamous **Terraform Circular Dependency (Cycle Error)**.

When assigning a Route Table to a Spoke Subnet that points to an Azure Firewall's private IP, Terraform often deadlocks because it cannot resolve the dependency graph. This repository provides the clean, functional baseline to break that loop.

```text
                        ┌──────────────────────────┐
                        │        vnet-hub          │
                        │   [ Azure Firewall ]     │
                        │      (10.0.1.4)          │
                        └────────────▲─────────────┘
                                     │
                         0.0.0.0/0 (Next Hop: NVA)
                                     │
                        ┌────────────┴─────────────┐
                        │        vnet-spoke        │
                        │     [ Route Table ]      │
                        └──────────────────────────┘
```

## 🚀 Features

- **Cycle Error Resolution** — Code structured to naturally resolve the UDR vs. Firewall IP dependency graph.
- **Forced Tunneling UDR** — Standard `0.0.0.0/0` route pointing to the Virtual Appliance.
- **KMS & Azure AD Bypasses** — Pre-built UDR injections so Windows activation and Entra ID auth keep working under forced tunneling.
- **Dynamic IP Groups** — Spoke CIDRs feed an `azurerm_ip_group`, so firewall policy rules scale without hardcoding IPs.
- **FQDN Application Policies** — Pre-configured rule collection for Windows Update and core Microsoft endpoints, ready to extend.
- **Parametrized Inputs** — Clean `variables.tf` to avoid hardcoded environments.

## 🛠️ Prerequisites

- Terraform `>= 1.5.0`
- Azure CLI (`az login`)
- An active Azure Subscription

## 📖 Usage

**1. Clone the repository**

```bash
git clone https://github.com/dwoitzik/azure-firewall-forced-tunneling.git
cd azure-firewall-forced-tunneling
```

**2. Configure your variables**

Create a `terraform.tfvars` file (or use default values):

```hcl
environment       = "demo"
rg_name           = "rg-forced-tunneling"
location          = "westeurope"
hub_vnet_cidr     = ["10.0.0.0/16"]
spoke_vnet_cidr   = ["10.1.0.0/16"]
```

**3. Deploy**

```bash
terraform init
terraform plan
# Only apply if you want to incur Azure Firewall costs (~$1.25/hour)
# terraform apply
```

## 📁 Repository Structure

```text
.
├── main.tf                  # Base Network, Firewall & Route Table logic
├── policies.tf               # Firewall Policy & FQDN rule collections
├── ip_groups.tf               # Dynamic IP Group for spoke CIDRs
├── routing.tf                 # Forced-tunneling UDR + KMS/Azure AD bypasses
├── providers.tf              # AzureRM Provider setup
├── variables.tf              # Input variable definitions
├── outputs.tf                # AFW Private/Public IP & UDR IDs
└── README.md
```

## ⚠️ Known Limitations

Forced tunneling still means every packet leaving a spoke subnet hits this firewall — that's the point, but it's also a single point of failure and a real cost (~$1.25/hour for the firewall itself). The KMS and Azure AD bypasses cover the two most common lockout scenarios; if you add other PaaS services behind this firewall, check whether they need their own bypass route or an FQDN rule before relying on it in production.

---

## 📖 Deep Dive

Read the full technical breakdown — cycle error root cause, KMS and Azure AD bypass routes, and dynamic IP Group design explained:

**[Azure Firewall Forced Tunneling: Solving the Cycle Error →](https://woitzik.dev/blog/azure-firewall-cycle-error)**

---

## 📄 License

MIT — free to use, modify, and distribute.

*Built by [David Woitzik](https://woitzik.dev) · [LinkedIn](https://linkedin.com/in/david-woitzik)*
