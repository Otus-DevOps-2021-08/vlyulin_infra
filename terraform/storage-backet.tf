// Use keys to create bucket
resource "yandex_storage_bucket" "vltf_state_bucket" {
  access_key = var.access_key
  secret_key = var.secret_key
  bucket     = var.bucket_name
  force_destroy = "true"
}
