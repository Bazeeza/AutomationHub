# AutomationHub

Déploiement automatisé d'infrastructure sur AWS à l'aide de **Terraform** et de **Docker**.

Ce dépôt regroupe les scripts d'infrastructure as code (IaC) permettant de provisionner un environnement cloud complet et de déployer un service conteneurisé, avec une documentation reproductible étape par étape.

---

## Contexte du projet

| Élément | Contenu |
|---|---|
| **Objet** | Guide de déploiement d'un serveur **Vaultwarden** (gestionnaire de mots de passe compatible Bitwarden, écrit en Rust) hébergé sur AWS |
| **Équipe** | Bariu Azeez · Abdul-Majid · Aran |
| **Objectif** | Documenter le déploiement complet du serveur Vaultwarden sur AWS au moyen de scripts Terraform, puis présenter les résultats obtenus |
| **Cadre** | Projet réalisé dans le cadre du DEC en Techniques de l'informatique (Réseautique), Collège de Rosemont |
| **Langue** | Français |

---

## Contenu du dépôt

```
AutomationHub/
├── AWS-Scripts-Terraform/      # Provisionnement de l'infrastructure AWS (VPC, EC2, Elastic IP)
└── DOCKER-Scripts-Terraform/   # Déploiement du conteneur Vaultwarden
```

**`AWS-Scripts-Terraform/`** — Création du réseau privé virtuel (VPC), des sous-réseaux, des groupes de sécurité, de l'instance EC2 et de l'adresse IP élastique.

**`DOCKER-Scripts-Terraform/`** — Déploiement du service Vaultwarden en conteneur Docker sur l'instance provisionnée.

---

## Qu'est-ce que Vaultwarden ?

Vaultwarden est un gestionnaire de mots de passe auto-hébergé, compatible avec les clients Bitwarden. Il permet de conserver de façon sécurisée et chiffrée :

- des identifiants et mots de passe
- des notes sécurisées
- des informations de cartes de paiement
- des identités et documents sensibles

Écrit en Rust, il est nettement plus léger que le serveur Bitwarden officiel, ce qui le rend idéal pour un déploiement sur une petite instance cloud.

---

## Prérequis

Avant de commencer, il faut disposer de :

- Un **compte AWS fonctionnel** avec les droits nécessaires pour créer des ressources VPC, EC2 et Elastic IP
- Un **nom de domaine** ou une zone DNS configurée
- Une machine **Ubuntu** avec accès à Internet
- **Terraform** installé (version 1.0 ou supérieure)
- L'**AWS CLI** configurée avec vos identifiants (`aws configure`)

---

## Déploiement

### 1. Cloner le dépôt

```bash
git clone https://github.com/Bazeeza/AutomationHub.git
cd AutomationHub/AWS-Scripts-Terraform
```

### 2. Initialiser Terraform

```bash
terraform init
```

### 3. Vérifier le plan d'exécution

```bash
terraform plan
```

### 4. Appliquer la configuration

```bash
terraform apply
```

### 5. Déployer le conteneur Vaultwarden

```bash
cd ../DOCKER-Scripts-Terraform
terraform init
terraform apply
```

### 6. Détruire l'infrastructure (nettoyage)

```bash
terraform destroy
```

---

## Sécurité

> **Important** — Aucun identifiant, clé d'accès ou mot de passe ne doit être inscrit en clair dans les fichiers de configuration.
>
> Utilisez plutôt des **variables d'environnement**, un fichier `terraform.tfvars` exclu du dépôt via `.gitignore`, ou **AWS Secrets Manager**.

---

## Technologies utilisées

`Terraform` · `AWS (VPC, EC2, Elastic IP, Security Groups)` · `Docker` · `Ubuntu Server` · `Vaultwarden`

---

## Compétences démontrées

- Infrastructure as Code (IaC) avec Terraform
- Conception et segmentation d'un réseau cloud (VPC, sous-réseaux, groupes de sécurité)
- Déploiement et gestion de services conteneurisés
- Rédaction de procédures techniques reproductibles (runbooks)
- Travail collaboratif avec versionnement Git

---

## Auteur

**Bariu Azeez**
Technicien en réseautique et télécommunication — Montréal, QC
Portfolio : [bazeeza.github.io](https://bazeeza.github.io) · GitHub : [@Bazeeza](https://github.com/Bazeeza)
