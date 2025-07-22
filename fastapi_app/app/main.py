from fastapi import FastAPI
from .routes import studies

app = FastAPI()
app.include_router(studies.router)

@app.get("/")
async def read_root():
    return {"message": "AACT FastAPI placeholder"}
