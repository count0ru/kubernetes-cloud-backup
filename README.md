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
This is using a Kubernetes alpha feature [Cron Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/), `batch/v2alpha1` API group needs to be [enabled](https://kubernetes.io/docs/reference/api-overview/#enabling-api-groups) in your cluster to make it work.

If your Kubernetes cluster runs under version 1.5 or less, `spec.successfulJobsHistoryLimit` and `spec.failedJobsHistoryLimit` will be ignored as they've been introduced in version 1.6. In this case, running an export every 10 minutes will quickly run up your Job (and therefor Pod) count, causing a linear increase in master server load.
A fix for this is to deploy a [cleanup job](job-cleanup.yaml) to clean the old kube-backup jobs.
