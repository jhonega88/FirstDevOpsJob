# aws -- version 
# aws eks  --region us-east-1 update-kubeconfig --name aforo255-cluster
# Uses default VPC  and Subnet. Create Your Own VPC and Private Subnets for 

terraform {
  backend "s3" {
    bucket = "mybucket" # will be overridden from build
    key = "path/to/my/key" # will be overridden from build
    region ="us-east-1"  
  }
}

resource "aws_default_vpc" "default" {

}

data "aws_subnet_ids" "subnets"{
  vpc_id= aws_default_vpc.default.id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "aforo255-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "aforo255-cluster"
  cluster_version = "1.14"
  subnets         = ["subnet-abcde012", "subnet-bcde012a"] #change
 # vpc_id          = "vpc-1234556abcdef"
  vpc_id          = aws_default_vpc.default.id 

  node_groups = [
    {
      instance_type = "t2.micro"
      max_capacity  = 5
      desired_capacity =2 
      min_capacity = 2
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  
  name  = module.aforo255-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
 
  name  = module.aforo255-cluster.cluster_id
}


# we will use ServiceAccount to connect to k8s Cluster in CI/CD mode
# ServiceAccount needs permissions to create deployments 
# and services in default namespace
resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name = "fabric8-rbac"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default" 
  }
}
