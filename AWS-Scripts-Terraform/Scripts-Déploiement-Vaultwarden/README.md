# Scripts-Déploiement-Vaultwarden

> **EN —** Terraform configuration that builds a VPC, a public subnet, a security group, an Ubuntu EC2 instance and an Elastic IP on AWS, then installs Docker, Vaultwarden and Caddy (automatic HTTPS) through `user_data`. The step-by-step guide below is in French.

## Contenu du dossier

| Fichier | Rôle |
|---|---|
| [`versions.tf`](versions.tf) | Version minimale de Terraform, fournisseur `hashicorp/aws` (~> 5.0) et région du fournisseur |
| [`variables.tf`](variables.tf) | Variables d'entrée : `aws_region` (défaut `us-east-1`) et `domain_name` (obligatoire) |
| [`main.tf`](main.tf) | Ressources : AMI Ubuntu 22.04, VPC, sous-réseau public, passerelle Internet, table de routage, ACL réseau, groupe de sécurité, instance EC2 avec script d'installation, Elastic IP |
| [`outputs.tf`](outputs.tf) | Sorties : IP publique (Elastic IP), URL HTTPS, ID de l'instance |
| [`terraform.tfvars.example`](terraform.tfvars.example) | Exemple de valeurs à copier dans `terraform.tfvars` (fichier exclu du dépôt) |

---

# Travail Pratique 3 – Guide de déploiement Vaultwarden sur AWS
**Auteur, but et planification**

