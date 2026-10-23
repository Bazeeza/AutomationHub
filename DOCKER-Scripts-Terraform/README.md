# DOCKER-Scripts-Terraform

> [!NOTE]
> **EN —** Placeholder folder: it contains no script yet. In the current project, Docker and the Vaultwarden container are installed by the EC2 `user_data` script in [`main.tf`](../AWS-Scripts-Terraform/Scripts-Déploiement-Vaultwarden/main.tf), not by a separate Terraform configuration.
>
> **FR —** Dossier réservé : il ne contient encore aucun script. Dans le projet actuel, Docker et le conteneur Vaultwarden sont installés par le script `user_data` de l'instance EC2 dans [`main.tf`](../AWS-Scripts-Terraform/Scripts-Déploiement-Vaultwarden/main.tf), et non par une configuration Terraform séparée.

## Où se fait le déploiement Docker aujourd'hui

Le script `user_data` exécuté au premier démarrage de l'instance :

| Étape | Commande principale (extrait de `main.tf`) |
|---|---|
| Installer Docker | `apt install -y docker.io` puis `systemctl enable --now docker` |
| Créer le dossier persistant | `mkdir -p /bw-data` |
| Lancer Vaultwarden | `docker run -d --name vaultwarden --restart unless-stopped -v /bw-data/:/data/ -e ROCKET_PORT=8000 -p 127.0.0.1:8000:8000 ${var.vaultwarden_image}` |
| Publier en HTTPS | Caddy, `reverse_proxy localhost:8000` sur `var.domain_name` |

Le port 8000 n'est publié que sur `127.0.0.1` : le conteneur n'est joignable que par Caddy, sur la même machine. `--restart unless-stopped` relance le conteneur après un redémarrage de l'instance. L'image est fixée par la variable `vaultwarden_image` (version épinglée, jamais `:latest`).

Il n'y a donc **rien à lancer dans ce dossier** : un seul `terraform apply` dans `Scripts-Déploiement-Vaultwarden` crée l'infrastructure et démarre le conteneur.
