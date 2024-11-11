#!/bin/bash

# Check if all arguments are provided
if [ "$#" -ne 4 ]; then
  echo "Usage: ./update.sh <PROJECT_ID> <DATASET_ID> <EMAIL> <ROLE>"
  exit 1
fi

# Assign arguments to variables
PROJECT_ID=$1         # First argument: GCP Project ID
DATASET_ID=$2         # Second argument: Dataset ID
MEMBER=$3             # Third argument: Email of the user or service account
ROLE=$4               # Fourth argument: Dataset-level role (READER, WRITER, OWNER)

# Retrieve the current IAM policy and save it to a temporary file
bq --project_id=$PROJECT_ID show --format=prettyjson $PROJECT_ID:$DATASET_ID > dataset_policy.json

# Update the JSON file to add the new member with jq
jq ".access += [{\"role\": \"$ROLE\", \"userByEmail\": \"$MEMBER\"}]" dataset_policy.json > updated_policy.json

# Apply the updated policy
bq --project_id=$PROJECT_ID update --source=updated_policy.json $PROJECT_ID:$DATASET_ID

# Clean up temporary files
rm dataset_policy.json updated_policy.json

echo "Access granted to $MEMBER with role $ROLE on dataset $DATASET_ID in project $PROJECT_ID."
