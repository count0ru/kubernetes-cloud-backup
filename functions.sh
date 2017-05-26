#!/bin/bash

function dump_state() {

	echo "Dumping namespaces" > /dev/stderr
	# dump all namespaces that are not kube-system/public or stackpoint-system
	/kubectl get --export -o=json ns | \
	jq '.items[] |
		select(.metadata.name!="kube-system") |
		select(.metadata.name!="kube-public") |
		select(.metadata.name!="stackpoint-system") |
		del(.status,
	        .metadata.uid,
	        .metadata.selfLink,
	        .metadata.resourceVersion,
	        .metadata.creationTimestamp,
	        .metadata.generation
	    )' > /tmp/backup/namespaces-dump.json
	echo ""

	# dump global resources state
	for resource in ${GLOBALRESOURCES}; do
	  echo "Dumping resource: ${resource}" > /dev/stderr
	  /kubectl get --export -o=json ${resource} | \
	  jq --sort-keys \
	      'del(
	          .items[].metadata.annotations."kubectl.kubernetes.io/last-applied-configuration",
	          .items[].metadata.uid,
	          .items[].metadata.selfLink,
	          .items[].metadata.resourceVersion,
	          .items[].metadata.creationTimestamp,
	          .items[].metadata.generation
	      )' >> /tmp/backup/global-resources-dump.json
	done
	echo ""

	# dump resources state
	echo "Dumping resources" > /dev/stderr
	for namespace in $(jq -r '.metadata.name' < /tmp/backup/namespaces-dump.json);do
	    echo "Namespace: ${namespace}" > /dev/stderr
	    /kubectl --namespace="${namespace}" get --export -o=json ${RESOURCETYPES} | \
	    jq '.items[] |
	        select(.type!="kubernetes.io/service-account-token") |
	        del(
	            .spec.clusterIP,
	            .metadata.uid,
	            .metadata.selfLink,
	            .metadata.resourceVersion,
	            .metadata.creationTimestamp,
	            .metadata.generation,
	            .status,
	            .spec.template.spec.securityContext,
	            .spec.template.spec.dnsPolicy,
	            .spec.template.spec.terminationGracePeriodSeconds,
	            .spec.template.spec.restartPolicy
	        )' >> /tmp/backup/cluster-dump.json
	done
	echo ""

	# dump Helm releases
	echo "Dumping Helm releases" > /dev/stderr
	/kubectl --namespace=kube-system get --export -o=json -l OWNER=TILLER configmap | \
	jq '.items[] |
		del(
		.metadata.uid,
		.metadata.selfLink,
		.metadata.resourceVersion,
		.metadata.creationTimestamp
		)' > /tmp/backup/helm-releases-dump.json
	echo ""
}

function tar_files() {
	cp /restore_state.sh /tmp/backup
	cd /tmp/backup
	tar czvf ${TARFILENAME} *
	cd /
}

function upload_s3() {
	# check if bucket exits, if not create it
	if aws s3 ls "s3://$BUCKET" 2>&1 | grep -q 'NoSuchBucket'
	then
		echo "$BUCKET does not exit, creating it"
		aws s3 mb s3://${BUCKET} --region ${REGION}
	fi

	# upload assets to S3 bucket
	echo "Upload assets backup to s3 ${BUCKET}"
	aws s3 cp /tmp/backup/${TARFILENAME} s3://${BUCKET}/ --region ${REGION}
	echo "✓ Assets backup uploaded"
}

function upload_gcs() {
	# check if bucket exits, if not create it
	if gsutil ls 2>&1 | grep -q -w "$BUCKET"
	then
		echo "$BUCKET does exit"
	else
		echo "$BUCKET does not exit, creating it"
		gsutil mb -l ${REGION} gs://${BUCKET}
	fi

	# upload assets to GCS bucket
	echo "Upload assets backup to GCS ${BUCKET}"
	gsutil cp /tmp/backup/${TARFILENAME} gs://${BUCKET}/
	echo "✓ Assets backup uploaded"
}
