#!/bin/bash

# restore global resources
kubectl create -f global-resources-dump.json

# restore namespaces
kubectl create -f namespaces-dump.json

# restore resources state
kubectl create -f cluster-dump.json

# restore helm releases
kubectl create -f helm-releases-dump.json
