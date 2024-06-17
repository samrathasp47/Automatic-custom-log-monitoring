data "oci_identity_regions" "these" {}

data "oci_identity_region_subscriptions" "these" {
  tenancy_id = var.tenancy_ocid
}
data "oci_identity_tenancy" "this" {
  tenancy_id = var.tenancy_ocid
}