import base64
import logging
import numpy as np
import mediapipe as mp
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from PIL import Image
import io
from app.models.schemas import success_response, error_response

logger = logging.getLogger(__name__)
router = APIRouter()

mp_hands = mp.solutions.hands

class DetectRequest(BaseModel):
    image: str  # base64 encoded image (JPEG or PNG)

@router.post("/hand")
async def detect_hand(body: DetectRequest):
    try:
        # 1. Decode base64 image using PIL
        image_bytes = base64.b64decode(body.image)
        pil_image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        rgb = np.array(pil_image, dtype=np.uint8)

        # 2. Run MediaPipe Hands
        with mp_hands.Hands(
            static_image_mode=True,
            max_num_hands=1,
            min_detection_confidence=0.3
        ) as hands:
            result = hands.process(rgb)

        # 3. No hand detected
        if not result.multi_hand_landmarks:
            logger.info("detect_hand: no hand found")
            return success_response(
                {"detected": False, "landmarks": None},
                "No hand detected"
            )

        # 4. Extract 21 landmarks (x, y, z) = 63 values
        lms = result.multi_hand_landmarks[0]
        pts = np.array(
            [[lm.x, lm.y, lm.z] for lm in lms.landmark],
            dtype=np.float32
        )

        # 5. Normalize landmarks
        wrist = pts[0].copy()
        pts -= wrist
        scale = np.max(np.abs(pts))
        if scale > 0:
            pts /= scale

        normalized = pts.flatten().tolist()
        logger.info(f"detect_hand: hand detected, {len(normalized)} landmarks")

        return success_response(
            {"detected": True, "landmarks": normalized},
            "Hand detected"
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"detect_hand error: {e}")
        raise HTTPException(
            status_code=500,
            detail=error_response("Detection failed")
        )
