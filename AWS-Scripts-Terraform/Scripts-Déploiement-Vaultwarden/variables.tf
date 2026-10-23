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

variable "instance_type" {
  description = "Type d'instance EC2 qui héberge Docker, Caddy et Vaultwarden"
  type        = string
  default     = "t2.micro"
}

variable "vaultwarden_image" {
  description = "Image Docker de Vaultwarden, épinglée à une version précise (jamais :latest) pour des déploiements reproductibles"
  type        = string
  default     = "vaultwarden/server:1.37.4"
}

variable "allowed_ssh_cidr" {
  description = "Plage CIDR autorisée à se connecter en SSH (port 22), idéalement votre seule adresse publique en /32 (ex: 203.0.113.10/32)"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0)) && var.allowed_ssh_cidr != "0.0.0.0/0"
    error_message = "allowed_ssh_cidr doit être une plage CIDR IPv4 valide (ex: 203.0.113.10/32) et ne peut pas être 0.0.0.0/0."
  }
}
