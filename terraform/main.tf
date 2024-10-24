provider "google" {
  credentials = file("/Users/hreddy/path/to/terraform-key.json")  # Path to your service account key
  project     = "testcicd-436812"                                # Your GCP project ID
  region      = "europe-west2"                                   # Your region
}

# Create the VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  auto_create_subnetworks = false  # Disable automatic subnet creation
}

# Create a Public Subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.1.0/24"  # IP range for the public subnet
  region        = "europe-west2"
  private_ip_google_access = true
}

# Create the firewall rule to allow SSH (port 22), HTTP (port 80), and Jenkins (port 8080)
resource "google_compute_firewall" "allow_ssh_http_jenkins" {
  name    = "allow-ssh-http-jenkins"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080"]  # Allow SSH, HTTP, and Jenkins traffic
  }

  source_ranges = ["0.0.0.0/0"]  # Allow traffic from all IPs (for development purposes)

  target_tags = ["public-access"]
}

# Create a public VM instance in the public subnet using CentOS Stream 9 image
resource "google_compute_instance" "public_instance" {
  name         = "public-instance"
  machine_type = "e2-medium"
  zone         = "europe-west2-b"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-9-v20241009"  # CentOS Stream 9 image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.id  # Reference the public subnet
    access_config {
      # Public IP will be assigned automatically
    }
  }

  tags = ["public-access"]  # Apply firewall rules

metadata_startup_script = <<-EOF
#!/bin/bash
set -e  # Exit on any error

LOG_FILE="/var/log/startup-script.log"
exec > >(tee -a $${LOG_FILE}) 2>&1

# Function to check if a command was successful
check_success() {
  if [ $? -ne 0 ]; then
    echo "Error occurred in the previous step. Exiting..." | tee -a $${LOG_FILE}
    exit 1
  fi
}

# Update all packages
echo "Updating all packages..." | tee -a $${LOG_FILE}
sudo yum update -y
check_success

# Install required dependencies: wget, Git, EPEL release, Java
echo "Installing dependencies..." | tee -a $${LOG_FILE}
sudo yum install -y wget git epel-release java-11-openjdk-devel
check_success

# Install Jenkins
echo "Installing Jenkins..." | tee -a $${LOG_FILE}
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
check_success

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
check_success

sudo yum install --nogpgcheck -y jenkins
check_success

# Enable and start Jenkins service
echo "Enabling and starting Jenkins service..." | tee -a $${LOG_FILE}
sudo systemctl enable jenkins
check_success

sudo systemctl start jenkins
check_success

# Install Ansible dependencies and Ansible itself via pip
echo "Enabling EPEL repository and installing Python3 and Ansible..." | tee -a $${LOG_FILE}
sudo yum install -y epel-release
check_success

sudo yum install -y python3 python3-pip
check_success

sudo pip3 install ansible
check_success

# Sleep for 60 seconds to give Jenkins time to start up
echo "Waiting for 60 seconds for Jenkins to fully start..." | tee -a $${LOG_FILE}
sleep 60

# Configure firewall for Jenkins on port 8080
echo "Configuring firewall for Jenkins..." | tee -a $${LOG_FILE}
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
check_success

sudo firewall-cmd --reload
check_success

# Output Jenkins initial admin password if available
echo "Checking for Jenkins initial admin password..." | tee -a $${LOG_FILE}
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
  echo "Jenkins initial admin password:" | tee -a $${LOG_FILE}
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword | tee -a $${LOG_FILE}
else
  echo "Jenkins installation failed or initialAdminPassword not found" >&2 | tee -a $${LOG_FILE}
  exit 1
fi
EOF
}