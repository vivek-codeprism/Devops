terraform {
  backend "s3" {
    bucket = "malferov.environment"
    key    = "terraform.tfstate"
    region = "us-west-2"
    shared_credentials_file = ".key/backend.credentials"
  }
}
