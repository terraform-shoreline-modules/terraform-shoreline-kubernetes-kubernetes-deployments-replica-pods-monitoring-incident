
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