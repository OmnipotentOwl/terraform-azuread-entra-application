variable "app_display_name" {
  type        = string
  description = "The display name of the application"
}
variable "app_description" {
  type        = string
  description = "The description of the application, as shown to end users."
  default     = null
}
variable "sign_in_audience" {
  type        = string
  description = "The sign in audience of the application"
}
variable "implicit_id_token_issuance_enabled" {
  type        = bool
  description = "Whether to enable implicit ID token issuance for the application"
  default     = false
}
variable "implicit_access_token_issuance_enabled" {
  type        = bool
  description = "Whether to enable implicit access token issuance for the application"
  default     = false
}
variable "homepage_url" {
  type        = string
  description = "Home page or landing page of the application."
  default     = null
}
variable "logout_url" {
  type        = string
  description = "The URL that will be used by Microsoft's authorization service to sign out a user using front-channel, back-channel or SAML logout protocols."
  default     = null
}
variable "marketing_url" {
  type        = string
  description = "The URL of the marketing page for the application."
  default     = null
}
variable "privacy_statement_url" {
  type        = string
  description = "The URL of the privacy statement for the application."
  default     = null
}
variable "support_url" {
  type        = string
  description = "The URL of the support page for the application."
  default     = null
}
variable "terms_of_service_url" {
  type        = string
  description = "The URL of the terms of service statement for the application."
  default     = null
}
variable "enable_fallback_public_client" {
  type        = bool
  description = "Whether to enable the fallback public client"
  default     = false
}
variable "redirect_uris" {
  type = object({
    public_client = optional(object({
      built_in                 = bool
      additional_redirect_uris = optional(set(string), [])
    }), null)
    spa = optional(object({
      redirect_uris = optional(set(string), [])
    }), null)
    web = optional(object({
      redirect_uris = optional(set(string), [])
    }), null)
  })
  description = "The redirect URIs to associate with the application"
  default = {
    public_client = null
    spa           = null
    web           = null
  }
}
#Refer to https://learn.microsoft.com/en-us/entra/identity-platform/reference-app-manifest#identifieruris-attribute for more information
variable "additional_identifier_uris" {
  type        = set(string)
  description = "Additional identifier URIs to associate with the application"
  default     = []
}
variable "known_client_app_ids" {
  type        = set(string)
  description = "Known client application IDs to associate with the application"
  default     = []
}
variable "app_roles" {
  type = map(object({
    allowed_member_types = list(string)
    description          = string
    display_name         = string
    value                = string
  }))
  description = "The roles to create for the application. Roles are intended to be used for admin consent scenarios and are for headless applications or admins only."
  default     = {}
}
variable "app_role_and_scopes_permissions" {
  type = map(object({
    allowed_member_types       = list(string)
    admin_consent_description  = string
    admin_consent_display_name = string
    type                       = string
    user_consent_description   = string
    user_consent_display_name  = string
    value                      = string
  }))
  description = "The roles and scopes where they are the same value to support permissions for applications and users to consent to."
  default     = {}
}
variable "permission_scopes" {
  type = map(object({
    admin_consent_description  = string
    admin_consent_display_name = string
    type                       = string
    user_consent_description   = string
    user_consent_display_name  = string
    value                      = string
  }))
  description = "The permission scopes to create for the application. Permission scopes are intended to be used for user consent scenarios and are for interactive applications only."
  default     = {}
}
variable "application_owners" {
  type = map(object({
    object_id                 = optional(string, null)
    group_display_name        = optional(string, null)
    is_group_security_enabled = optional(bool, false)
    is_group_mail_enabled     = optional(bool, false)
    user_principal_name       = optional(string, null)
  }))
  description = "The owners of the application registration. Owners are granted limited administrative permissions to the application registration."
  default     = {}
}
variable "service_principal_owners" {
  type = map(object({
    object_id                 = optional(string, null)
    group_display_name        = optional(string, null)
    is_group_security_enabled = optional(bool, false)
    is_group_mail_enabled     = optional(bool, false)
    user_principal_name       = optional(string, null)
  }))
  description = "The owners of the service principal. Owners are granted limited administrative permissions to the service principal for the app."
  default     = {}
}
variable "api_permissions" {
  type = map(object({
    well_known_app_id_name = optional(string)
    service_principal_name = optional(string)
    service_principal_key  = optional(string)
    role_ids               = optional(list(string), [])
    role_values            = optional(list(string), [])
    scope_ids              = optional(list(string), [])
    scope_values           = optional(list(string), [])
  }))
  default = {}
}
variable "client_secrets" {
  type = map(object({
    display_name = optional(string)
    start_date   = optional(string, null)
    end_date     = optional(string, null)
    automatic_rotation_configuration = optional(object({
      rotation_days   = optional(number, 10)
      rotation_months = optional(number, 11)
      rotation_years  = optional(number, 1)
    }), null)
  }))
  description = "The client secrets to create for the application. Client secrets are used by applications to prove their identity when calling APIs."
  default     = {}
}

variable "federated_identity_credentials" {
  type = map(object({
    display_name = string
    description  = optional(string, null)
    issuer       = string
    subject      = string
  }))
}

variable "optional_claims" {
  type = map(object({
    token_type            = string
    name                  = string
    essential             = optional(bool, false)
    source                = optional(string, null)
    additional_properties = optional(list(string), null)
  }))
  description = "The optional claims to configure for the application. Optional claims are used to specify the claims that are not included in the token by default."
  default     = null
}

variable "service_principals" {
  type = map(object({
    client_id                   = optional(string, null)
    app_role_ids                = optional(map(string), {})
    oauth2_permission_scope_ids = optional(map(string), {})
  }))
  description = "A map of the service principals to use for API permissions. Service principals are used to grant permissions to applications."
  default     = {}
}