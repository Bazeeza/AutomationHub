# outputs.tf

output "bitwarden_public_ip" {
  value = aws_eip.bitwarden_eip.public_ip
  description = "Adresse IP publique fixe du serveur Bitwarden"
}

output "bitwarden_url" {
  value = "https://vault-tp3-faaa.duckdns.org"
  description = "URL finale du serveur Bitwarden en HTTPS"
}

output "instance_id" {
  value = aws_instance.bitwarden_server.id
  description = "ID de l'instance EC2"
}
