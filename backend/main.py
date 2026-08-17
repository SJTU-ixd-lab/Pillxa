from typing import List
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Smart Pillbox Demo")


class MedicationPlanItem(BaseModel):
    id: int
    time: str
    meal: str
    status: str


MOCK_MEDICATIONS_TODAY: List[MedicationPlanItem] = [
    MedicationPlanItem(id=1, time="08:00", meal="早餐", status="pending"),
    MedicationPlanItem(id=2, time="12:00", meal="午餐", status="pending"),
    MedicationPlanItem(id=3, time="18:00", meal="晚餐", status="pending"),
    MedicationPlanItem(id=4, time="22:00", meal="睡前", status="pending"),
]


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/medications/today", response_model=List[MedicationPlanItem])
def get_medications_today():
    return MOCK_MEDICATIONS_TODAY
