# Our private repo for kube-state-backup with SPC customization.
===========
[![Docker Repository on Quay](https://quay.io/repository/stackpoint/spc-state-backup/status "Docker Repository on Quay")](https://quay.io/repository/stackpoint/spc-state-backup)

Kubernetes state backup script, designed to be ran as Kubernetes Job.

Setup
-----
Use the Helm chart and deploy a kubernetes `CronJob` primitive in your kubernetes (1.5 and up) cluster ensuring backups of Kubernetes resource definitions to your S3/GCS bucket.


Caveat
------
This is using a kubernetes alpha feature ([cronjobs](https://kubernetes.io/docs/user-guide/jobs/#handling-pod-and-container-failures)) and hasn't been tested for idempotency/concurrent behaviour.  See the cronjob [documentation](https://kubernetes.io/docs/user-guide/cron-jobs/) for details.

If your kubernetes cluster runs under version 1.5 or less, `spec.successfulJobsHistoryLimit` and `spec.failedJobsHistoryLimit` will be ignored as they've been introduced in version 1.6. In this case, running an export every 10 minutes will quickly run up your Job (and therefor Pod) count, causing a linear increase in master server load. A fix for this is to deploy a [blunt instrument](job-cleanup.yaml) to clean the old kube-backup jobs.

