terraform {
  backend "s3" {
    bucket = "malferov.segregation"
    key    = "terraform.tfstate"
    region = "us-west-2"
    shared_credentials_file = ".key/backend.credentials"
  }
}
