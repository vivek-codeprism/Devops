#!/bin/bash
echo hostname = \"$(kubectl get service app -o=jsonpath='{.status.loadBalancer.ingress[].hostname}')\" > hostname.auto.tfvars
