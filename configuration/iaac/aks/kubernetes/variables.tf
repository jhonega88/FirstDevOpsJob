variable client_id {}
variable client_secret {}
variable ssh_public_key {}

variable environment {
    default = "dev"
}

variable location {
    default = "eastus"
}

variable node_count {
  default = 2
}



variable dns_prefix {
  default = "k8sjhonv2"
}

variable cluster_name {
  default = "k8sjhonv2"
}

variable resource_group {
  default = "kubernetesJhonRGv2"
}
