variable "application_id" {
  description = "The application id of the application to configure the federated identity credential for"
  type        = string
}
variable "display_name" {
  description = "display name of the application federated identity credential"
  type        = string
}
variable "description" {
  description = "description of the application federated identity credential"
  type        = string
  default     = null
}
variable "audience" {
  description = "audience of the application federated identity credential"
  type        = string
  default     = "api://AzureADTokenExchange"
}
variable "issuer" {
  description = "issuer of the application federated identity credential"
  type        = string
}
variable "subject" {
  description = "subject of the application federated identity credential"
  type        = string
}