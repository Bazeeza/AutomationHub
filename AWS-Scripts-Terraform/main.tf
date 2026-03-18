# main.tf (Version finale sans IAM SSM pour AWS Academy – Avec HTTPS force via Caddy redirect)
# Recherche de l'AMI Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "bitwarden-vpc"
  }
}

# Subnet Public
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "bitwarden-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "bitwarden-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "bitwarden-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Network ACL (Pour allow all inbound/outbound – Fixe timeouts)
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "bitwarden-nacl"
  }
}

# Security Group
resource "aws_security_group" "bitwarden_sg" {
  name        = "bitwarden-sg"
  description = "HTTP + HTTPS pour Vaultwarden"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name      = "bitwarden-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bitwarden_sg.id
}

resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bitwarden_sg.id
}

# SSH Temporaire (Limité à ton IP pour sécurité – Change 0.0.0.0/0 si tu as ton IP)
resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bitwarden_sg.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bitwarden_sg.id
}

# Elastic IP (IP fixe)
resource "aws_eip" "bitwarden_eip" {
  domain = "vpc"
  tags = {
    Name = "bitwarden-eip"
  }
}

# Instance EC2
resource "aws_instance" "bitwarden_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bitwarden_sg.id]
  associate_public_ip_address = true

  tags = {
    Name        = "Vaultwarden-Server"
    Project     = "TP3-Bitwarden"
    ManagedBy   = "terraform"
  }

  # Script d'installation automatique (Avec UFW allow pour fix timeouts, et Caddy avec redirect HTTP->HTTPS)
  user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    set -e
    # Mise à jour
    apt update -y && apt upgrade -y
    # Forcer démarrage SSH
    systemctl start ssh
    systemctl enable ssh
    # Ouvrir ports dans UFW (Firewall OS)
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 22/tcp
    ufw reload
    # Docker
    apt install -y docker.io
    systemctl enable --now docker
    # Dossier persistant
    mkdir -p /bw-data
    # Lancer Vaultwarden sur port 8000
    docker run -d \
      --name vaultwarden \
      -v /bw-data/:/data/ \
      -e ROCKET_PORT=8000 \
      -p 8000:8000 \
      vaultwarden/server:latest
    # Caddy pour HTTPS auto
    apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt update -y
    apt install -y caddy
    # Caddyfile avec ton domaine et redirect HTTP->HTTPS
    cat > /etc/caddy/Caddyfile <<'EOC'
    http:// {
        redir https://{host}{uri}
    }
    vault-tp3-faaa.duckdns.org {
        reverse_proxy localhost:8000
        tls {
            on_demand
        }
    }
    EOC
    systemctl restart caddy
    systemctl enable caddy
    echo "Vaultwarden prêt sur https://vault-tp3-faaa.duckdns.org" > /var/log/vaultwarden.log
    EOF
  )
}

# Associer l'EIP à l'instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.bitwarden_server.id
  allocation_id = aws_eip.bitwarden_eip.id
}
