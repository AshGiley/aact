# FastAPI Example for AACT

This folder contains a minimal FastAPI application that acts as a placeholder for a future Python implementation of the AACT service.

## Folder Structure

```
fastapi_app/
  app/
    main.py          # FastAPI application entrypoint
  requirements.txt   # Python dependencies
  Dockerfile         # Image to run the service
```

## Usage with Docker Compose
A sample `docker-compose` file is available at the repository root named `docker-compose.fastapi.yml`.

Build and run the application:

```bash
docker compose -f docker-compose.fastapi.yml build
docker compose -f docker-compose.fastapi.yml up
```

The API will be available at `http://localhost:8000/`.
