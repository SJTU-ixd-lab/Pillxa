from fastapi import FastAPI

app = FastAPI(title="Smart Pillbox Demo")


@app.get("/health")
def health_check():
    return {"status": "ok"}
