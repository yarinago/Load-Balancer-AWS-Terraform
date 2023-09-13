#!/bin/bash

# Define the repository URL
REPO_URL="https://github.com/yarinago/Load-Balancer-AWS-Terraform.git"

# Define the directory to clone the repository into
DIR="~/beaconcure"

# Check if all parameters are provided
if [ "$#" -ne 4 ]; then
    echo "Error: Invalid number of arguments"
    echo "Usage: $0 {terraform_version} {awscli_version} {cluster_number} {action}"
    exit 1
fi

TERRAFORM_VERSION="$1"
AWSCLI_VERSION="$2"
CLUSTER_NUMBER="$3" # Which cluster to manage
AVAILABLE_CLUSTER_AMOUNT=2 # Number of clusters define in main.tf
CLUSTER_DIR="$DIR/cluster$CLUSTER_NUMBER" # Define the directory for the cluster 


# Check if the number of clusters is greater than the maximum
if [ $CLUSTER_NUMBER -gt $AVAILABLE_CLUSTER_AMOUNT ]; then
    echo "Error: Cannot create more than $AVAILABLE_CLUSTER_AMOUNT clusters."
    exit 1
fi


install_requirements() {
    echo "Installing Git, Curl and Unzip..."
    sudo apt-get update
    sudo apt-get install git curl unzip -y
}

# Function to install Terraform
install_terraform() {
    if [ "$TERRAFORM_VERSION" = "-1" ]; then
        echo "Skipping Terraform installation..."
        return
    fi

    echo "Installing Terraform..."
    curl -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    unzip terraform.zip
    sudo mv terraform /usr/local/bin/
    rm terraform.zip
}

# Function to install AWS CLI
install_awscli() {
    if [ "$AWSCLI_VERSION" = "-1" ]; then
        echo "Skipping AWS CLI installation..."
        return
    fi

    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
}

# Function to install the cluster
install_cluster() {
    install_requirements
    install_terraform
    install_awscli

    # Clone the repository into the directory for the cluster 
    git clone $REPO_URL $CLUSTER_DIR 

    # Navigate to the directory 
    cd $CLUSTER_DIR 

    # Initialize Terraform 
    terraform init 

    # Apply the Terraform configuration 
    terraform apply -auto-approve 
}

# Function to start the cluster
start_cluster() {
    # Check if the Terraform state file exists
    if [ ! -f "$CLUSTER_DIR/terraform.tfstate" ]; then
        echo "Error: No cluster found to destroy."
        exit 1
    fi
    
    cd $CLUSTER_DIR

    terraform apply -auto-approve
}

# Function to stop the cluster
stop_cluster() {
    # Check if the Terraform state file exists
    if [ ! -f "$CLUSTER_DIR/terraform.tfstate" ]; then
        echo "Error: No cluster found to destroy."
        exit 1
    fi
    
    cd $CLUSTER_DIR

    terraform apply -auto-approve
}

# Function to check the status of the cluster
cluster_status() {
    # Check if the Terraform state file exists
    if [ ! -f "$CLUSTER_DIR/terraform.tfstate" ]; then
        echo "Error: No cluster found to destroy."
        exit 1
    fi
    
   cd $CLUSTER_DIR

   terraform show
}

# Check the command line argument
case $4 in 
  install)
    install_cluster ;;
  start)
    start_cluster ;;
  stop)
    stop_cluster ;;
  status)
    cluster_status ;;
  *)
    echo "Usage: $0 {terraform_version} {awscli_version} {cluster_number} {install|start|stop|status}" ;;
esac
