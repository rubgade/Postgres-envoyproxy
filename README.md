
# PostgreSQL Database Proxy with Envoy

This project sets up an Envoy Proxy to act as a load balancer and read/write query router for PostgreSQL databases. Here's how it works:

- **Read/Write Query Splitting**: SELECT queries are routed to read replicas, while INSERT/UPDATE/DELETE and other modifying queries are directed to the primary writer.
- **Load Balancing**: Read queries are load-balanced across multiple PostgreSQL read replicas.
- **Secure Credential Management**: Credentials are fetched from AWS Secrets Manager for secure handling.

## Prerequisites

- Docker (for running the containerized Envoy)
- AWS CLI configured with permissions to access Secrets Manager
- PostgreSQL server(s) set up (one writer, one or more readers)

## Architecture

- **Client**: Applications connect to Envoy instead of directly to the database.
- **Envoy**: 
  - Listens on port 5432 for incoming PostgreSQL connections.
  - Parses SQL commands to determine if they are read or write operations.
  - Routes traffic accordingly:
    - Read queries to a load-balanced pool of read replicas.
    - Write queries to the single writer instance.
- **PostgreSQL Servers**: 
  - One primary server for write operations.
  - Multiple read replicas for read operations.

## Setup

### Building the Docker Image

1. **Clone the repository**:

   ```bash
   git clone <your-repository-url>
   cd <repository-directory>

Build the Docker Image:
bash
docker build -t envoy-postgres-proxy .

Running the Proxy
To run the proxy, you can use:

bash
docker run --rm \
  -e READER1=reader1.example.com \
  -e READER2=reader2.example.com \
  -e WRITER=writer.example.com \
  -p 5432:5432 \
  -e AWS_ACCESS_KEY_ID=your-access-key \
  -e AWS_SECRET_ACCESS_KEY=your-secret-key \
  -e AWS_REGION=your-region \
  envoy-postgres-proxy

Note: 
Adjust AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_REGION according to your AWS setup. Using IAM roles for EC2 or ECS is recommended for production.
Replace reader1.example.com, reader2.example.com, and writer.example.com with your actual PostgreSQL server addresses.

Secrets Management
Secrets Manager: The proxy fetches database credentials from AWS Secrets Manager. Ensure your secret JSON includes username and password keys.

Configuration
envoy.yaml: Contains the routing logic for Envoy. You might want to adjust this file to match your exact needs, like adding more readers or changing load balancing policies.
modify_config.sh: Modifies the envoy.yaml at runtime to inject environment variables for reader and writer endpoints.
entrypoint.sh: Fetches credentials from AWS Secrets Manager before starting Envoy.

Security Considerations
TLS: Ensure TLS is used for all connections if you're passing credentials through the network. This setup doesn't include TLS configuration for simplicity but should be added for production use.
Credentials: Credentials are managed via environment variables and AWS Secrets Manager. Always use secure methods for managing and passing sensitive information.

Limitations
SQL Parsing: SQL parsing for routing might not catch all edge cases or custom queries. You might need to refine or extend the parsing logic.
Performance: Parsing queries adds some latency. Ensure this overhead is acceptable for your application.

Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.



