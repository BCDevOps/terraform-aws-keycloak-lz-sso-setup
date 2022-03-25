variable "aws_saml_idp_name" {
  type        = string
  description = "Name for Keycloak IDP that will be created in AWS"
  default     = "BCGovKeyCloak"
}

variable "kc_realm" {
  description = "KeyCloak realm where terraform client has been created and where users/groups to be created/manipulated exist."
  type        = string
}

variable "kc_iam_auth_client_id" {
  description = "Client ID of client where KC roles corresponding to AWS roles will be created."
  type        = string
}

variable "kc_base_url" {
  description = "Base URL of KeyCloak instance to interact with."
  type        = string
}

variable "account_name" {
  description = "Name to identify the account."
  type        = string
}

variable "account_roles" {
  description = "Roles and associated policies for an account."
  type        = map(string)
}

variable "trusted_login_sources" {
  description = "A list of one or more URLs from which login is expected and permitted."
  default     = ["https://signin.aws.amazon.com/saml"]
  type        = list(string)
}
