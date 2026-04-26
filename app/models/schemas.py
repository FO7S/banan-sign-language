import uuid
from enum import Enum

from pydantic import BaseModel, field_validator


class ModeEnum(str, Enum):
    letter = "letter"
    word = "word"
    challenge = "challenge"
    free = "free"


# ── Session ──────────────────────────────────────────────────────────────────

class SessionStartRequest(BaseModel):
    user_id: uuid.UUID
    mode: ModeEnum


class SessionStartData(BaseModel):
    session_id: uuid.UUID
    mode: ModeEnum
    created_at: str


# ── Challenge ─────────────────────────────────────────────────────────────────

class ChallengeSubmitRequest(BaseModel):
    user_id: uuid.UUID
    session_id: uuid.UUID
    mode: ModeEnum
    target: str
    answer: str
    confidence: float
    time_taken: float

    @field_validator("confidence")
    @classmethod
    def confidence_range(cls, v: float) -> float:
        if not 0.0 <= v <= 1.0:
            raise ValueError("confidence must be between 0.0 and 1.0")
        return v

    @field_validator("time_taken")
    @classmethod
    def time_taken_positive(cls, v: float) -> float:
        if v < 0:
            raise ValueError("time_taken must be non-negative")
        return v


class ChallengeSubmitData(BaseModel):
    correct: bool
    score_added: int
    streak: int
    total_session_score: int


# ── Progress ──────────────────────────────────────────────────────────────────

class ProgressData(BaseModel):
    user_id: uuid.UUID
    total_score: int
    best_streak: int
    letters_practiced: dict
    letters_count: int


# ── Session end ──────────────────────────────────────────────────────────────

class SessionEndRequest(BaseModel):
    session_id: uuid.UUID
    user_id: uuid.UUID


# ── User ──────────────────────────────────────────────────────────────────────

class UserRegisterRequest(BaseModel):
    user_id: uuid.UUID
    username: str
    email: str
    password: str
    avatar_name: str | None = None
    avatar_emoji: str | None = None


class UserLoginRequest(BaseModel):
    email: str
    password: str


class UserUpdateRequest(BaseModel):
    user_id: uuid.UUID
    username: str | None = None
    password: str | None = None
    avatar_name: str | None = None
    avatar_emoji: str | None = None


# ── Generic response wrapper ──────────────────────────────────────────────────

class ApiResponse(BaseModel):
    success: bool
    data: dict
    message: str


def success_response(data: dict, message: str = "OK") -> dict:
    return {"success": True, "data": data, "message": message}


def error_response(message: str) -> dict:
    return {"success": False, "data": {}, "message": message}
