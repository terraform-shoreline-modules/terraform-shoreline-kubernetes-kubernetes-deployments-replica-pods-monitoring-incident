resource "shoreline_notebook" "kubernetes_deployments_replica_pods_monitoring_incident" {
  name       = "kubernetes_deployments_replica_pods_monitoring_incident"
  data       = file("${path.module}/data/kubernetes_deployments_replica_pods_monitoring_incident.json")
  depends_on = [shoreline_action.invoke_deployment_status_check,shoreline_action.invoke_deployment_scaling_check,shoreline_action.invoke_deployment_checker,shoreline_action.invoke_restart_deployment]
}

resource "shoreline_file" "deployment_status_check" {
  name             = "deployment_status_check"
  input_file       = "${path.module}/data/deployment_status_check.sh"
  md5              = filemd5("${path.module}/data/deployment_status_check.sh")
  description      = "A recent deployment or upgrade of applications on Kubernetes might have caused the pods to go down."
  destination_path = "/agent/scripts/deployment_status_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "deployment_scaling_check" {
  name             = "deployment_scaling_check"
  input_file       = "${path.module}/data/deployment_scaling_check.sh"
  md5              = filemd5("${path.module}/data/deployment_scaling_check.sh")
  description      = "There might be a scaling issue where the desired number of replica pods is not being met due to resource constraints or misconfiguration."
  destination_path = "/agent/scripts/deployment_scaling_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "deployment_checker" {
  name             = "deployment_checker"
  input_file       = "${path.module}/data/deployment_checker.sh"
  md5              = filemd5("${path.module}/data/deployment_checker.sh")
  description      = "Check if any recent changes were made to the deployment that could have caused the issue. Verify if the replicas are scaled down or if there is a problem with the deployment configuration."
  destination_path = "/agent/scripts/deployment_checker.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "restart_deployment" {
  name             = "restart_deployment"
  input_file       = "${path.module}/data/restart_deployment.sh"
  md5              = filemd5("${path.module}/data/restart_deployment.sh")
  description      = "."
  destination_path = "/agent/scripts/restart_deployment.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_deployment_status_check" {
  name        = "invoke_deployment_status_check"
  description = "A recent deployment or upgrade of applications on Kubernetes might have caused the pods to go down."
  command     = "`chmod +x /agent/scripts/deployment_status_check.sh && /agent/scripts/deployment_status_check.sh`"
  params      = ["DEPLOYMENT_NAME","NAMESPACE"]
  file_deps   = ["deployment_status_check"]
  enabled     = true
  depends_on  = [shoreline_file.deployment_status_check]
}

resource "shoreline_action" "invoke_deployment_scaling_check" {
  name        = "invoke_deployment_scaling_check"
  description = "There might be a scaling issue where the desired number of replica pods is not being met due to resource constraints or misconfiguration."
  command     = "`chmod +x /agent/scripts/deployment_scaling_check.sh && /agent/scripts/deployment_scaling_check.sh`"
  params      = ["DEPLOYMENT_NAME","CONTEXT_NAME"]
  file_deps   = ["deployment_scaling_check"]
  enabled     = true
  depends_on  = [shoreline_file.deployment_scaling_check]
}

resource "shoreline_action" "invoke_deployment_checker" {
  name        = "invoke_deployment_checker"
  description = "Check if any recent changes were made to the deployment that could have caused the issue. Verify if the replicas are scaled down or if there is a problem with the deployment configuration."
  command     = "`chmod +x /agent/scripts/deployment_checker.sh && /agent/scripts/deployment_checker.sh`"
  params      = ["DEPLOYMENT_NAME"]
  file_deps   = ["deployment_checker"]
  enabled     = true
  depends_on  = [shoreline_file.deployment_checker]
}

resource "shoreline_action" "invoke_restart_deployment" {
  name        = "invoke_restart_deployment"
  description = "."
  command     = "`chmod +x /agent/scripts/restart_deployment.sh && /agent/scripts/restart_deployment.sh`"
  params      = ["DEPLOYMENT_NAME","NAMESPACE"]
  file_deps   = ["restart_deployment"]
  enabled     = true
  depends_on  = [shoreline_file.restart_deployment]
}

