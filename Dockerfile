FROM envoyproxy/envoy:v1.26.0

# Install AWS CLI and jq for JSON parsing
RUN apt-get update && \
    apt-get install -y \
    python3-pip \
    jq && \
    pip3 install awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration file
COPY envoy.yaml /etc/envoy/envoy.yaml

# Make the configuration file readable by the envoy user
RUN chmod go+r /etc/envoy/envoy.yaml

# Copy scripts
COPY modify_config.sh /usr/local/bin/modify_config.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make scripts executable
RUN chmod +x /usr/local/bin/modify_config.sh /usr/local/bin/entrypoint.sh

# Set environment variables with default values
ENV READER1="reader1.example.com" \
    READER2="reader2.example.com" \
    WRITER="writer.example.com"

# Use entrypoint.sh to initialize environment before running Envoy
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start Envoy with the modified configuration (this is overridden by entrypoint.sh)
CMD ["/usr/local/bin/envoy", "-c", "/etc/envoy/envoy.yaml"]