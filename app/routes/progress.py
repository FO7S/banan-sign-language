import logging
import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.db.models import Progress
from app.models.schemas import success_response, error_response

router = APIRouter(prefix="/progress", tags=["progress"])
logger = logging.getLogger(__name__)


@router.get("/{user_id}")
async def get_progress(user_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    try:
        result = await db.execute(select(Progress).where(Progress.user_id == user_id))
        progress = result.scalar_one_or_none()

        if progress is None:
            raise HTTPException(status_code=404, detail=error_response(f"Progress not found for user {user_id}"))

        letters_practiced = progress.letters_practiced or {}
        logger.info(f"Progress retrieved for user {user_id}")

        return success_response(
            data={
                "user_id": str(user_id),
                "total_score": progress.total_score,
                "best_streak": progress.best_streak,
                "letters_practiced": letters_practiced,
                "letters_count": len(letters_practiced),
            },
            message="Progress retrieved",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in get_progress: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))
