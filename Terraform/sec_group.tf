# Security group and rules for the minecraft server
# Inbound traffic on port 25565 and port 22 for server connections and SSH functionality
# SSH source set to anywhere (0.0.0.0/0) to limit manual local IP updates

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-sg"
  description = "Allows server connection and private SSH connections"
  vpc_id      = aws_vpc.minecraft_server_vpc.id

  tags = {
    Name = "minecraft-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "user_connections" {
  security_group_id = aws_security_group.minecraft_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 25565
  to_port           = 25565
  ip_protocol       = "tcp"
  description       = "Allows server connections by users on port 25565"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_connections" {
  security_group_id = aws_security_group.minecraft_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allows SSH connections on port 22"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.minecraft_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


