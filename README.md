README
Prerequisites

    Google Cloud SDK (gcloud) installed and authenticated.
    Sufficient permissions in the project to modify IAM roles and manage service accounts.
    Access to Jenkins server and the ability to SSH into compute instances.

1. Add IAM Policy Binding for Service Account

This command assigns the roles/editor role to a service account, granting it edit-level permissions in the specified project.

bash

gcloud projects add-iam-policy-binding testcicd-436812 \
    --member="serviceAccount:terraform-sa@testcicd-436812.iam.gserviceaccount.com" \
    --role="roles/editor"

    testcicd-436812: Your project ID.
    terraform-sa@testcicd-436812.iam.gserviceaccount.com: Service account email.
    roles/editor: The role being granted to the service account.

2. Create and Download Service Account Key

Generate a JSON key for the service account and save it to the specified path.

bash

gcloud iam service-accounts keys create ~/path/to/terraform-key.json \
    --iam-account=terraform-sa@testcicd-436812.iam.gserviceaccount.com

    ~/path/to/terraform-key.json: The local path where the key will be saved.

3. Retrieve Jenkins Admin Password

Retrieve the initial admin password for Jenkins to complete the setup.

bash

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

    Outputs the password from the Jenkins secrets file.

4. Monitor Startup Script Logs

Monitor the startup script logs for troubleshooting or verification purposes.

bash

sudo tail -f /var/log/startup-script.log

    This command continuously displays the log output for review.

5. SSH into a Google Compute Engine Instance

SSH into a public instance running in the specified zone using the gcloud command.

bash

gcloud compute ssh public-instance --zone=europe-west2-b

    public-instance: The name of the Compute Engine instance.
    europe-west2-b: The zone where the instance is located.

