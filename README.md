# CICD Ansible Project

This project includes an Ansible setup to manage GCP resources, specifically BigQuery datasets and tables.

## Components
- **Playbook**: The main playbook to deploy BigQuery resources.
- **Inventory**: Configuration for the staging environment.
- **Role**: `bq_operations` role for BigQuery operations.

## Usage
1. Navigate to the `ansible` directory.
2. Run the playbook with:

   ```
   ansible-playbook -i inventory/staging/hosts.yml playbook.yml
   ```
