output "id" {
  description = "The ID of the application registration"
  value       = azuread_application_registration.this.id
}
output "display_name" {
  description = "The display name of the application registration"
  value       = azuread_application_registration.this.display_name
}
output "client_id" {
  description = "The client ID of the application registration"
  value       = azuread_application_registration.this.client_id
}
output "object_id" {
  description = "The object ID of the service principal for the application registration"
  value       = azuread_service_principal.this.object_id
}
output "client_secrets" {
  description = "The client secrets of the application registration"
  value       = merge(azuread_application_password.static, azuread_application_password.dynamic)
  sensitive   = true
}
output "app_role_ids" {
  description = "The app role IDs of the application registration"
  value       = azuread_service_principal.this.app_role_ids
  sensitive   = false
}
output "oauth2_permission_scope_ids" {
  description = "The OAuth2 permission scope IDs of the application registration"
  value       = azuread_service_principal.this.oauth2_permission_scope_ids
  sensitive   = false
}