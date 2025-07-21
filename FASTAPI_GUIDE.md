# FastAPI Setup

This repository primarily contains a Ruby on Rails application. The `fastapi_app/` directory provides a minimal FastAPI example that can serve as a starting point for rewriting functionality in Python.

## Structure

```
fastapi_app/
  app/
    main.py          # FastAPI application entrypoint
  requirements.txt   # Python dependencies
  Dockerfile         # Container image for the API
```

A Docker Compose file (`docker-compose.fastapi.yml`) is included at the repository root to run the API alongside a PostgreSQL database.

## Running with Docker Compose

```bash
docker compose -f docker-compose.fastapi.yml build
docker compose -f docker-compose.fastapi.yml up
```

The API will be available at `http://localhost:8000/`.
