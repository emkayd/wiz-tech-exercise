########################################
# MONGODB SECURITY GROUP (INTENTIONAL FLAWS)
########################################

resource "aws_security_group" "mongo_sg" {
  name        = "wiz-mongo-sg"
  description = "Insecure MongoDB SG (intentional flaws for exercise)"
  vpc_id      = aws_vpc.main.id

  # INTENTIONAL FLAW:
  # Allow SSH from anywhere
  ingress {
    description = "SSH from anywhere (bad)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # INTENTIONAL FLAW:
  # Allow MongoDB from anywhere
  ingress {
    description = "MongoDB from anywhere (bad)"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all egress (typical)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wiz-mongo-sg"
  }
}

########################################
# MONGODB EC2 INSTANCE (PUBLIC SUBNET)
########################################

resource "aws_instance" "mongo" {
  ami                         = var.mongo_ami_id
  instance_type               = var.mongo_instance_type
  subnet_id                   = aws_subnet.public_a.id # PUBLIC subnet (intentional)
  associate_public_ip_address = true                   # PUBLIC IP (intentional)
  vpc_security_group_ids      = [aws_security_group.mongo_sg.id]
  key_name                    = var.mongo_key_name

  tags = {
    Name = "wiz-mongo-db"
    Role = "mongo-db"
  }

  # (AMI is pre-baked with Mongo config from your previous work)
}

########################################
# OUTPUTS FOR MONGODB
########################################

output "mongo_public_ip" {
  description = "Public IPv4 address of MongoDB EC2 instance"
  value       = aws_instance.mongo.public_ip
}

output "mongo_private_ip" {
  description = "Private IPv4 address of MongoDB EC2 instance"
  value       = aws_instance.mongo.private_ip
}

output "mongo_security_group_id" {
  description = "Security Group ID for MongoDB instance"
  value       = aws_security_group.mongo_sg.id
}
