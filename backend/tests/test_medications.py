from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)


def test_health_endpoint():
    """Verify health probe endpoint returns 200"""
    response = client.get("/health")
    assert response.status_code == 200


def test_get_medications_today_smoke():
    """Verify medications endpoint returns 200 and a list"""
    response = client.get("/medications/today")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

