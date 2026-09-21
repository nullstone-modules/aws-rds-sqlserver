resource "aws_db_instance" "this" {
  identifier = local.resource_name

  db_subnet_group_name        = aws_db_subnet_group.this.name
  parameter_group_name        = aws_db_parameter_group.this.name
  engine                      = local.engine
  engine_version              = local.versions_map[var.sqlserver_version]
  allow_major_version_upgrade = true
  instance_class              = var.instance_class
  multi_az                    = var.high_availability
  allocated_storage           = var.allocated_storage
  storage_encrypted           = true
  storage_type                = "gp2"
  port                        = local.port
  vpc_security_group_ids      = [aws_security_group.this.id]
  tags                        = local.tags
  publicly_accessible         = var.enable_public_access
  license_model               = "license-included"

  username = replace(data.ns_workspace.this.block_ref, "-", "_")
  password = random_password.this.result

  // final_snapshot_identifier is unique to when an instance is launched
  // This prevents repeated launch+destroy from creating the same final snapshot and erroring
  // Changes to the name are ignored so it doesn't keep invalidating the instance
  final_snapshot_identifier = "${local.resource_name}-${replace(timestamp(), ":", "-")}"

  backup_retention_period = var.backup_retention_period
  backup_window           = "02:00-03:00"
  copy_tags_to_snapshot   = true

  lifecycle {
    ignore_changes = [username, final_snapshot_identifier]
  }
}

resource "aws_db_subnet_group" "this" {
  name        = local.resource_name
  description = "SqlServer db subnet group for sqlserver cluster"
  subnet_ids  = var.enable_public_access ? local.public_subnet_ids : local.private_subnet_ids
  tags        = local.tags
}

locals {
  engine                = "sqlserver-${var.sqlserver_edition}"
  major_version         = "${var.sqlserver_version}.0"
  enforce_ssl_parameter = var.enforce_ssl ? tomap({ "rds.force_ssl" = 1 }) : tomap({})
  db_parameters         = merge(local.enforce_ssl_parameter)
  // Can only contain alphanumeric and hypen characters
  param_group_name      = "${local.resource_name}-sqlserver${replace(var.sqlserver_version, ".", "-")}"
}

resource "aws_db_parameter_group" "this" {
  name        = local.param_group_name
  family      = "sqlserver-${var.sqlserver_edition}-${local.major_version}"
  tags        = local.tags
  description = "SqlServer for ${local.block_name} (${local.env_name})"

  // When sqlserver version changes, we need to create a new one that attaches to the db
  //   because we can't destroy a parameter group that's in use
  lifecycle {
    create_before_destroy = true
  }

  dynamic "parameter" {
    for_each = local.db_parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }
}
