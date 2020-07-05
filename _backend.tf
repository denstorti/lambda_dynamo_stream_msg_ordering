terraform {
  backend "s3" {
    bucket = "labs-serverless"
    key    = "state.tfstate"
    region = "ap-southeast-2"
  }
}