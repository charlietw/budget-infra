variable "stack_identifier" {
  description = "Value of stack identifier to append to all resources"
  type        = string
}

variable "domain_name" {
  description = "Budget domain name"
  type        = string
}

variable "hosted_zone_id" {
  description = "ID of the hosted zone created for the apex domain"
  type        = string
}

variable "gcp_client_id" {
  description = "Client ID supplied for oauth2"
  type        = string
}

variable "gcp_client_secret" {
  description = "Client secret supplied for oauth2"
  type        = string
}

variable "allowed_email" {
  description = "Email allowed to access oauth"
  type        = string
}
