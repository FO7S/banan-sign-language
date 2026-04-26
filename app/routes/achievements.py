import logging
import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.db.models import Achievement
from app.models.schemas import error_response, success_response

router = APIRouter(prefix="/achievements", tags=["achievements"])
logger = logging.getLogger(__name__)


@router.get("/{user_id}")
async def get_achievements(user_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    try:
        result = await db.execute(
            select(Achievement).where(Achievement.user_id == user_id)
        )
        achievements = result.scalars().all()

        if not achievements:
            raise HTTPException(status_code=404, detail=error_response(f"Achievements not found for user {user_id}"))

        achievements_data = [
            {
                "code": a.code,
                "unlocked": a.unlocked,
                "unlocked_at": a.unlocked_at.isoformat() if a.unlocked_at else None,
            }
            for a in achievements
        ]

        logger.info(f"Achievements retrieved for user {user_id}")
        return success_response(
            data={"achievements": achievements_data},
            message="Achievements retrieved",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in get_achievements: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))
