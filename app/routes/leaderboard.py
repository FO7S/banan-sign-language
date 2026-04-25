import logging

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.db.models import Progress, User
from app.models.schemas import success_response, error_response

router = APIRouter(prefix="/leaderboard", tags=["leaderboard"])
logger = logging.getLogger(__name__)


@router.get("")
async def get_leaderboard(db: AsyncSession = Depends(get_db)):
    try:
        stmt = (
            select(Progress, User.username)
            .join(User, User.id == Progress.user_id)
            .order_by(Progress.total_score.desc())
            .limit(10)
        )
        result = await db.execute(stmt)
        rows = result.all()

        leaderboard = [
            {
                "rank": rank,
                "user_id": str(row.Progress.user_id),
                "username": row.username,
                "total_score": row.Progress.total_score,
                "letters_count": len(row.Progress.letters_practiced or {}),
            }
            for rank, row in enumerate(rows, start=1)
        ]

        logger.info(f"Leaderboard retrieved: {len(leaderboard)} entries")
        return success_response(data={"leaderboard": leaderboard}, message="Leaderboard retrieved")
    except Exception as e:
        logger.error(f"Database error in get_leaderboard: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))
