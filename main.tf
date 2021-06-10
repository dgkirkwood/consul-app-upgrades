terraform {
  required_version = ">= 0.12"
}

resource "random_pet" "name" {
  prefix = "consul"
  length = 1
}

#Google
module "Cluster_GKE" {
  source       = "./Cluster_GKE"
  cluster_name = random_pet.name.id
}
