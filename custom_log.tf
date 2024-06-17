resource "oci_identity_domains_dynamic_resource_group" "dynamic_group" {
    display_name   = "${var.Label}_dynamicgroup"
	idcs_endpoint  = var.idcs_endpoint
	schemas 	   = ["urn:ietf:params:scim:schemas:oracle:idcs:DynamicResourceGroup"]
    #compartment_id = "ocid1.tenancy.oc1..aaaaaaaakxcj247rl2tyoc6bsmexmcnku6x6ze4p55lqfobmww2rnrjbksiq"
    description    = "for including virtual machines to this dynamic group"
    matching_rule  = "Any {instance.compartment.id = 'ocid1.compartment.oc1..aaaaaaaapjdzahspbgldg4d7vwtty47hywkaqu3372jj2cytb7chlaiqmgha'}"
}
resource "oci_identity_policy" "custom_log_policy" {
    #depends_on = [oci_identity_dynamic_group]
    #Required
    compartment_id = var.tenancy_ocid
    description = "dynamicgrouppolicy"
    name = "${var.Label}_log_policy"
    statements = ["Allow dynamic-group custom_log_dynamicgroup to read metrics in tenancy"]
}
/*resource "oci_identity_domains_policy" "custom_log_policy" {
    #depends_on = [oci_identity_domains_dynamic_resource_group]
    #Required
	idcs_endpoint  = "https://idcs-ff3532e3a9ba4bd7887f5cf49e2ae425.identity.oraclecloud.com:443"
	schemas = ["urn:ietf:params:scim:schemas:oracle:idcs:Policy"]
    name = "${var.Label}_dynpolicy"
	description = "for this dynamic group to grant Virtual Machines to allow the push of logs so the Logging Service can source them"
    #rules = ["Allow dynamic-group custom_log_dynamicgroup to read metrics in tenancy"]
	policy_type {
        #Required
        value = "IdentityProvider"
    }
	rules {
        #Required
        sequence = 1
        value = "Allow dynamic-group custom_log_dynamicgroup to read metrics in tenancy"
    }
}*/
resource "oci_logging_log_group" "custom_log_group" {
    #Required
    compartment_id = var.compartment_id
    display_name = "${var.Label}_log_group"
}
resource "oci_logging_log" "oci_logging_log"{   
      display_name  = "${var.Label}_logs"
      log_group_id  = "${oci_logging_log_group.custom_log_group.id}"
      is_enabled     = true
      log_type = "CUSTOM"
}
resource "oci_logging_unified_agent_configuration" "generated_oci_logging_unified_agent_configuration" {
	compartment_id = var.compartment_id
	description = "specify which hosts you want to collect logs from, log inputs, and log destination settings"
	display_name = "${var.Label}_log_agent_config"
	group_association {
		group_list = ["${oci_identity_domains_dynamic_resource_group.dynamic_group.id}"]
	}
	is_enabled = "true"
	service_configuration {
		configuration_type = "LOGGING"
		destination {
			log_object_id = "${oci_logging_log.oci_logging_log.id}"
		}
		sources {
			name = "apache_error_input"
			parser {
				parser_type = "APACHE_ERROR"
			}
			paths = ["${var.log_path}"]
			source_type = "LOG_TAIL"
		}
	}
}
resource "oci_ons_notification_topic" "custom_log_notification_topic" {
    #Required
    compartment_id = var.compartment_id
    name = "${var.Label}_topic"
}
resource "oci_ons_subscription" "custom_log_alert_subscription" {
    #Required
    compartment_id = var.compartment_id
    endpoint = "vishak.chittuvalapil@oracle.com"
    protocol = "EMAIL"
    topic_id = "${oci_ons_notification_topic.custom_log_notification_topic.id}"
}
resource "oci_sch_service_connector" "custom_log_service_connector" {
  compartment_id = var.compartment_id
    display_name = "${var.Label}_SCH"
    source {
        #Required
        kind = "logging"
    
    log_sources {

      #Optional
      compartment_id = var.compartment_id
      log_group_id = "${oci_logging_log_group.custom_log_group.id}"
      log_id = "${oci_logging_log.oci_logging_log.id}"
    }
	}
	target {
        #Required
        kind = "notifications"
		compartment_id = var.compartment_id
		topic_id = "${oci_ons_notification_topic.custom_log_notification_topic.id}"
    }
} 