# AWS-Scripts-Terraform

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
├── Scripts-Déploiement-MMA/
│   └── README.md
└── Scripts-Déploiement-Vaultwarden/
    ├── README.md
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    ├── variables.tf
    └── versions.tf
```
