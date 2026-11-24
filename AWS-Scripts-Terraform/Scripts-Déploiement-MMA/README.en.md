# Scripts-Déploiement-MMA

[![Français](https://img.shields.io/badge/Langue-Français-3fe0a0?style=for-the-badge)](README.md)
[![English](https://img.shields.io/badge/Language-English-2b9dff?style=for-the-badge)](README.en.md)

> [!NOTE]
> **EN —** Placeholder folder. It does not contain any Terraform file yet: only this README is tracked.
>
> **FR —** Dossier réservé. Il ne contient encore aucun fichier Terraform : seul ce README est suivi par git.

## Current state

| Item | State |
|---|---|
| `.tf` files | None |
| Scripts | None |
| Documentation | This file only |

The working deployment of the repository is in [`../Scripts-Déploiement-Vaultwarden/`](../Scripts-Déploiement-Vaultwarden/README.en.md).

When files are added here, they must follow the same rules as the rest of the repository: no `terraform.tfvars` or `*.tfstate` published (see the [`.gitignore`](../../.gitignore)), and a documented `terraform.tfvars.example` file.
