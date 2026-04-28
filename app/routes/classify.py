import base64
import json
import logging
import numpy as np
import mediapipe as mp
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from PIL import Image
import io
import os
from app.models.schemas import success_response, error_response

logger = logging.getLogger(__name__)
router = APIRouter()

mp_hands = mp.solutions.hands

LABELS_PATH = os.path.join(os.path.dirname(__file__), '..', '..', 'ml', 'labels.json')
MODEL_PATH  = os.path.join(os.path.dirname(__file__), '..', '..', 'ml', 'model.tflite')

with open(LABELS_PATH, 'r', encoding='utf-8') as f:
    LABELS = json.load(f)

try:
    import tflite_runtime.interpreter as tflite
    interpreter = tflite.Interpreter(model_path=MODEL_PATH)
except ImportError:
    import tensorflow as tf
    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)

interpreter.allocate_tensors()
input_details  = interpreter.get_input_details()
output_details = interpreter.get_output_details()

logger.info(f"Model loaded: {len(LABELS)} classes")


class ClassifyRequest(BaseModel):
    image: str  # base64 encoded image (JPEG or PNG)


def normalize_landmarks(landmarks):
    pts = np.array([[lm.x, lm.y, lm.z] for lm in landmarks], dtype=np.float32)
    wrist = pts[0].copy()
    pts -= wrist
    scale = np.max(np.abs(pts))
    if scale > 0:
        pts /= scale
    return pts.flatten().tolist()


@router.post("/sign")
async def classify_sign(body: ClassifyRequest):
    try:
        image_bytes = base64.b64decode(body.image)
        pil_image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        rgb = np.array(pil_image, dtype=np.uint8)

        with mp_hands.Hands(
            static_image_mode=True,
            max_num_hands=1,
            min_detection_confidence=0.3
        ) as hands:
            result = hands.process(rgb)

        if not result.multi_hand_landmarks:
            logger.info("classify_sign: no hand detected")
            return success_response(
                {"detected": False, "label": None, "confidence": None},
                "No hand detected"
            )

        landmarks = result.multi_hand_landmarks[0].landmark
        normalized = normalize_landmarks(landmarks)

        input_data = np.array([normalized], dtype=np.float32)
        interpreter.set_tensor(input_details[0]['index'], input_data)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]['index'])[0]

        pred_idx   = int(np.argmax(output))
        confidence = float(output[pred_idx])
        label      = LABELS[pred_idx]

        logger.info(f"classify_sign: {label} ({confidence:.3f})")

        return success_response(
            {
                "detected": True,
                "label": label,
                "confidence": confidence,
                "landmarks": normalized
            },
            "Sign classified"
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"classify_sign error: {e}")
        raise HTTPException(
            status_code=500,
            detail=error_response("Classification failed")
        )


@router.get("/health")
async def classify_health():
    return success_response(
        {"ready": True, "num_classes": len(LABELS)},
        "OK"
    )
