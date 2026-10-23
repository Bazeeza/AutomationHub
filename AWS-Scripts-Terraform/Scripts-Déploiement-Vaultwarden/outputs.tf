# outputs.tf
# Valeurs affichées à la fin de `terraform apply` (et relisibles avec `terraform output`).

output "bitwarden_public_ip" {
  description = "Elastic IP fixe du serveur : c'est l'adresse vers laquelle doit pointer l'enregistrement DNS de domain_name"
  value       = aws_eip.bitwarden_eip.public_ip
}

output "bitwarden_url" {
  description = "URL HTTPS finale de Vaultwarden (fonctionne une fois le DNS propagé et le certificat obtenu par Caddy)"
  value       = "https://${var.domain_name}"
}

output "instance_id" {
  description = "ID de l'instance EC2, utile pour la console AWS ou l'AWS CLI (ex: aws ec2 describe-instances)"
  value       = aws_instance.bitwarden_server.id
}

output "ssh_command" {
  description = "Commande SSH d'administration (utilisateur ubuntu de l'AMI Canonical) ; null si aucune paire de clés n'est fournie"
  value       = var.ssh_key_name == null ? null : "ssh -i <${var.ssh_key_name}.pem> ubuntu@${aws_eip.bitwarden_eip.public_ip}"
}
