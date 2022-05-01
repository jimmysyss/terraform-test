resource "aws_security_group" "rds" {
  name = "${var.name}-${var.env}-rds-sg"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs.id, aws_security_group.fargate.id]
  }
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.name}-${var.env}-rds"

  engine               = "postgres"
  engine_version       = "14.1" 
  major_engine_version = "14"
  family               = "postgres14"   # DB parameter group
  instance_class       = "db.t3.micro"  # Only T3 Micro supports storage encryption
  allocated_storage    = var.db_allocated_storage

  #DBName must begin with a letter and contain only alphanumeric characters.
  db_name  = "${var.name}${var.env}db"
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = var.db_maintenance_window
  backup_window      = var.db_backup_window

  # disable backups to create DB faster
  backup_retention_period = var.db_backup_retention_period

  #subnet_ids = module.vpc.database_subnets
  db_subnet_group_name = module.vpc.database_subnet_group

  multi_az = length(regexall("stage", var.env)) > 0 || length(regexall("prod", var.env)) > 0
  storage_encrypted = true

  # Disable default master password generation
  create_random_password = false
}

