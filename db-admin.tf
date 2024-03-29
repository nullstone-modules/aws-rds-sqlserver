module "db_admin" {
  source  = "api.nullstone.io/nullstone/aws-mss-db-admin/aws"

  name     = local.resource_name
  tags     = local.tags
  host     = aws_db_instance.this.address
  username = aws_db_instance.this.username
  password = random_password.this.result

  network = {
    vpc_id               = local.vpc_id
    pg_security_group_id = aws_security_group.this.id
    security_group_ids   = []
    subnet_ids           = local.private_subnet_ids
  }
}
