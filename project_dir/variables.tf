variable "region" {
  
  type = list
  default = ["us-east-1", "us-east-2"]
}

variable "project" {

    default = "popsocial"
}

variable "env" {

    default = "prod"
}

variable "cidr" {

    default = "172.16.0.0/16"
}

variable "engine" {
  
  default = "aurora-mysql"
}

variable "engine_version" {
  
  default = "5.7.mysql_aurora.2.07.2"
}

variable "db_name" {
  
  default = "mydb"
}

variable "master_usr" {
  
  default = "popsocial"
}

variable "master_pswd" {
  
  default = "Popsocial2023"
}

variable "db_class" {
  
  default = "db.r5.large"
}