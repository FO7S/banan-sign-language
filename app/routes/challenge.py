import logging
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.db.models import Attempt, Progress, Session
from app.models.schemas import ChallengeSubmitRequest, success_response, error_response
from app.services.game_logic import calculate_score, evaluate_answer, update_streak

router = APIRouter(prefix="/challenge", tags=["challenge"])
logger = logging.getLogger(__name__)


@router.post("/submit")
async def submit_challenge(body: ChallengeSubmitRequest, db: AsyncSession = Depends(get_db)):
    try:
        session = await db.get(Session, body.session_id)
        if not session:
            raise HTTPException(status_code=404, detail=error_response(f"Session {body.session_id} not found"))

        logger.info(f"User {body.user_id} submitted answer={body.answer} for target={body.target} confidence={body.confidence:.3f}")

        correct = evaluate_answer(body.target, body.answer, body.confidence)
        score_added = calculate_score(correct, body.time_taken)
        new_streak = update_streak(session.streak, correct)

        session.score += score_added
        session.streak = new_streak

        attempt = Attempt(
            user_id=body.user_id,
            session_id=body.session_id,
            mode=body.mode.value,
            target=body.target,
            answer=body.answer,
            correct=correct,
            confidence=body.confidence,
            time_taken=body.time_taken,
        )
        db.add(attempt)

        result = await db.execute(select(Progress).where(Progress.user_id == body.user_id))
        progress = result.scalar_one_or_none()

        if progress is None:
            progress = Progress(user_id=body.user_id, total_score=0, best_streak=0, letters_practiced={})
            db.add(progress)

        progress.total_score += score_added
        if new_streak > progress.best_streak:
            progress.best_streak = new_streak

        if correct and body.target:
            letters = dict(progress.letters_practiced or {})
            letters[body.target] = letters.get(body.target, 0) + 1
            progress.letters_practiced = letters

        progress.updated_at = datetime.now(timezone.utc)

        await db.flush()

        return success_response(
            data={
                "correct": correct,
                "score_added": score_added,
                "streak": new_streak,
                "total_session_score": session.score,
            },
            message="Correct" if correct else "Incorrect",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Database error in submit_challenge: {e}")
        raise HTTPException(status_code=500, detail=error_response("Internal server error"))
