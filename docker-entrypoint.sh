#!/bin/bash -e

source /functions.sh

#
GLOBALRESOURCES=${GLOBALRESOURCES:-"storageclasses"}
RESOURCETYPES=${RESOURCETYPES:-"svc,ingress,configmap,secrets,ds,rc,deployment,statefulset,job,cronjob,serviceaccount,thirdpartyresource,networkpolicy,storageclass"}
TARFILENAME="kube-state-$(date +%FT%T).tar.gz"

# dump state
dump_state

# tar backup assets
tar_files

# upload to cloud storage
if [ "${STORAGE}" = "aws" ]
then
  upload_s3
elif [ "${STORAGE}" = "gcs" ]
then
  upload_gcs
elif [ "${STORAGE}" = "azure" ]
then
  upload_azure_blob
fi
