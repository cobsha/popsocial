module "vpc" {
  
  source = "../module/VPC"
  vpc_cidr = var.cidr
  project = var.project
  region = var.region[0]
  env = var.env
}

module "vpc_replica" {
  
  providers = { aws = aws.use2 }
  source = "../module/VPC"
  vpc_cidr = var.cidr
  project = var.project
  region = var.region[1]
  env = var.env
}

resource "aws_db_subnet_group" "main" {

  name       = "${var.project}-${var.env}-sg"
  subnet_ids = [module.vpc.private_subnet.id, module.vpc.public_subnet.id]
  tags = {
    Name = "${var.project}-${var.env}-sg"
    project = var.project
    env = var.env
  }
}

resource "aws_rds_cluster" "main" {

  apply_immediately = true  
  db_subnet_group_name = aws_db_subnet_group.main.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_pg.name
  cluster_identifier_prefix      = "${var.project}-"
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = var.db_name
  master_username         = var.master_usr
  master_password         = var.master_pswd
  skip_final_snapshot  = true
  tags = {
    Name = "${var.project}-${var.env}-rds"
    project = var.project
    env = var.env
  }
  lifecycle {
    
    create_before_destroy = true
  }
  depends_on = [ aws_rds_cluster_parameter_group.cluster_pg ]
}

resource "aws_rds_cluster_parameter_group" "cluster_pg" {

    family      = "aurora-mysql5.7"
    name        = "aurora-mysql5"

    parameter {
        apply_method = "pending-reboot"
        name         = "binlog_format"
        value        = "MIXED"
    }
    tags = {
    Name = "${var.project}-${var.env}-pg"
    project = var.project
    env = var.env
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {

  count = 1
  identifier_prefix         = "${var.project}-${count.index+1}-"
  apply_immediately = true
  db_subnet_group_name = aws_db_subnet_group.main.name
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.db_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
  availability_zone = module.vpc.private_subnet.availability_zone
  tags = {
    Name = "${var.project}-${var.env}-rds"
    project = var.project
    env = var.env
  }
  lifecycle {
    create_before_destroy = true
  }
}

#######Replica######

resource "aws_db_subnet_group" "replica_sg" {

  provider = aws.use2
  name       = "main-replica"
  subnet_ids = [ module.vpc_replica.private_subnet.id, module.vpc_replica.public_subnet.id ]

  tags = {
    Name = "${var.project}-${var.env}-subnetgroup"
    project = var.project
    env = var.env
  }
}

resource "aws_rds_cluster" "aurora_cluster_replica" {

  provider = aws.use2
  cluster_identifier_prefix      = "${var.project}-"
  db_subnet_group_name                = aws_db_subnet_group.replica_sg.name
  engine                              = var.engine
  engine_version                      = var.engine_version
  replication_source_identifier       = aws_rds_cluster.main.arn
  skip_final_snapshot                 = true
  tags = {
  Name = "${var.project}-${var.env}-rds"
  project = var.project
  env = var.env
}
  depends_on = [ aws_rds_cluster_instance.cluster_instances ]
}

resource "aws_rds_cluster_instance" "replica_instance" {

  provider = aws.use2
  availability_zone                     = module.vpc_replica.private_subnet.availability_zone
  cluster_identifier                    = aws_rds_cluster.aurora_cluster_replica.id
  copy_tags_to_snapshot                 = false
  db_subnet_group_name                  = aws_db_subnet_group.replica_sg.name
  engine                                = var.engine
  engine_version                        = var.engine_version
  identifier_prefix = "${var.project}-"
  instance_class                        = var.db_class
  lifecycle {
    create_before_destroy = true
  }
  tags = {
  Name = "${var.project}-${var.env}-subnetgroup"
  project = var.project
  env = var.env
  }
}