| Élément        | Contenu                         |
| -------------- | ------------------------------- |
| **Référent**   | Guide de déploiement d’un serveur **Vaultwarden** (serveur compatible Bitwarden écrit en Rust) hébergé sur **AWS** |
| **Émetteur**   | **Bariu Azeez – Abdul-Majid – Aran** |
| **Message**    | Présenter/documenter un tutoriel et les résultats du déploiement du serveur **Vaultwarden** sur AWS à l’aide des scripts Terraform.  |
| **Récepteur**  | M. Jérémy Massinon  |
| **Canal**      | GitLab |
| **Code**       | Français |
| **Références** | [Vaultwarden](https://github.com/dani-garcia/vaultwarden) · [Terraform](https://developer.hashicorp.com/terraform/docs) · [AWS EC2 Docs](https://docs.aws.amazon.com/fr_fr/ec2/) · [AWS VPC Docs](https://docs.aws.amazon.com/vpc/) · |

-----

#### Prérequis

Avant de commencer, il faut :

- Un compte AWS functionelle avec les droits pour créer VPC, EC2, Elastic IP, etc.
- Un nom de domaine ou une zone DNS configuré
- Une machine Ubuntu avec accès Internet
- Les fichiers Terraform de ce dossier (`versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`), à l'origine dans le dépôt GitLab du cours

-----

### C’est quoi Vaultwarden ?

 D’abord, **Vaultwarden** est un gestionnaire de mots de passe (un *vault*) qui permet de garder de façon sécurisée :

- des mots de passe  
- des identifiants  
- des notes sécurisées  
- d’autres informations sensibles qui doivent être chiffrées  

C’est un serveur compatible avec **Bitwarden** type open-source et aussi plus simple à configurer et on peut l’installer sur notre propre serveur.

**Cet outil permet de :**

- Accéder à ses mots de passe depuis un navigateur web
- Stocker et chiffrer des mots de passe, notes sécurisées, identifiants, etc.
- Synchroniser les données entre navigateurs, applications mobiles et de bureau
- Partager des éléments entre plusieurs utilisateurs (équipe)

Dans le cadre de ce travail pratique, on déploie Vaultwarden sur AWS à l’aide de **Terraform** pour faire un déploiement automatsée.

-----

### Schéma globale du Déploiement

Les scripts Terraform qui produisent ce déploiement sont dans ce dossier (voir [Contenu du dossier](#contenu-du-dossier)). Le schéma ci-dessous reprend les ressources déclarées dans `main.tf` :

```mermaid
flowchart TB
    user["Client Bitwarden ou navigateur"]
    dns["DNS : domain_name vers l'Elastic IP"]

    subgraph aws["AWS - région var.aws_region"]
        eip["Elastic IP bitwarden-eip"]
        subgraph vpc["VPC bitwarden-vpc - 10.0.0.0/16"]
            igw["Internet Gateway bitwarden-igw"]
            rt["Table de routage bitwarden-public-rt : 0.0.0.0/0 vers IGW"]
            subgraph subnet["Sous-réseau public 10.0.1.0/24 - zone var.aws_region + a"]
                sg["Groupe de sécurité bitwarden-sg : entrée TCP 22, 80, 443"]
                subgraph ec2["EC2 Ubuntu 22.04 - t2.micro"]
                    caddy["Caddy : HTTPS automatique, redirection HTTP vers HTTPS"]
                    docker["Docker"]
                    vw["Conteneur vaultwarden/server : port 8000, volume /bw-data"]
                end
            end
        end
    end

    user --> dns --> eip --> igw
    igw --- rt
    igw --> sg --> caddy
    caddy -->|"reverse_proxy localhost:8000"| vw
    docker --- vw

    classDef ext fill:#070d1c,stroke:#2b9dff,color:#e6edf3
    classDef net fill:#070d1c,stroke:#3fe0a0,color:#e6edf3
    classDef sec fill:#070d1c,stroke:#ffb454,color:#e6edf3
    classDef app fill:#070d1c,stroke:#c792ea,color:#e6edf3
    class user,dns,eip ext
    class igw,rt net
    class sg sec
    class caddy,docker,vw app
```

Schéma de planification réalisé pendant le travail pratique :

----
![Capture 56](https://i.postimg.cc/3wHBMVRT/Screenshot-2025-11-18-at-8-15-03-PM.png)  

-----
### Phase 1 - Préparer la machine Ubuntu de déploiement

Cette phase sert à préparer votre machine qui va lancer Terraform ça peut être un Ubuntu.


#### Mettre à jour la machine
```
sudo apt update && sudo apt upgrade -y
```
---
![Capture 1](https://i.postimg.cc/tRF0QQDS/Screenshot-2025-11-18-at-6-05-11-PM.png)  
---

**Installer les outils de base**
```
sudo apt install -y git curl unzip software-properties-common
```
**Installer AWS CLI**
```
sudo apt install -y awscli

# cmd pour vérifier la version installer
aws --version
```
---
![Capture 3](https://i.postimg.cc/bY1XccLK/Screenshot-2025-11-18-at-6-07-05-PM.png)  
---
**Configurer les identifiants AWS (les clés sont données / créées dans la console AWS) :**

**Option 1:**: 
```
aws configure
AWS Access Key ID: ***************
AWS Secret Access Key: ***************
Default region name: ca-central-1    # (prennez le meme de votre compte aws)
Default output format: json
```
------
![Capture 8](https://i.postimg.cc/ZKmGJ7DD/Screenshot-2025-11-18-at-6-27-00-PM.png)  
------
**Configurer les identifiants AWS en ligne de commande (les clés sont données / créées dans la console AWS) :**

**Option 2:** 
```
nano ~/.aws/credentials
```
- Tapez vos identifiants AWS dans le fichier credentials
```
AWS Access Key ID= ***************
AWS Secret Access Key= ***************
aws_session_token= *****************
Default region name= ********************
```
---
![Capture 51](https://i.postimg.cc/jdmccLYt/Screenshot-2025-11-18-at-7-19-18-PM.png)  
---
- Les informations des identifiants AWS s'est trouve dans cette section de votre compte AWS
----
![Capture 7](https://i.postimg.cc/Nft3QJPC/Screenshot-2025-11-18-at-6-22-23-PM.png)  
----

#### Installer Terraform

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install -y terraform

# CMD pour vérifier la version installer
terraform -version
```
---
![Capture 5](https://i.postimg.cc/VsXyQQ42/Screenshot-2025-11-18-at-6-09-02-PM.png)  
---

### Phase 2 - Initialisation

Donc ici cette phase sert à copier les script et par la suite lancer le déploiement à partir des scripts Terraform déjà présents dans le repotoire.

1. **Récupérer les fichiers `.tf` de ce dossier (clonage du dépôt ou copie)**
2. **Aller dans le terminal de ubuntu et créer le dossier Terraform**
3. **Créer et coller dans chaque fichier créer les éléments du scripts-terraform**
```
cd ~/terraform
```
**ou bien**
```
mkdir ~/terraform
```
---
![Capture 10](https://i.postimg.cc/m24vTX6J/Screenshot-2025-11-18-at-6-30-10-PM.png)  
---

**Renseigner les variables** : copier l'exemple puis remplacer `domain_name` par votre nom de domaine. Le fichier `terraform.tfvars` est exclu du dépôt par le `.gitignore`.
```
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

**Initialiser Terraform** : Cette commande télécharge les plugins soit chez AWS ou bien tout ce qui est nécessaire et prépare le dossier.
```
terraform init
```
---
![Capture 11](https://i.postimg.cc/ncxynRPt/Screenshot-2025-11-18-at-6-31-11-PM.png)  
---

**Plan de déploiement**

```
terraform plan
```

Cette commande :

* lit les scripts Terraform dans le dossier,
* montre ce qui va être créé (VPC, EC2, etc.),
* enregistre le plan dans le dossier

---

**Appliquer le plan et par la suit elle lancer le déploiement**

```
terraform apply
```
Terraform va alors :

* créer le VPC, le subnet, l’Internet Gateway
* créer le groupe de sécurité
* créer l’instance EC2 Ubuntu
* exécuter le script d’installation de Vaultwarden sur cette instance

---
![Capture 12](https://i.postimg.cc/X7WRnHz6/Screenshot-2025-11-18-at-6-36-09-PM.png)  
---
**À la fin, Terraform affiche des **outputs** définis :**

* L’adresse IP publique de l’instance
* Le nom DNS ou bien le url du serveur
* L'id de instance
---
![Capture 16](https://i.postimg.cc/m24vTX5D/Screenshot-2025-11-18-at-6-42-24-PM.png)  
---
**Ensuite, allez à la page web du fourniseur duckdns.org et créer vous un compte afin de réattribuer l'addresse ip public à notre nom de domaine**
- Voici la capture du résultat attendu:
----
![Capture 21](https://i.postimg.cc/xTPW8vwT/Screenshot-2025-11-18-at-6-55-29-PM.png)  
----

**ATTENTION!**
**ATTENTION!**
**La commande DESTROY détruire et supprime l’infrastructure créer**

```
terraform destroy
```
---
![Capture 52](https://i.postimg.cc/6pZ0mtBH/Screenshot-2025-11-18-at-7-58-53-PM.png)  
---

### Phase 3 - Tests de fonctionnement

> [!NOTE]
> Les identifiants AWS (`vpc-…`, `subnet-…`, `sg-…`, `i-…`), l'adresse IP publique et le nom de domaine du laboratoire ont été remplacés par des valeurs génériques entre `< >`. Ces valeurs ne servent qu'à un déploiement donné : chaque nouveau déploiement produit ses propres valeurs (voir les sorties `terraform output`).

**Configuration du VPC**

* **VPC** : `<vpc-id>` (`bitwarden-vpc`)
* **CIDR IPv4** : `10.0.0.0/16`
* **Sous-réseau public** : `<subnet-id>` (`bitwarden-public-subnet`) en **us-east-1a**
* **Passerelle Internet** : `bitwarden-igw` reliée au VPC
* **Table de routage publique** : `bitwarden-public-rt` avec une route `0.0.0.0/0` vers l’Internet Gateway
* **Groupe de sécurité associé à l’instance** : `<sg-id>` (`bitwarden-sg`)
------
- En Bref
- Internet = vers ports 80/443 du **bitwarden-sg**
- Serveur web Caddy sur l’EC2 = vers conteneur **Vaultwarden**
---
![Capture 20](https://i.postimg.cc/15KLXGk3/Screenshot-2025-11-18-at-6-48-55-PM.png)
-----
**Instance EC2 Vaultwarden**

* **Nom de l’instance** : `Vaultwarden-Server`
* **ID de l’instance** : `<instance-id>`
* **Région / Zone de dispo** : `us-east-1` – `us-east-1a`
* **Type d’instance EC2** : `t2.micro`
* **VPC** : `<vpc-id>` (`bitwarden-vpc`)
* **Sous-réseau** : `<subnet-id>` (`bitwarden-public-subnet`)
* **Adresse IP privée** : une adresse de `10.0.1.0/24` attribuée par AWS
* **Adresse IPv4 publique / Elastic IP** : `<elastic-ip>` (`bitwarden-eip`)
* **DNS public EC2** : `ec2-<elastic-ip>.compute-1.amazonaws.com`
* **Nom de domaine utilisé pour l’appli** : `<domain_name>` (DuckDNS, pointe vers `<elastic-ip>`)
* **Groupe de sécurité attaché** : `<sg-id>` (`bitwarden-sg`)
* **Ports exposés publiquement** :
  * **22/TCP** : SSH (administration)
  * **80/TCP** : HTTP (redirection vers HTTPS par Caddy)
  * **443/TCP** : HTTPS (accès sécurisé au site Vaultwarden)
----
![Capture 18](https://i.postimg.cc/jdTpRgFn/Screenshot-2025-11-18-at-6-47-14-PM.png)  
----
* **Groupe de sécurité attaché** : `<sg-id>` (`bitwarden-sg`)
----
![Capture 19](https://i.postimg.cc/MKYhH7C6/Screenshot-2025-11-18-at-6-47-31-PM.png)  
----

### Phase 4 - Validation

- Résultats Attendu: **Page web en https et avec nom de domaine**
----
![Capture 22](https://i.postimg.cc/jdhG2Hpj/Screenshot-2025-11-18-at-6-55-54-PM.png)  
---
![Capture 54](https://i.postimg.cc/GmDQ5dbf/Screenshot-2025-11-18-at-8-09-05-PM.png)  
---
- Résultats Attendu: **Création d'un compte pour vérifier les fonctionnalités**
----
![Capture 55](https://i.postimg.cc/VktRVmzT/Screenshot-2025-11-18-at-8-14-23-PM.png)  
-----
