workflow "Build and Deploy" {
  on = "push"
  resolves = ["List Public IP"]
}

# Build

action "Build Docker image" {
  uses = "actions/docker/cli@master"
  args = ["build", "--tag", "aws-example", "."]
}

# Deploy Filter
action "Deploy branch filter" {
  needs = ["Push image to ECR"]
  uses = "actions/bin/filter@master"
  args = "branch master"
}

# AWS

action "Login to ECR" {
  uses = "actions/aws/cli@master"
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    AWS_DEFAULT_REGION = "us-west-2"
  }
  args = "ecr get-login --no-include-email --region $AWS_DEFAULT_REGION | sh"
}

action "Tag image for ECR" {
  needs = ["Build Docker image"]
  uses = "actions/docker/tag@master"
  env = {
    CONTAINER_REGISTRY_PATH = "377117578606.dkr.ecr.us-west-2.amazonaws.com"
    IMAGE_NAME = "aws-example"
  }
  args = ["$IMAGE_NAME", "$CONTAINER_REGISTRY_PATH/$IMAGE_NAME"]
}

action "Push image to ECR" {
  needs = ["Login to ECR", "Tag image for ECR"]
  uses = "actions/docker/cli@master"
  env = {
    CONTAINER_REGISTRY_PATH = "377117578606.dkr.ecr.us-west-2.amazonaws.com"
    IMAGE_NAME = "aws-example"
  }
  args = ["push", "$CONTAINER_REGISTRY_PATH/$IMAGE_NAME"]
}

action "Deploy to EKS" {
  needs = ["Deploy branch filter"]
  uses = "actions/aws/kubectl@master"
  runs = "sh -l -c"
  args = ["echo \"$KUBE_CONFIG_DATA\" | base64 --decode > /tmp/config && export KUBECONFIG=/tmp/config && SHORT_REF=$(echo $GITHUB_SHA | head -c7) && cat $GITHUB_WORKSPACE/deployment.yml | sed 's/__TAG__/'\"$SHORT_REF\"'/' | kubectl apply --filename - "]
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "KUBE_CONFIG_DATA"]
}

action "Verify EKS deployment" {
  needs = ["Deploy to EKS"]
  uses = "actions/aws/kubectl@master"
  args = ["rollout status deployment/aws-example-octodex"]
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "KUBE_CONFIG_DATA"]
}

action "List Public IP" {
  needs = "Verify EKS deployment"
  uses = "actions/aws/kubectl@master"
  args = ["get services -o wide"]
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "KUBE_CONFIG_DATA"]
}
