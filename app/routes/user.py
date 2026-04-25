import logging
import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.db.models import User
from app.models.schemas import UserRegisterRequest, success_response, error_response

router = APIRouter(prefix="/user", tags=["user"])
logger = logging.getLogger(__name__)


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
                    "created_at": user.created_at.isoformat(),
                },
                message="User registered",
            )

        user = User(id=body.user_id, username=body.username)
        db.add(user)
        await db.flush()
        await db.refresh(user)

        logger.info(f"User registered: {user.id} username={user.username}")
        return success_response(
            data={
                "user_id": str(user.id),
                "username": user.username,
                "created_at": user.created_at.isoformat(),
            },
            message="User registered",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in register_user: {e}")
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
                "created_at": user.created_at.isoformat(),
            },
            message="User retrieved",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in get_user: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))
