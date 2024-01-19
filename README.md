# OCP Tekton Demo Test App

## Prerequisites
- Code Ready Containers CRC (Can be replaced by any other RedHat OCP cluster)
- OC CLI - https://docs.openshift.com/container-platform/4.8/cli_reference/openshift_cli/getting-started-cli.html
- Tekton CLI - https://tekton.dev/vault/cli-v0.21.0/



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
      tkn hub install task openshift-client

## Add Repo to OCP
Create file repo.yaml with content:

      apiVersion: pipelinesascode.tekton.dev/v1alpha1
      kind: Repository
      metadata:
        name: git-ocp-test-git
        namespace: tekton-demo
      spec:
        url: 'https://github.com/majoferenc/ocp-test.git'

## Create Container Registry Secret

### Set default values for CRC
Bash:

      CRC_REGISTRY_SERVER=default-route-openshift-image-registry.apps-crc.testing
      CRC_USERNAME=kubeadmin
      CRC_PASSWORD=$(oc whoami -t)
      CRC_EMAIL=kubeadmin@example.com
      CRC_SECRET_NAME=docker-credentials

Powershell:

      $CRC_REGISTRY_SERVER = "default-route-openshift-image-registry.apps-crc.testing"
      $CRC_USERNAME = "kubeadmin"
      $CRC_PASSWORD = (oc whoami -t)
      $CRC_EMAIL = "kubeadmin@example.com"
      $CRC_SECRET_NAME = "docker-credentials"


### Create a Docker-registry secret for CRC

Bash:

      oc create secret docker-registry $CRC_SECRET_NAME \
          --docker-server=$CRC_REGISTRY_SERVER \
          --docker-username=$CRC_USERNAME \
          --docker-password=$CRC_PASSWORD \
          --docker-email=$CRC_EMAIL

Powershell:

      oc create secret docker-registry $CRC_SECRET_NAME `
      --docker-server=$CRC_REGISTRY_SERVER `
      --docker-username=$CRC_USERNAME `
      --docker-password=$CRC_PASSWORD `
      --docker-email=$CRC_EMAIL


### Link the secret to the default service account in the crc namespace
      
      oc secrets link default -n tekton-demo $CRC_SECRET_NAME --for=pull

### Import needed images 
      
      oc import-image ubi8/openjdk-8:1.18-2 --from=registry.access.redhat.com/ubi8/openjdk-8:1.18-2 --confirm

### Allow deployment from tekton pipeline

      oc policy add-role-to-user edit -z default -n tekton-demo
      
### Create Pipeline

      oc apply -f .tekton/pipeline.yaml

### Trigger Pipeline Run

      oc create -f .tekton/pipelinerun.yaml

### Configure auto trigger after commit in git

      oc apply -f .tekton/push.yaml
