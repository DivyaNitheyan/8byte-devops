# terraform {
#   backend "s3" {
#     bucket = "8byte-devops-terraform-state"
#     key    = "terraform.tfstate"
#     region = "us-east-1"
#      use_lockfile = true
#   }
# }