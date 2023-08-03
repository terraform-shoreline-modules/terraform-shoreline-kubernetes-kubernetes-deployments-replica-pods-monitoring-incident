
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