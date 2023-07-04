# output "pub_subnet" {
#     value = module.vpc.public_subnet.id
# }

# output "priv_subnet" {
#     value = module.vpc.private_subnet.id
# }

# output "pub_subnet_replica" {
#     value = module.vpc_replica.public_subnet.id
# }

# output "priv_subnet_replica" {
#     value = module.vpc_replica.private_subnet.id
# }

output "rds_main_endpoint" {
  
  value = aws_rds_cluster.main.endpoint
}

output "rds_main_db_name" {
  
  value = aws_rds_cluster.main.database_name
}

output "rds_main_port" {
  
  value = aws_rds_cluster.main.port
}

output "rds_replica_endpoint" {
  
  value = aws_rds_cluster.aurora_cluster_replica.endpoint
}

output "rds_replica_db_name" {
  
  value = aws_rds_cluster.aurora_cluster_replica.database_name
}

output "rds_mreplica_port" {
  
  value = aws_rds_cluster.aurora_cluster_replica.port
}