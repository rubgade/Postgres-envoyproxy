#!/bin/bash

# Update readers in the config file
sed -i "s/reader1\.example\.com/$READER1/g" /etc/envoy/envoy.yaml
sed -i "s/reader2\.example\.com/$READER2/g" /etc/envoy/envoy.yaml

# Update writer in the config file
sed -i "s/writer\.example\.com/$WRITER/g" /etc/envoy/envoy.yaml

# Add user and password to the connection (assuming PostgreSQL supports this in connection string)
# Note: This is a simplified approach; in practice, you might need to handle authentication more securely
sed -i "s/address: \(.*\)/address: \\1?user=$USERNAME&password=$PASSWORD/g" /etc/envoy/envoy.yaml

# Execute the command passed to the script
exec "$@"