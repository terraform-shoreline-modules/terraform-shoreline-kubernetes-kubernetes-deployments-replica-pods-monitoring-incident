
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes Deployments Replica Pods Monitoring Incident
---

This incident type relates to the monitoring of Kubernetes deployments replica pods. It implies that there is an issue with the number of replica pods available as compared to the desired number. The incident might be triggered by a query alert monitor and might require immediate action to resolve the issue. The incident could impact the deployment of applications hosted on Kubernetes and might require troubleshooting and fixing the underlying issue.

### Parameters
```shell
# Environment Variables
export NAMESPACE="PLACEHOLDER"
export POD_NAME="PLACEHOLDER"
export DEPLOYMENT_NAME="PLACEHOLDER"
export PATH_TO_KUBE_MANIFESTS="PLACEHOLDER"
export CONTEXT_NAME="PLACEHOLDER"
```

## Debug

### List all deployments in the affected namespace
```shell
kubectl get deployments -n ${NAMESPACE}
```

### Check if there are any pods that are not ready
```shell
kubectl describe pods -n ${NAMESPACE}
```

### Check the logs of the affected pods for any errors
```shell
kubectl logs ${POD_NAME} -n ${NAMESPACE}
```

### Check the events in the affected namespace
```shell
kubectl get events -n ${NAMESPACE}
```

### Check the status of the Kubernetes nodes
```shell
kubectl get nodes
```

### Check the status of the Kubernetes services
```shell
kubectl get services -n ${NAMESPACE}
```

### Check the Kubernetes events related to the deployment
```shell
kubectl describe deployment ${DEPLOYMENT_NAME} -n ${NAMESPACE}
```

### A recent deployment or upgrade of applications on Kubernetes might have caused the pods to go down.
```shell
bash
#!/bin/bash

# Set the target Kubernetes namespace and deployment name
NAMESPACE=${NAMESPACE}
DEPLOYMENT=${DEPLOYMENT_NAME}

# Check the status of the deployment
DEPLOYMENT_STATUS=$(kubectl -n $NAMESPACE get deployment $DEPLOYMENT -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')

if [ "$DEPLOYMENT_STATUS" == "False" ]; then
  # Get the deployment events
  kubectl -n $NAMESPACE describe deployment $DEPLOYMENT | grep -A 10 -i events

  # Check the logs of the deployment pods
  PODS=$(kubectl -n $NAMESPACE get pods -l app=$DEPLOYMENT -o jsonpath='{.items[*].metadata.name}')
  for POD in $PODS; do
    echo "### Logs for pod $POD ###"
    kubectl -n $NAMESPACE logs $POD
  done
fi

```

### There might be a scaling issue where the desired number of replica pods is not being met due to resource constraints or misconfiguration.
```shell

#!/bin/bash

# Set Kubernetes context
kubectl config use-context ${CONTEXT_NAME}

# Check if the deployment exists
if ! kubectl get deployment ${DEPLOYMENT_NAME}; then
  echo "Deployment does not exist"
  exit 1
fi

# Check the number of available replicas
available=$(kubectl get deployment ${DEPLOYMENT_NAME} -o=jsonpath='{.status.availableReplicas}')
if [[ $available -eq 0 ]]; then
  echo "No available replicas"
  exit 1
fi

# Check the number of desired replicas
desired=$(kubectl get deployment ${DEPLOYMENT_NAME} -o=jsonpath='{.spec.replicas}')
if [[ $desired -eq 0 ]]; then
  echo "No desired replicas"
  exit 1
fi

# Check if the number of available replicas equals the number of desired replicas
if [[ $available -ne $desired ]]; then
  echo "Scaling issue - available replicas do not match desired replicas"
  exit 1
fi

echo "Scaling is working correctly"

```

---

## Repair
---
### Check if any recent changes were made to the deployment that could have caused the issue. Verify if the replicas are scaled down or if there is a problem with the deployment configuration.
```shell

#!/bin/bash

# Check if deployment has been modified recently
last_modified=$(kubectl get deployment ${DEPLOYMENT_NAME} -o=json | jq -r '.metadata.creationTimestamp')
echo "Deployment was last modified on: $last_modified"

# Check if replicas are scaled down
current_replicas=$(kubectl get deployment ${DEPLOYMENT_NAME} -o=json | jq -r '.spec.replicas')
available_replicas=$(kubectl get deployment ${DEPLOYMENT_NAME} -o=json | jq -r '.status.availableReplicas')
if [[ $available_replicas -lt $current_replicas ]]; then
    echo "Replicas are scaled down. Current replicas: $current_replicas, Available replicas: $available_replicas"
fi

# Verify if there is a problem with the deployment configuration
deployment_status=$(kubectl get deployment ${DEPLOYMENT_NAME} -o=json | jq -r '.status.conditions[-1].status')
if [[ $deployment_status == "False" ]]; then
    deployment_message=$(kubectl get deployment ${DEPLOYMENT_NAME} -o=json | jq -r '.status.conditions[-1].message')
    echo "There is a problem with the deployment configuration: $deployment_message"
fi

```
### Perform a Rolling Restart of a Kubernetes Deployment.
.
```shell
#!/bin/bash

kubectl rollout restart deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}
 
```

---