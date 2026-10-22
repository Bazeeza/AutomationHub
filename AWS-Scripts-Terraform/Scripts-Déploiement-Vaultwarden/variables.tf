#variables.tf


variable "aws_region" {
  description = "Région AWS où déployer l'infrastructure (la zone utilisée est <région>a)"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Nom de domaine complet qui pointe vers l'Elastic IP (ex: vault.exemple.duckdns.org)"
  type        = string
}
