from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)


def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_get_medications_today_status_and_structure():
    response = client.get("/medications/today")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 4


def test_get_medications_today_data_contents():
    response = client.get("/medications/today")
    assert response.status_code == 200
    expected_items = [
        {"id": 1, "time": "08:00", "meal": "早餐", "status": "pending"},
        {"id": 2, "time": "12:00", "meal": "午餐", "status": "pending"},
        {"id": 3, "time": "18:00", "meal": "晚餐", "status": "pending"},
        {"id": 4, "time": "22:00", "meal": "睡前", "status": "pending"},
    ]
    assert response.json() == expected_items
