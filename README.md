
## Setup Instructions

### Prerequisites

- [Jenkins](https://www.jenkins.io/)
- [Terraform](https://www.terraform.io/)
- [Ansible](https://www.ansible.com/)
- Google Cloud SDK

### Jenkins Setup

1. **Install Jenkins**:
    ```sh
    sudo yum install -y wget git epel-release java-11-openjdk-devel
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum install --nogpgcheck -y jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    ```

2. **Configure Jenkins**:
    - Install necessary plugins: Pipeline, Ansible, Terraform.
    - Set up credentials for Google Cloud service account.

### Terraform Setup

1. **Initialize Terraform**:
    ```sh
    cd terraform
    terraform init
    ```

2. **Apply Terraform Configuration**:
    ```sh
    terraform apply
    ```

### Ansible Setup

1. **Install Ansible**:
    ```sh
    sudo yum install -y python3 python3-pip
    sudo pip3 install ansible
    ```

2. **Install Ansible Collections**:
    ```sh
    ansible-galaxy install -r ansible/requirements.yml --force --ignore-errors
    ```

## Running the Jenkins Pipeline

1. **Activate GCP Service Account**:
    - The Jenkins pipeline will activate the GCP service account using the credentials provided.

2. **Ansible Setup**:
    - The pipeline checks for Ansible and installs the Google Cloud Ansible collection if not present.

3. **Run BigQuery Operations with Ansible**:
    - The pipeline runs the Ansible playbook for BigQuery operations.

## Cleaning Up

- The Jenkins pipeline includes a `cleanWs()` step to clean the workspace after execution.

## Troubleshooting

- Check the Jenkins logs for detailed error messages if the pipeline fails.
- Ensure all dependencies are installed and configured correctly.

## Additional Information

- For more details on the Ansible roles and playbooks, refer to the [ansible](ansible/) directory.
- For Terraform configuration details, refer to the [terraform](terraform/) directory.