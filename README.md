# ADK Agent Deployment Project

This project contains a Google Agent Development Kit (ADK) agent, a FastAPI backend, and Terraform infrastructure for deployment to Google Cloud.

## Directory Structure
- `/agent`: ADK agent source code.
- `/backend`: FastAPI service that wraps the agent.
- `/infrastructure`: Terraform configuration for Cloud Run and related resources.

## Prerequisites
- **Google Cloud SDK (`gcloud`)**: Installed and authenticated.
- **Python 3.10+**: Required for local agent execution.
- **Terraform**: Installed (if deploying infrastructure).
- **Access to Vertex AI**: Ensure the API is enabled in your Google Cloud Project.

## Environment Setup

1. **Agent Configuration**:
   Navigate to the `/agent` directory and copy the example environment file:
   ```bash
   cd agent
   cp .env.example .env
   ```
   Edit `.env` and fill in your details:
   ```ini
   GOOGLE_GENAI_USE_VERTEXAI=1
   GOOGLE_CLOUD_PROJECT=your-project-id
   GOOGLE_CLOUD_LOCATION=us-central1
   ```

2. **Install Dependencies**:
   It is recommended to use a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r agent/requirements.txt
   pip install -r backend/requirements.txt
   ```
   *Note: If `agent/requirements.txt` is missing, ensure you install `google-adk`.*

## Local Testing

### Option 1: Interacting with the Agent Directly (CLI)
You can run the ADK agent locally using the ADK CLI. This is best for testing agent logic isolated from the backend.

```bash
cd agent
adk run
```
This will start an interactive chat session in your terminal.

### Option 2: Running the Backend Locally
To test the full API flow locally:

1. **Start the FastAPI Server**:
   ```bash
   cd backend
   uvicorn main:app --reload --port 8080
   ```

2. **Test the Endpoint**:
   Open a new terminal and send a request:
   ```bash
   curl -X POST http://localhost:8080/chat \
        -H "Content-Type: application/json" \
        -d '{"message": "Hello Local Agent"}'
   ```

## Deployment

1. **Authenticate**:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

2. **Run Deployment Script**:
   ```bash
   ./deploy.sh
   ```
   This script will:
   - Build the backend container using Cloud Build.
   - Initialize and apply the Terraform configuration.

## Testing
Once deployed, you will receive a `backend_url`.
You can test it via curl:
```bash
curl <BACKEND_URL>/
curl -X POST <BACKEND_URL>/chat -H "Content-Type: application/json" -d '{"message": "Hello Agent"}'
```
