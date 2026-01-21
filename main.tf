resource "azuread_application_registration" "this" {
  display_name     = var.app_display_name
  description      = var.app_description
  sign_in_audience = var.sign_in_audience

  implicit_id_token_issuance_enabled     = var.implicit_id_token_issuance_enabled
  implicit_access_token_issuance_enabled = var.implicit_access_token_issuance_enabled

  homepage_url          = var.homepage_url
  logout_url            = var.logout_url
  marketing_url         = var.marketing_url
  privacy_statement_url = var.privacy_statement_url
  support_url           = var.support_url
  terms_of_service_url  = var.terms_of_service_url
}

resource "azuread_application_api_access" "well_known" {
  for_each = {
    for key, api_permission in var.api_permissions : key => api_permission
    if api_permission.well_known_app_id_name != null
  }

  application_id = azuread_application_registration.this.id
  api_client_id  = data.azuread_service_principal.well_known[each.key].client_id

  role_ids = concat(
    each.value.role_ids,
    [for v in each.value.role_values : data.azuread_service_principal.well_known[each.key].app_role_ids[v]]
  )
  scope_ids = concat(
    each.value.scope_ids,
    [for v in each.value.scope_values : data.azuread_service_principal.well_known[each.key].oauth2_permission_scope_ids[v]]
  )
}

resource "azuread_application_api_access" "existing" {
  for_each = {
    for key, api_permission in var.api_permissions : key => api_permission
    if api_permission.service_principal_name != null
  }

  application_id = azuread_application_registration.this.id
  api_client_id  = data.azuread_service_principal.existing[each.key].client_id

  role_ids = concat(
    each.value.role_ids,
    [for v in each.value.role_values : data.azuread_service_principal.existing[each.key].app_role_ids[v]]
  )

  scope_ids = concat(
    each.value.scope_ids,
    [for v in each.value.scope_values : data.azuread_service_principal.existing[each.key].oauth2_permission_scope_ids[v]]
  )
}
resource "azuread_application_api_access" "external" {
  for_each = {
    for key, api_permission in var.api_permissions : key => api_permission
    if api_permission.service_principal_key != null
  }

  application_id = azuread_application_registration.this.id
  api_client_id  = var.service_principals[each.value.service_principal_key].client_id

  role_ids = concat(
    each.value.role_ids,
    [for v in each.value.role_values : var.service_principals[each.value.service_principal_key].app_role_ids[v]]
  )

  scope_ids = concat(
    each.value.scope_ids,
    [for v in each.value.scope_values : var.service_principals[each.value.service_principal_key].oauth2_permission_scope_ids[v]]
  )
}

resource "azuread_application_known_clients" "this" {
  count = length(var.known_client_app_ids) > 0 ? 1 : 0

  application_id   = azuread_application_registration.this.id
  known_client_ids = var.known_client_app_ids
}

resource "azuread_application_identifier_uri" "default" {
  application_id = azuread_application_registration.this.id
  identifier_uri = "api://${azuread_application_registration.this.client_id}"
}

resource "azuread_application_identifier_uri" "additional" {
  for_each = toset(var.additional_identifier_uris)

  application_id = azuread_application_registration.this.id
  identifier_uri = each.value
}

resource "azuread_application_fallback_public_client" "this" {
  count          = var.enable_fallback_public_client ? 1 : 0
  application_id = azuread_application_registration.this.id
  enabled        = true
}

resource "azuread_application_redirect_uris" "public_client" {
  count = var.redirect_uris.public_client != null ? 1 : 0

  application_id = azuread_application_registration.this.id
  type           = "PublicClient"

  redirect_uris = toset(concat(var.redirect_uris.public_client.built_in ? local.public_client_built_in_redirect_uris : [], tolist(var.redirect_uris.public_client.additional_redirect_uris)))
}

resource "azuread_application_redirect_uris" "spa" {
  count = var.redirect_uris.spa != null ? 1 : 0

  application_id = azuread_application_registration.this.id
  type           = "SPA"

  redirect_uris = toset(var.redirect_uris.spa.redirect_uris)
}

resource "azuread_application_redirect_uris" "web" {
  count = var.redirect_uris.web != null ? 1 : 0

  application_id = azuread_application_registration.this.id
  type           = "Web"
  redirect_uris  = toset(var.redirect_uris.web.redirect_uris)
}

resource "random_uuid" "app_roles" {
  for_each = var.app_roles
  keepers = {
    app_id = azuread_application_registration.this.id
  }
}

resource "azuread_application_app_role" "this" {
  for_each = var.app_roles

  application_id = azuread_application_registration.this.id
  role_id        = random_uuid.app_roles[each.key].id

  allowed_member_types = each.value.allowed_member_types
  description          = each.value.description
  display_name         = each.value.display_name
  value                = each.value.value
}

resource "random_uuid" "permission_scopes" {
  for_each = var.permission_scopes
  keepers = {
    app_id = azuread_application_registration.this.id
  }
}

resource "azuread_application_permission_scope" "this" {
  for_each = var.permission_scopes

  application_id = azuread_application_registration.this.id
  scope_id       = random_uuid.permission_scopes[each.key].id

  admin_consent_description  = each.value.admin_consent_description
  admin_consent_display_name = each.value.admin_consent_display_name
  user_consent_description   = each.value.user_consent_description
  user_consent_display_name  = each.value.user_consent_display_name
  type                       = each.value.type
  value                      = each.value.value
}

