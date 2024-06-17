variable "compartment_id" {
  type        = string
  description = "The Existing compartment where all the resources will get deploy"
}
variable "Label" {
  type        = string
  description = "A unique label that gets prepended to all resources created by the stack."
}
variable "idcs_endpoint" {
  type        = string
  description = "Domain URL."
}
variable "log_path" {
  type        = string
  description = "logging path from the server which needs to be monitored(Note: starts with /)"
}
variable "tenancy_ocid" {}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}
variable "private_key_password" {
  default = ""
}
variable "region" {}
