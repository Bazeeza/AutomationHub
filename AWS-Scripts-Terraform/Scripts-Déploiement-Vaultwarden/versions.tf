# versions.tf
# Version de Terraform et du fournisseur AWS requises par ce projet.
# Sans ce bloc, Terraform prend la derniere version du fournisseur et la region
# vient uniquement de l'environnement (AWS_REGION), ce qui peut ne pas correspondre
# a la zone de disponibilite "${var.aws_region}a" utilisee dans main.tf.

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # l'argument `domain = "vpc"` de aws_eip existe depuis la v5
    }
  }
}

provider "aws" {
  region = var.aws_region
}