resource "random_uuid" "app_role_and_scopes_permissions" {
  for_each = var.app_role_and_scopes_permissions
  keepers = {
    app_id = azuread_application_registration.this.id
  }
}
resource "azuread_application_app_role" "app_role_and_scopes_permissions" {
  for_each = var.app_role_and_scopes_permissions

  application_id = azuread_application_registration.this.id
  role_id        = random_uuid.app_role_and_scopes_permissions[each.key].id

  allowed_member_types = each.value.allowed_member_types
  description          = each.value.admin_consent_description
  display_name         = each.value.admin_consent_display_name
  value                = each.value.value
}
resource "azuread_application_permission_scope" "app_role_and_scopes_permissions" {
  for_each = var.app_role_and_scopes_permissions

  application_id = azuread_application_registration.this.id
  scope_id       = random_uuid.app_role_and_scopes_permissions[each.key].id

  admin_consent_description  = each.value.admin_consent_description
  admin_consent_display_name = each.value.admin_consent_display_name
  user_consent_description   = each.value.user_consent_description
  user_consent_display_name  = each.value.user_consent_display_name
  type                       = each.value.type
  value                      = each.value.value
}

resource "azuread_application_owner" "this" {
  application_id  = azuread_application_registration.this.id
  owner_object_id = data.azuread_client_config.current.object_id
}

resource "azuread_application_owner" "object_id" {
  for_each = {
    for key, owner in var.application_owners : key => owner
    if owner.object_id != null
  }

  application_id  = azuread_application_registration.this.id
  owner_object_id = each.value.object_id
}

resource "azuread_application_owner" "groups" {
  for_each = {
    for key, owner in var.application_owners : key => owner
    if owner.group_display_name != null
  }

  application_id  = azuread_application_registration.this.id
  owner_object_id = data.azuread_group.application_owners[each.key].id
}

resource "azuread_application_owner" "users" {
  for_each = {
    for key, owner in var.application_owners : key => owner
    if owner.user_principal_name != null
  }

  application_id  = azuread_application_registration.this.id
  owner_object_id = data.azuread_user.application_owners[each.key].id
}

resource "time_rotating" "client_secrets" {
  for_each = {
    for key, client_secret in var.client_secrets : key => client_secret
    if client_secret.start_date == null && client_secret.end_date == null
  }

  rotation_days   = each.value.automatic_rotation_configuration.rotation_days
  rotation_months = each.value.automatic_rotation_configuration.rotation_months
  rotation_years  = each.value.automatic_rotation_configuration.rotation_years

  triggers = {
    application_id = azuread_application_registration.this.id
  }
}
resource "azuread_application_password" "static" {
  for_each = {
    for key, client_secret in var.client_secrets : key => client_secret
    if client_secret.start_date != null || client_secret.end_date != null
  }

  application_id = azuread_application_registration.this.id
  display_name   = each.value.display_name
  start_date     = each.value.start_date
  end_date       = each.value.end_date
}
resource "azuread_application_password" "dynamic" {
  for_each = {
    for key, client_secret in var.client_secrets : key => client_secret
    if client_secret.start_date == null && client_secret.end_date == null
  }

  application_id = azuread_application_registration.this.id
  display_name   = each.value.display_name
  rotate_when_changed = {
    rotation = time_rotating.client_secrets[each.key].id
  }
}

module "federated_identity_credential" {
  source   = "./modules/azuread-app-federated-identity"
  for_each = var.federated_identity_credentials

  application_id = azuread_application_registration.this.id
  display_name   = each.value.display_name
  description    = each.value.description
  issuer         = each.value.issuer
  subject        = each.value.subject
}

resource "azuread_service_principal" "this" {
  client_id                    = azuread_application_registration.this.client_id
  app_role_assignment_required = false
  owners = toset(concat(
    [data.azuread_client_config.current.object_id],
    [for key, owner in var.service_principal_owners : owner.object_id if owner.object_id != null],
    [for key, owner in var.service_principal_owners : data.azuread_group.service_principal_owners[key].id if owner.group_display_name != null],
    [for key, owner in var.service_principal_owners : data.azuread_user.service_principal_owners[key].id if owner.user_principal_name != null]
  ))
}

resource "azuread_application_optional_claims" "this" {
  count          = var.optional_claims != null && length(var.optional_claims) > 0 ? 1 : 0
  application_id = azuread_application_registration.this.id

  dynamic "id_token" {
    for_each = { for k, v in var.optional_claims : k => v if v.token_type == "id_token" }
    content {
      name                  = id_token.value.name
      source                = id_token.value.source
      essential             = id_token.value.essential
      additional_properties = id_token.value.additional_properties
    }
  }

  dynamic "access_token" {
    for_each = { for k, v in var.optional_claims : k => v if v.token_type == "access_token" }
    content {
      name                  = access_token.value.name
      source                = access_token.value.source
      essential             = access_token.value.essential
      additional_properties = access_token.value.additional_properties
    }
  }

  dynamic "saml2_token" {
    for_each = { for k, v in var.optional_claims : k => v if v.token_type == "saml2_token" }
    content {
      name                  = saml2_token.value.name
      source                = saml2_token.value.source
      essential             = saml2_token.value.essential
      additional_properties = saml2_token.value.additional_properties
    }
  }
}