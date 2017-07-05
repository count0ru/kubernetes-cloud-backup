Kubernetes state backup
===========

[![Docker Repository on Quay](https://quay.io/repository/stackpoint/spc-state-backup/status "Docker Repository on Quay")](https://quay.io/repository/stackpoint/spc-state-backup)

Kubernetes state backup solution, designed to be run as Kubernetes Job.


Setup
-----
Use the Helm [chart](helm/spc-state-backup) and deploy it to Kubernetes as `CronJob` which will ensure cluster backups of Kubernetes resource definitions to your S3/GCS/Azure cloud storage.


Restore
-------
Check [Restoring from Backup](restore.md) doc.


Caveat
------
This is using a kubernetes alpha feature ([cronjobs](https://kubernetes.io/docs/user-guide/jobs/#handling-pod-and-container-failures)) and and `alpha` features need to be ebaled in your cluster.  See the cronjob  [documentation](https://kubernetes.io/docs/user-guide/cron-jobs/) for details.

If your kubernetes cluster runs under version 1.5 or less, `spec.successfulJobsHistoryLimit` and `spec.failedJobsHistoryLimit` will be ignored as they've been introduced in version 1.6. In this case, running an export every 10 minutes will quickly run up your Job (and therefor Pod) count, causing a linear increase in master server load.
A fix for this is to deploy a [cleanup job](job-cleanup.yaml) to clean the old kube-backup jobs.
