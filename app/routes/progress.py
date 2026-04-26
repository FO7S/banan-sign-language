import logging
import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.db.models import Achievement, Progress, User
from app.models.schemas import error_response, success_response

router = APIRouter(prefix="/progress", tags=["progress"])
logger = logging.getLogger(__name__)


@router.get("/{user_id}")
async def get_progress(user_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    try:
        user = await db.get(User, user_id)
        if user is None:
            raise HTTPException(status_code=404, detail=error_response(f"User {user_id} not found"))

        result = await db.execute(select(Progress).where(Progress.user_id == user_id))
        progress = result.scalar_one_or_none()

        if progress is None:
            raise HTTPException(status_code=404, detail=error_response(f"Progress not found for user {user_id}"))

        rank_result = await db.execute(
            select(func.count()).select_from(Progress).where(Progress.total_score > progress.total_score)
        )
        rank = rank_result.scalar() + 1

        ach_result = await db.execute(
            select(Achievement).where(Achievement.user_id == user_id)
        )
        achievements = ach_result.scalars().all()
        achievements_data = [
            {
                "code": a.code,
                "unlocked": a.unlocked,
                "unlocked_at": a.unlocked_at.isoformat() if a.unlocked_at else None,
            }
            for a in achievements
        ]

        letters_practiced = progress.letters_practiced or {}
        logger.info(f"Progress retrieved for user {user_id}")

        return success_response(
            data={
                "user_id": str(user_id),
                "username": user.username,
                "avatar_name": user.avatar_name,
                "avatar_emoji": user.avatar_emoji,
                "total_score": progress.total_score,
                "best_streak": progress.best_streak,
                "letters_practiced": letters_practiced,
                "letters_count": len(letters_practiced),
                "rank": rank,
                "achievements": achievements_data,
            },
            message="Progress retrieved",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in get_progress: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))
