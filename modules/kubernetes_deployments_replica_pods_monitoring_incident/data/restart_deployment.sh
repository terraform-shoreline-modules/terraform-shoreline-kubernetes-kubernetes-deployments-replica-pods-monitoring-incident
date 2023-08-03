#!/bin/bash

kubectl rollout restart deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}