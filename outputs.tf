
output "Kube_contexts" {
  value = "All clusters have been authenticated to. Use the following command to see the context you want to use: kubectl config get-contexts. To switch contect use: kubectl config use-context <conetxt-name>"
}

// Auth to k8s cluster 
output "gcloud_connect_command" {
  value = module.Cluster_GKE.gcloud_connect_command
}


# output "rds_ip" {
#   value = module.Cluster_EKS.RDS_IP
# }