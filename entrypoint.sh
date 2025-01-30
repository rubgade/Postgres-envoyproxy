#!/bin/bash

# Wait for AWS credentials to be available (e.g., from IAM roles for ECS or EC2)
while ! aws sts get-caller-identity >/dev/null 2>&1; do
    echo "Waiting for AWS credentials..."
    sleep 1
done

# Fetch secrets from AWS Secrets Manager
SECRET=$(aws secretsmanager get-secret-value --secret-id your-secret-name --query 'SecretString' --output text)

# Parse JSON (assumes JSON structure like {"username":"user", "password":"pass"})
USERNAME=$(echo $SECRET | jq -r '.username')
PASSWORD=$(echo $SECRET | jq -r '.password')

# Export these variables for use in modify_config.sh
export USERNAME
export PASSWORD

# Modify the config file
/usr/local/bin/modify_config.sh

# Start Envoy with the modified configuration
exec /usr/local/bin/envoy -c /etc/envoy/envoy.yaml