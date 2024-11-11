#!/bin/bash

# Set your Google Cloud Project ID
PROJECT_ID="testcicd-436812"

# Check if dataset ID and user email are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <dataset_id> <user_email> [role]"
    exit 1
fi

# Assign arguments to variables
DATASET_ID="$1"
USER_EMAIL="$2"
ROLE="${3:-roles/bigquery.dataViewer}"  # Default role is BigQuery Data Viewer if not specified

# Debugging: Print values to confirm they are set correctly
echo "Debug: Member is user:$USER_EMAIL"
echo "Debug: Role is $ROLE"

# Use gcloud command with --condition=None to bypass condition check
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="user:$USER_EMAIL" \
    --role="$ROLE" \
    --condition=None \
    --quiet

if [ $? -eq 0 ]; then
    echo "Successfully added $USER_EMAIL to $DATASET_ID with role $ROLE."
else
    echo "Failed to add $USER_EMAIL to $DATASET_ID with role $ROLE. Please check permissions and try again."
fi
