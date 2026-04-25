from pydantic_settings import BaseSettings
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

class Settings(BaseSettings):
    DATABASE_URL: str
    CONFIDENCE_THRESHOLD: float = 0.80
    COOLDOWN_SECONDS: float = 1.0
    NO_HAND_TIMEOUT: float = 2.0

    model_config = {"env_file": str(BASE_DIR / ".env")}

settings = Settings()