from pydantic import BaseModel

class Study(BaseModel):
    nct_id: str
    brief_title: str | None = None
    official_title: str | None = None
