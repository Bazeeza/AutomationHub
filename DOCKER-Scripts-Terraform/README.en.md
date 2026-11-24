# DOCKER-Scripts-Terraform

[![Français](https://img.shields.io/badge/Langue-Français-3fe0a0?style=for-the-badge)](README.md)
[![English](https://img.shields.io/badge/Language-English-2b9dff?style=for-the-badge)](README.en.md)

> [!NOTE]
> **EN —** Placeholder folder: it contains no script yet. In the current project, Docker and the Vaultwarden container are installed by the EC2 `user_data` script in [`main.tf`](../AWS-Scripts-Terraform/Scripts-Déploiement-Vaultwarden/main.tf), not by a separate Terraform configuration.
>
> **FR —** Dossier réservé : il ne contient encore aucun script. Dans le projet actuel, Docker et le conteneur Vaultwarden sont installés par le script `user_data` de l'instance EC2 dans [`main.tf`](../AWS-Scripts-Terraform/Scripts-Déploiement-Vaultwarden/main.tf), et non par une configuration Terraform séparée.

## Where the Docker deployment happens today

The `user_data` script run at the first boot of the instance:

| Step | Main command (excerpt from `main.tf`) |
|---|---|
| Install Docker | `apt install -y docker.io` then `systemctl enable --now docker` |
| Create the persistent folder | `mkdir -p /bw-data` |
| Start Vaultwarden | `docker run -d --name vaultwarden --restart unless-stopped -v /bw-data/:/data/ -e ROCKET_PORT=8000 -p 127.0.0.1:8000:8000 ${var.vaultwarden_image}` |
| Publish over HTTPS | Caddy, `reverse_proxy localhost:8000` on `var.domain_name` |

Port 8000 is only published on `127.0.0.1`: the container can only be reached by Caddy, on the same machine. `--restart unless-stopped` restarts the container after a reboot of the instance. The image is set by the `vaultwarden_image` variable (pinned version, never `:latest`).

There is therefore **nothing to run in this folder**: a single `terraform apply` in `Scripts-Déploiement-Vaultwarden` creates the infrastructure and starts the container.
