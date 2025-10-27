############################################
# Subnet Group for RDS
############################################

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.project_name}-rds-subnet-group"
  description = "Subnet group for RDS instance"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

############################################
# MySQL RDS Instance
############################################

resource "aws_db_instance" "rds_instance" {
  identifier        = "${var.project_name}-rds"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20 # 20 GB
  multi_az          = true
  username          = "admin"
  password          = random_password.db_password.result
  db_name           = "countries"
  port              = 3306
  skip_final_snapshot        = true # to avoid snapshot cost on destroy
  deletion_protection        = false


  backup_retention_period    = 7
  backup_window              = "03:00-04:00"
  copy_tags_to_snapshot      = true
  auto_minor_version_upgrade = true
  
  publicly_accessible        = false
  
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "${var.project_name}-rds-instance"
  }
}

############################################
# Random Password Generator
############################################

resource "random_password" "db_password" {
  length  = 16
  special = true
}

############################################
# Secrets Manager Entry for RDS credentials 
############################################

resource "aws_secretsmanager_secret" "rds_secret" {
  name        = "${var.project_name}-rds-credentials"
  description = "RDS MySQL credentials stored securely"
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id = aws_secretsmanager_secret.rds_secret.id

  secret_string = jsonencode({
    username = aws_db_instance.rds_instance.username
    password = random_password.db_password.result
    engine   = aws_db_instance.rds_instance.engine
    host     = aws_db_instance.rds_instance.address
    port     = 3306
    dbname   = aws_db_instance.rds_instance.db_name
  })
}