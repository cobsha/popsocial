provider "aws" {
  
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

provider "aws" {

  alias = "use2"
  region     = "us-east-2"
  access_key = ""
  secret_key = ""
}