# AutomationHub

# Déploiement .....
**Auteur But et Schéma planification**

| Élément        | Contenu         |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Référent**   | Guide de déploiement d’un serveur **Vaultwarden** (serveur compatible Bitwarden écrit en Rust) hébergé sur **AWS**,                                                                                                      |
| **Émetteur**   | **Abdul-Bariu – Abdul-Majid – Aran**                                                                                                                                                                                                                                                                                                                                |
| **Message**    | Présenter/documenter un tutoriel et les résultats du déploiement du serveur **Vaultwarden** sur AWS à l’aide des scripts Terraform.                                                                                                                                                                     |
| **Récepteur**  | M. Jérémy Massinon                                                                                                                                                                                                                                                                                                                                                  |
| **Canal**      | GitLab                                                                                                                                                                                                                                                                                                                       |
| **Code**       | Français                                                                                                                                                                                                                                                                                                                                                            |
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
