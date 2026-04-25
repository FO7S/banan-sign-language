import logging
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.db.models import Session, User
from app.models.schemas import SessionEndRequest, SessionStartRequest, success_response, error_response

router = APIRouter(prefix="/session", tags=["session"])
logger = logging.getLogger(__name__)


@router.post("/start")
async def start_session(body: SessionStartRequest, db: AsyncSession = Depends(get_db)):
    try:
        user = await db.get(User, body.user_id)
        if not user:
            user = User(id=body.user_id, username=str(body.user_id))
            db.add(user)
            await db.flush()

        session = Session(user_id=body.user_id, mode=body.mode.value)
        db.add(session)
        await db.flush()
        await db.refresh(session)

        logger.info(f"Session started: user={body.user_id} mode={body.mode} session={session.id}")
        return success_response(
            data={
                "session_id": str(session.id),
                "mode": session.mode,
                "created_at": session.created_at.isoformat(),
            },
            message="Session started",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in start_session: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))


@router.post("/end")
async def end_session(body: SessionEndRequest, db: AsyncSession = Depends(get_db)):
    try:
        session = await db.get(Session, body.session_id)
        if not session:
            raise HTTPException(status_code=404, detail=error_response(f"Session {body.session_id} not found"))

        now = datetime.now(timezone.utc)
        session.ended_at = now

        created_at = session.created_at
        if created_at.tzinfo is None:
            created_at = created_at.replace(tzinfo=timezone.utc)
        duration_seconds = int((now - created_at).total_seconds())

        await db.flush()

        logger.info(f"Session ended: session={body.session_id} score={session.score} duration={duration_seconds}s")
        return success_response(
            data={
                "session_id": str(session.id),
                "final_score": session.score,
                "final_streak": session.streak,
                "duration_seconds": duration_seconds,
            },
            message="Session ended",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in end_session: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))
