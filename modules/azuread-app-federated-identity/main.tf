resource "azuread_application_federated_identity_credential" "this" {
  application_id = var.application_id
  display_name   = "fid-${var.display_name}"
  description    = var.description
  audiences      = [var.audience]
  issuer         = var.issuer
  subject        = var.subject
}