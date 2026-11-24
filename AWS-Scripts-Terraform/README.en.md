# AWS-Scripts-Terraform

[![Français](https://img.shields.io/badge/Langue-Français-3fe0a0?style=for-the-badge)](README.md)
[![English](https://img.shields.io/badge/Language-English-2b9dff?style=for-the-badge)](README.en.md)

> **EN —** Terraform configurations for AWS. Each sub-folder is an independent Terraform root module: run `terraform init`, `plan` and `apply` inside the sub-folder, not here.
>
> **FR —** Configurations Terraform pour AWS. Chaque sous-dossier est un module racine indépendant : les commandes `terraform init`, `plan` et `apply` se lancent dans le sous-dossier, pas ici.

| Sub-folder | Contents | State |
|---|---|---|
| [`Scripts-Déploiement-Vaultwarden/`](Scripts-Déploiement-Vaultwarden/README.en.md) | VPC, public subnet, security group, Ubuntu EC2 instance, Elastic IP; Docker, Vaultwarden and Caddy installed by `user_data`; step-by-step lab guide | Working |
| [`Scripts-Déploiement-MMA/`](Scripts-Déploiement-MMA/README.en.md) | README only | Reserved |

```text
AWS-Scripts-Terraform/
├── README.md
├── README.en.md
├── Scripts-Déploiement-MMA/
│   ├── README.md
│   └── README.en.md
└── Scripts-Déploiement-Vaultwarden/
    ├── README.md
    ├── README.en.md
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    ├── variables.tf
    └── versions.tf
```
