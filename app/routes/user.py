import hashlib
import logging
import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.db.models import Achievement, User
from app.models.schemas import (
    UserLoginRequest,
    UserRegisterRequest,
    UserUpdateRequest,
    error_response,
    success_response,
)

router = APIRouter(prefix="/user", tags=["user"])
logger = logging.getLogger(__name__)

ACHIEVEMENT_CODES = [
    "first_letter",
    "pro_speller",
    "sign_speaker",
    "challenge_hero",
    "fire_streak",
    "leaderboard_star",
]


def hash_password(password: str) -> str:
    return hashlib.sha256(f"banan_salt_{password}".encode()).hexdigest()


@router.post("/register")
async def register_user(body: UserRegisterRequest, db: AsyncSession = Depends(get_db)):
    try:
        user = await db.get(User, body.user_id)
        if user:
            logger.info(f"User already exists: {body.user_id}")
            return success_response(
                data={
                    "user_id": str(user.id),
                    "username": user.username,
                    "email": user.email,
                    "avatar_name": user.avatar_name,
                    "avatar_emoji": user.avatar_emoji,
                    "created_at": user.created_at.isoformat(),
                },
                message="User registered",
            )

        user = User(
            id=body.user_id,
            username=body.username,
            email=body.email,
            password_hash=hash_password(body.password),
            avatar_name=body.avatar_name,
            avatar_emoji=body.avatar_emoji,
        )
        db.add(user)
        await db.flush()

        for code in ACHIEVEMENT_CODES:
            db.add(Achievement(user_id=body.user_id, code=code, unlocked=False))

        await db.flush()
        await db.refresh(user)

        logger.info(f"User registered: {user.id} username={user.username}")
        return success_response(
            data={
                "user_id": str(user.id),
                "username": user.username,
                "email": user.email,
                "avatar_name": user.avatar_name,
                "avatar_emoji": user.avatar_emoji,
                "created_at": user.created_at.isoformat(),
            },
            message="User registered",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in register_user: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))


@router.post("/login")
async def login_user(body: UserLoginRequest, db: AsyncSession = Depends(get_db)):
    try:
        result = await db.execute(select(User).where(User.email == body.email))
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(status_code=404, detail=error_response("User not found"))

        if user.password_hash != hash_password(body.password):
            raise HTTPException(status_code=401, detail=error_response("Incorrect password"))

        logger.info(f"User logged in: {user.id}")
        return success_response(
            data={
                "user_id": str(user.id),
                "username": user.username,
                "email": user.email,
                "avatar_name": user.avatar_name,
                "avatar_emoji": user.avatar_emoji,
            },
            message="Login successful",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in login_user: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))


@router.put("/update")
async def update_user(body: UserUpdateRequest, db: AsyncSession = Depends(get_db)):
    try:
        user = await db.get(User, body.user_id)
        if not user:
            raise HTTPException(status_code=404, detail=error_response(f"User {body.user_id} not found"))

        if body.username is not None:
            user.username = body.username
        if body.password is not None:
            user.password_hash = hash_password(body.password)
        if body.avatar_name is not None:
            user.avatar_name = body.avatar_name
        if body.avatar_emoji is not None:
            user.avatar_emoji = body.avatar_emoji

        await db.flush()
        await db.refresh(user)

        logger.info(f"User updated: {user.id}")
        return success_response(
            data={
                "user_id": str(user.id),
                "username": user.username,
                "avatar_name": user.avatar_name,
                "avatar_emoji": user.avatar_emoji,
            },
            message="User updated",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in update_user: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))


@router.get("/{user_id}")
async def get_user(user_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    try:
        user = await db.get(User, user_id)
        if not user:
            raise HTTPException(status_code=404, detail=error_response(f"User {user_id} not found"))

        logger.info(f"User retrieved: {user_id}")
        return success_response(
            data={
                "user_id": str(user.id),
                "username": user.username,
                "email": user.email,
                "avatar_name": user.avatar_name,
                "avatar_emoji": user.avatar_emoji,
                "created_at": user.created_at.isoformat(),
            },
            message="User retrieved",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in get_user: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))
