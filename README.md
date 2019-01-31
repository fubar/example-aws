# Amazon Web Service (AWS) - GitHub Action Example

An example workflow, using the [GitHub Action for AWS](https://github.com/actions/aws) to build, tag, and deploy a container image to a running Kubernetes cluster on EKS.

## Workflow

The [example workflow](.github/main.workflow) will trigger on every push to this repo.

For pushes to a _feature_ branch, the workflow will:

1. Build the Docker image from [the included `Dockerfile`](Dockerfile)
1. Tag and push the image to [Amazon Elastic Container Registry](https://aws.amazon.com/ecr/)

For pushes to the _default_ branch (`master`), in addition to the above Actions, the workflow will:

1. Create a deployment using [deployment.yml](/deployment.yml) on the running EKS cluster with the latest container image

## Prerequisites

1. Create an Amazon user with [EKS IAM role](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html) permissions to EKS - [eks user role](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)
1. Create a Repository in [Amazon Elastic Container Registry](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html) to push images to
1. Follow the [Getting Started Guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html) to set up a cluster on EKS
1. Generate a kubectl config with credentials to access the cluster - for example: `aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_DEFAULT_REGION` - base64 encode this file and save this as the `KUBE_CONFIG_DATA` secret
      
      `cat $HOME/.kube/config | base64`
