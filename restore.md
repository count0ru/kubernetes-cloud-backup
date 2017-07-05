# Tutorial: How to Restore a Kubernetes Cluster's State from Backup


## Table of Contents
* [Introduction](#introduction)
* [Restoring from Backup](#restoring-from-backup)

## Introduction

For more information on how to run the Kubernetes state backup script, designed to be ran as Kubernetes Cron job, see the README file in this repository.

Each backup has a `restore_state.sh` script, which will restore the entire cluster's state when run.

## Restoring from Backup

To restore from backup, run the `restore_state.sh` shell script on the freshly-created cluster. `kubectl` must be present and set to access your cluster. This will restore cluster state from the backed up cluster.
