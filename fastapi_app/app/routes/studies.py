from fastapi import APIRouter
from ..models.study import Study

router = APIRouter()

fake_db = [
    Study(nct_id="NCT00000001", brief_title="Example Study", official_title="Example Official Title"),
]

@router.get("/studies", response_model=list[Study])
async def list_studies():
    return fake_db

@router.get("/studies/{nct_id}", response_model=Study)
async def get_study(nct_id: str):
    for study in fake_db:
        if study.nct_id == nct_id:
            return study
    return Study(nct_id=nct_id)
