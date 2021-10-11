
// Create SA
resource "yandex_iam_service_account" "terraform" {
  folder_id = var.folder_id
  name      = "terraform"
}
