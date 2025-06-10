# Adventure Works data ingestion pipeline

A data ingestion pipeline that extracts data from multiple sources API and SQL Server database and loads it into Databricks Delta Lake tables.

## Project overview

This project implements a comprehensive data ingestion solution for Adventure Works, demonstrating best practices in:
- Multi-source data extraction API and SQL Server Database
- Databricks Serverless compute
- Infrastructure as Code using Terraform
- Containerization with Docker
- Parallel processing for optimal performance
- Error handling and idempotency for production reliability

## Architecture 

```mermaid
graph TB
    subgraph "Data Sources"
        API[API]
        DB[(SQL Server)]
    end
    
    subgraph "Infrastructure"
        TF[Terraform]
        DOCKER[Docker]
    end
    
    subgraph "Databricks Serverless"
        NB1[API Ingestion<br/>Notebook]
        NB2[DB Ingestion<br/>Notebook]
    end
    
    subgraph "Storage"
        DL[Delta Lake<br/>Tables]
    end
    
    API --> NB1
    DB --> NB2
    TF --> NB1
    TF --> NB2
    DOCKER --> TF
    NB1 --> DL
    NB2 --> DL
```
## Getting started

### Prerequisites

- Docker and Docker Compose installed
- Access to Azure Databricks workspace
- Databricks personal access token

### Environment configuration

1. Clone the repository:
```bash
git clone <repository-url>
cd aw-lh-checkpoint
```

2. Create environment file:
```bash
cp .env.example .env
```

3. Configure `.env` file with your credentials:
```bash
# Databricks Configuration
DATABRICKS_HOST=https://adb-xxxxxxxxx.x.azuredatabricks.net
DATABRICKS_TOKEN=dapi********************************

# API Configuration  
API_URL=http://xxx.xxx.xxx.xxx:8080/
API_USER=your_api_username
API_PASSWORD=your_api_password

# Database Configuration
DB_URL=jdbc:sqlserver://xxx.xxx.xxx.xxx:4563;databaseName=AdventureWorks;encrypt=false;trustServerCertificate=true
DB_USER=your_db_username
DB_PASSWORD=your_db_password

# Output Configuration
OUTPUT_PATH=/Workspace/Users/your.email@domain.com/PROJECT_NAME
PATH_TABLE_OUTPUT=your_catalog.your_schema
```

## Deployment

### Automated deployment 

```bash
# Grant execution permission
chmod +x deploy.sh

# Execute complete deployment
./deploy.sh
```

### Manual deployment

```bash
# Initialize Terraform
docker compose run --rm terraform init

# Validate configuration
docker compose run --rm terraform validate

# Apply infrastructure
docker compose run --rm terraform apply -auto-approve
```

## Project structure

```
aw-lh-checkpoint/
├── README.md                    
├── deploy.sh                    # Automated deployment script
├── Dockerfile                   # Terraform container with dependencies
├── docker-compose.yml           # Container orchestration
├── .env                         # Environment variables 
├── .gitignore                   # Files git will ignore
└── terraform/                   
    ├── main.tf                  # Main Databricks resources
    ├── variables.tf             # Variable definitions
    └── notebooks/               # Processing logic
        ├── api_ingestion.py     # API data ingestion pipeline
        └── db_ingestion.py      # Database ingestion pipeline
```
