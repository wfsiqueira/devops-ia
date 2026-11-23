locals {
  name_prefix = "rds-${var.environment}-${var.project}-${var.name}"

  default_ports = {
    postgres = 5432
    mysql    = 3306
    mariadb  = 3306
  }
  port = coalesce(var.port, local.default_ports[var.engine])

  create_parameter_group = length(var.parameters) > 0
  create_monitoring_role = var.monitoring_interval > 0

  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project
  }
}

resource "aws_db_subnet_group" "this" {
  name       = local.name_prefix
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "db-subnet-group-${var.environment}-${var.project}-${var.name}"
  })
}

resource "aws_security_group" "this" {
  name        = "sg-${var.environment}-${var.project}-${var.name}-rds"
  description = "Acesso ao RDS ${local.name_prefix}"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "sg-${var.environment}-${var.project}-${var.name}-rds"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_security_groups" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = each.value
  from_port                    = local.port
  to_port                      = local.port
  ip_protocol                  = "tcp"
  description                  = "Acesso ao banco a partir de ${each.value}"

  tags = local.common_tags
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr_blocks" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value
  from_port         = local.port
  to_port           = local.port
  ip_protocol       = "tcp"
  description       = "Acesso ao banco a partir de ${each.value}"

  tags = local.common_tags
}

resource "aws_db_parameter_group" "this" {
  count = local.create_parameter_group ? 1 : 0

  name   = local.name_prefix
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(local.common_tags, { Name = local.name_prefix })

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = var.parameter_group_family != null
      error_message = "parameter_group_family é obrigatória quando parameters não for vazio."
    }
  }
}

resource "aws_iam_role" "monitoring" {
  count = local.create_monitoring_role ? 1 : 0

  name = "role-${var.environment}-${var.project}-${var.name}-rds-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  count = local.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "this" {
  identifier = local.name_prefix

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  port           = local.port

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_id

  db_name                     = var.db_name
  username                    = var.username
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  parameter_group_name = local.create_parameter_group ? aws_db_parameter_group.this[0].name : null

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  copy_tags_to_snapshot   = true

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${local.name_prefix}-final"

  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = local.create_monitoring_role ? aws_iam_role.monitoring[0].arn : null

  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  tags = merge(local.common_tags, { Name = local.name_prefix })

  lifecycle {
    precondition {
      condition     = var.max_allocated_storage == 0 || var.max_allocated_storage > var.allocated_storage
      error_message = "max_allocated_storage deve ser maior que allocated_storage ou 0 para desabilitar o autoscaling."
    }
  }
}
