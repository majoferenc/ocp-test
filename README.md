# OCP Tekton Demo Test App

## Prerequisites
- Code Ready Containers CRC (Can be replaced by any other RedHat OCP cluster)
- OC CLI
- Tekton CLI

## Prepare local Env (CRC)
In your shell:

      crc setup
      crc start --memory 16000 --disk-size 50 --cpus 8

## Create OCP project
In your shell:
  
    oc new-project tekton-demo

https://github.com/tektoncd/catalog/tree/main/task/buildah

## Install Tekton Community Tasks
In your shell:

      tkn hub install task git-clone
      tkn hub install task buildah
      tkn hub install task kaniko

## Add Repo to OCP
Create file repo.yaml with content:

      apiVersion: pipelinesascode.tekton.dev/v1alpha1
      kind: Repository
      metadata:
        name: git-ocp-test-git
        namespace: openshift-pipelines
      spec:
        url: 'https://github.com/majoferenc/ocp-test.git'

## Create Container Registry Secret

### Set default values for CRC
      CRC_REGISTRY_SERVER=default-route-openshift-image-registry.apps-crc.testing
      CRC_USERNAME=kubeadmin
      CRC_PASSWORD=$(oc whoami -t)
      CRC_EMAIL=kubeadmin@example.com
      CRC_SECRET_NAME=docker-credentials

### Create a Docker-registry secret for CRC
      oc create secret docker-registry $CRC_SECRET_NAME \
          --docker-server=$CRC_REGISTRY_SERVER \
          --docker-username=$CRC_USERNAME \
          --docker-password=$CRC_PASSWORD \
          --docker-email=$CRC_EMAIL

### Link the secret to the default service account in the crc namespace
      oc secrets link default -n tekton-demo $CRC_SECRET_NAME --for=pull

### Create Pipeline

      oc apply -f .tekton/pipeline.yaml

### Trigger Pipeline Run

      oc create -f .tekton/pipelinerun.yaml

### Configure auto trigger after commit in git

      oc apply -f .tekton/push.yaml
