# Azure Firewall: Forced Tunneling (Cycle Error Fix)

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
- **Minimalist Base** — Perfect for testing routing concepts locally without massive cloud overhead.
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
├── providers.tf             # AzureRM Provider setup
├── variables.tf             # Input variable definitions
├── outputs.tf               # AFW Private IP & UDR IDs
└── README.md
```

## ⚠️ Known Limitations (Base Edition)

This is a functional baseline, but **DO NOT deploy this directly into production**. By blindly routing `0.0.0.0/0` to an unconfigured firewall, you will instantly break essential Azure PaaS services:

- **Windows Activation Failures:** Your VMs will lose their license status because Azure KMS traffic is trapped by the `0.0.0.0/0` route.
- **Azure AD Lockouts:** Managed Identities and Azure AD login will fail without specific Service Tag bypasses.
- **Management Nightmare:** This setup lacks IP Groups and FQDN policies, forcing you to manually update hundreds of IP addresses for basic Microsoft updates.

---

## 📖 Deep Dive

Read the full technical breakdown — cycle error root cause, KMS and Azure AD bypass routes, and dynamic IP Group design explained:

**[Azure Firewall Forced Tunneling: Solving the Cycle Error →](https://woitzik.dev/blog/azure-firewall-cycle-error)**

---

## 🔒 Need a Production-Ready Enterprise Firewall?

If you are building an enterprise Hub & Spoke architecture, you cannot afford broken Windows activations or blocked authentication traffic. You need dynamic IP scaling and pre-configured Microsoft service bypasses.

👉 **[Get the Enterprise Firewall Blueprint →](https://woitzik-cloud.lemonsqueezy.com/checkout/buy/a955d698-acf5-4654-ae16-bb8ec1f7be15)** The Enterprise Edition is a plug-and-play Terraform module that attaches seamlessly to any existing network. It includes:
- **KMS & Azure AD Bypasses:** Pre-built UDR injections to guarantee VMs stay activated and authenticated.
- **Dynamic IP Groups:** Never hardcode Spoke IPs again; pass variables and let the firewall scale automatically.
- **FQDN Application Policies:** Pre-configured rule collections for Windows Updates, NTP, and core infrastructure out of the box.

---

## 📄 License

MIT — free to use, modify, and distribute.

*Built by [David Woitzik](https://woitzik.dev) · [LinkedIn](https://linkedin.com/in/david-woitzik)*
