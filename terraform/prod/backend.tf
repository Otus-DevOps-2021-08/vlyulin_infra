terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "vltf-state-bucket"
    region     = "ru-central1"
    key        = "prod/terraform.tfstate"
    shared_credentials_file = "./credentials.aws"

    skip_region_validation      = true
    skip_credentials_validation = true
   }
}
