variable service_account_key_file {
  description = "key .json"
}
variable cloud_id {
  description = "Cloud"
}
variable "zones" {
  type = map
  default = {
    "a" = "ru-central1-a"
    "b" = "ru-central1-b"
    "c" = "ru-central1-c"
  }
}
variable zone {
  description = "Selected zone"
  type        = string
  default     = "a"
}
variable folder_id {
  description = "Folder"
}
variable access_key {
  description = "key id"
}
variable secret_key {
  description = "secret key"
}
variable bucket_name {
  description = "bucket name"
}
