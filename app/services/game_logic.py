import logging

from app.config import settings

logger = logging.getLogger(__name__)


def evaluate_answer(target: str, answer: str, confidence: float) -> bool:
    result = answer == target and confidence >= settings.CONFIDENCE_THRESHOLD
    logger.info(f"evaluate_answer: target={target} answer={answer} confidence={confidence:.3f} → {result}")
    return result


def calculate_score(correct: bool, time_taken: float) -> int:
    if not correct:
        return 0
    time_bonus = max(0, int((10 - time_taken) * 0.5))
    score = 10 + time_bonus
    logger.info(f"calculate_score: correct={correct} time_taken={time_taken:.2f}s → {score}")
    return score


def update_streak(current_streak: int, correct: bool) -> int:
    new_streak = current_streak + 1 if correct else 0
    logger.info(f"update_streak: {current_streak} → {new_streak}")
    return new_streak
