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