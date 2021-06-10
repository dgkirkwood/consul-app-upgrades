# Consul Gateways Demo
This code creates a demonstration environment to show the usage of Consul service mesh with mesh, terminating and ingress gateways.

This code is built on the connected clouds repository from David Wright: https://github.com/dawright22/connected-clouds


## Pre-requisites

* Install Terraform 0.12 or higher

* Ensure you have a AWS and a GCP account

* Install helm 3

* Install Kubectl

* Install aswcli v2 https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html 

* Install GKE SDK https://cloud.google.com/sdk/docs/downloads-interactive 

* Clone this repo




## Usage
### 1. Inputs

### AWS 

Open the file Cluster_EKS/variables.tf

You will need to set the following variables to be relevant to your envrioment:
```hcl
variable "aws_region" 
```
### GCP

Open the file Cluster_GKE/variables.tf

You will need to set the following variables to be relevant to your envrioment:
```hcl
variable "gcp_region" 

  description = "GCP region, e.g. us-east1"
  
  default     = "australia-southeast1"

variable "gcp_zone" 

  description = "GCP zone, e.g. us-east1-b (which must be in gcp_region)"
  
  default     = "australia-southeast1-c"

variable "gcp_project" 

  description = "GCP project name"
  
  default     = "your-project-name"
```

### Main.tf
Here you can name the clusters by altering the following:

```hcl
cluster_name = "your-name"
```
### 2. Environment Variables

Ensure you have the correct environment variables set to auth to AWS and GCP

### 3. Terraform

Initialise your environment
```hcl
terraform init 
```

Run a Terraform plan
```hcl
terraform plan 
```

Apply the Terraform environment
```hcl
terraform apply
```

If the run is successful you will see a single output of an IP address we will use in the next step. 


### 4. Application

#### Initial Deploy
As part of the Terraform run you will now have two Kubernetes clusters that have been authenticated to your local Kubectl. 
Please note that you will need to ensure that Kubectl does not have multiple contexts available with the same naming convention as this can affect the scripts run in this step. Ensure if you run this environment multiple times that you remove the old contexts from Kubectl. 

To install the application, first check the file at app/gke_app/gke_app.yaml
On line 101 note the line 
```yaml
image: dgkirkwood/frontend:4.1
```
This is the container image that will change as you update the application. Ensure it is set to 4.1 to start the demo. 

Run the following script: app/01_initial_deploy.sh

This wil install Consul across GKE and EKS, federate the two and install the initial application elements. 

#### Gateway Configuration

Once the initial script has run succesfully, you will have the Mesh Gateway running however extra configuration is needed for the terminating and ingress gateways. 

Two steps are needed to populate the configuration

* Take the IP address that was output from the TF run, and use it to populate app/ext_svc.json
* Take the public address of your Consul server from the GKE and EKS cluster using the following:
```
kubectl config use-context (your GKE context)
```
```
kubectl get svc
```
```
kubectl config use-context (your EKS context)
```
```
kubectl get svc
```

The public address will be displayed as the External Address for the Consul UI. 

Copy these public addresses into the file at app/02_gateway_config.sh

Then run app/02_gateway_config.sh

The application is now ready to demo. Access the application through the public address of the ingress gateway on GKE using port 5000. 


#### Application Lifecycle

The application uses three images to show different aspects of the Service Mesh. 
The images are defined in /app/gke_app/gke_app.yaml

Check line 101
```yaml
image: dgkirkwood/frontend:4.1
```
The image labels are as follows:
* 4.1 Three services in a service mesh within a single K8s cluster on GCP
* 4.2 Three original services with another service in EKS communicating via Mesh Gateway
* 4.3 All original services as well as the external mysql databse via the terminating gateway and RDS in AWS. 

You can use any of these images, or show then sequentially to build a story. 
If you change the image tag you can update the Kubernetes deployment with the following command run from /app: 
```
kubectl apply --force -f /gke_app
```



## Clean up

To remove the environment you will first need to delete the application and the Consul deployments as if you try to run a Terraform destroy you will run into problems with the LBs created by the Kube cluster. 

To ensure cleanup is successful first run app/03_cleanup.sh

Then run 
```hcl
terraform destroy
```

Ensure to clean up the contexts and user profiles from your local kubectl config.


