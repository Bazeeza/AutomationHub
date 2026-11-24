# AWS-Scripts-Terraform

[![Français](https://img.shields.io/badge/Langue-Français-3fe0a0?style=for-the-badge)](README.md)
[![English](https://img.shields.io/badge/Language-English-2b9dff?style=for-the-badge)](README.en.md)

> **EN —** Terraform configurations for AWS. Each sub-folder is an independent Terraform root module: run `terraform init`, `plan` and `apply` inside the sub-folder, not here.
>
> **FR —** Configurations Terraform pour AWS. Chaque sous-dossier est un module racine indépendant : les commandes `terraform init`, `plan` et `apply` se lancent dans le sous-dossier, pas ici.

| Sous-dossier | Contenu | État |
|---|---|---|
| [`Scripts-Déploiement-Vaultwarden/`](Scripts-Déploiement-Vaultwarden/) | VPC, sous-réseau public, groupe de sécurité, EC2 Ubuntu, Elastic IP ; installation de Docker, Vaultwarden et Caddy par `user_data` ; guide pas à pas du TP | Fonctionnel |
| [`Scripts-Déploiement-MMA/`](Scripts-Déploiement-MMA/) | README seulement | Réservé |

```
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
