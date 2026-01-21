data "azuread_client_config" "current" {}
data "azuread_application_published_app_ids" "well_known" {}

data "azuread_group" "application_owners" {
  for_each = {
    for key, owner in var.application_owners : key => owner
    if owner.group_display_name != null
  }

  display_name     = each.value.group_display_name
  security_enabled = each.value.is_group_security_enabled
  mail_enabled     = each.value.is_group_mail_enabled
}

data "azuread_user" "application_owners" {
  for_each = {
    for key, owner in var.application_owners : key => owner
    if owner.user_principal_name != null
  }
  user_principal_name = each.value.user_principal_name
}

data "azuread_service_principal" "well_known" {
  for_each = {
    for key, api_permission in var.api_permissions : key => api_permission
    if api_permission.well_known_app_id_name != null
  }

  client_id = data.azuread_application_published_app_ids.well_known.result[each.value.well_known_app_id_name]
}

data "azuread_service_principal" "existing" {
  for_each = {
    for key, api_permission in var.api_permissions : key => api_permission
    if api_permission.service_principal_name != null
  }

  display_name = each.value.service_principal_name
}

data "azuread_group" "service_principal_owners" {
  for_each = {
    for key, owner in var.service_principal_owners : key => owner
    if owner.group_display_name != null
  }

  display_name     = each.value.group_display_name
  security_enabled = each.value.is_group_security_enabled
  mail_enabled     = each.value.is_group_mail_enabled
}

data "azuread_user" "service_principal_owners" {
  for_each = {
    for key, owner in var.service_principal_owners : key => owner
    if owner.user_principal_name != null
  }
  user_principal_name = each.value.user_principal_name
}