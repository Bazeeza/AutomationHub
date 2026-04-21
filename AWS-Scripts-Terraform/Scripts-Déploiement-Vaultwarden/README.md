# AWS-Scripts-Terraform

This is a README for the AWS-Scripts-Terraform folder.
# Travail Pratique 3 – Guide/Tuto Déploiement Ubuntu Desktop
**Auteur But et Schéma planification**

| Élément        | Contenu                                                                                                                                                                                                                                                                                                                                                             |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Référent**   | Guide de déploiement d’un serveur **Vaultwarden** (serveur compatible Bitwarden écrit en Rust) hébergé sur **AWS** |
| **Émetteur**   | **Abdul-Bariu – Abdul-Majid – Aran**                                                                                                                                                     |
| **Message**    | Présenter/documenter un tutoriel et les résultats du déploiement du serveur **Vaultwarden** sur AWS à l’aide des scripts Terraform.  |
| **Récepteur**  | M. Jérémy Massinon     |
| **Canal**      | GitLab   |
| **Code**       | Français                               |
| **Références** | [Vaultwarden](https://github.com/dani-garcia/vaultwarden) · [Terraform](https://developer.hashicorp.com/terraform/docs) · [AWS EC2 Docs](https://docs.aws.amazon.com/fr_fr/ec2/) · [AWS VPC Docs](https://docs.aws.amazon.com/vpc/) · |

-----

#### Prérequis

Avant de commencer, il faut :

- Un compte AWS functionelle avec les droits pour créer VPC, EC2, Elastic IP, etc.
- Un nom de domaine ou une zone DNS configuré
- Une machine Ubuntu avec accès Internet
- Votre script terraform qui est dans le répertoire Scripts-Terraform du projets git-lab H73-A25-TP3-Abdul_Aran_Azeez_Freddy 

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

    Les scripts Terraform s'est trouve dans le répertoire Scripts-Terraform du projets git-lab H73-A25-TP3-Abdul_Aran_Azeez_Freddy
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

1. **Aller dans git est copier tout les fichier et éléments du répertoire Scripts-Terraform du projets git-lab H73-A25-TP3-Abdul_Aran_Azeez_Freddy**
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

**Configuration du VPC**

* **VPC** : `vpc-049347764302a4881` (`bitwarden-vpc`)
* **CIDR IPv4** : `10.0.0.0/16`
* **Sous-réseau public** : `subnet-0ae2a012b3571f91a` (`bitwarden-public-subnet`) en **us-east-1a**
* **Passerelle Internet** : `bitwarden-igw` reliée au VPC
* **Table de routage publique** : `bitwarden-public-rt` avec une route `0.0.0.0/0` vers l’Internet Gateway
* **Groupe de sécurité associé à l’instance** : `sg-0ca760bcf26bdcc8e` (`bitwarden-sg`)
------
- En Bref
- Internet = vers ports 80/443 du **bitwarden-sg**
- Serveur web Caddy sur l’EC2 = vers conteneur **Vaultwarden**
---
![Capture 20](https://i.postimg.cc/15KLXGk3/Screenshot-2025-11-18-at-6-48-55-PM.png)
-----
**Instance EC2 Vaultwarden**

* **Nom de l’instance** : `Vaultwarden-Server`
* **ID de l’instance** : `i-0fc11d6b791f8e63f`
* **Région / Zone de dispo** : `us-east-1` – `us-east-1a`
* **Type d’instance EC2** : `t2.micro`
* **VPC** : `vpc-049347764302a4881` (`bitwarden-vpc`)
* **Sous-réseau** : `subnet-0ae2a012b3571f91a` (`bitwarden-public-subnet`)
* **Adresse IP privée** : `10.0.1.35`
* **Adresse IPv4 publique / Elastic IP** : `3.213.60.70` (`bitwarden-eip`)
* **DNS public EC2** : `ec2-3-213-60-70.compute-1.amazonaws.com`
* **Nom de domaine utilisé pour l’appli** : `vault-tp3-faaaaaa.duckdns.org` (DuckDNS, pointe vers `3.213.60.70`)
* **Groupe de sécurité attaché** : `sg-0ca760bcf26bdcc8e` (`bitwarden-sg`)
* **Ports exposés publiquement** :
  * **22/TCP** : SSH (administration)
  * **80/TCP** : HTTP (redirection vers HTTPS par Caddy)
  * **443/TCP** : HTTPS (accès sécurisé au site Vaultwarden)
----
![Capture 18](https://i.postimg.cc/jdTpRgFn/Screenshot-2025-11-18-at-6-47-14-PM.png)  
----
* **Groupe de sécurité attaché** : `sg-0ca760bcf26bdcc8e` (`bitwarden-sg`)
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
