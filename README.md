# 🌿 Banan Backend | بنان

*REST API for the Banan Arabic Sign Language Learning Game*

Banan (بنان) is an AI-powered mobile app that teaches Arabic Sign Language to children — especially deaf and hard-of-hearing kids — through interactive gameplay. This repository contains the FastAPI backend responsible for game logic, user management, scoring, progress tracking, and AI-powered sign language classification.

> The backend provides full AI classification via /classify/sign — combining MediaPipe hand detection and MLP TFLite inference in a single endpoint.

-----

## 🚀 Live API


https://banan-sign-language-production.up.railway.app


Interactive docs:


https://banan-sign-language-production.up.railway.app/docs


-----

## 🛠 Tech Stack

|Layer           |Technology                     |
|----------------|-------------------------------|
|Framework       |FastAPI                        |
|Database        |Supabase (PostgreSQL)          |
|ORM             |SQLAlchemy async + asyncpg     |
|Connection Pool |NullPool (pgbouncer compatible)|
|Validation      |Pydantic v2                    |
|Hand Detection  |MediaPipe Hands                |
|Classification  |MLP TFLite (39 ArSL classes)   |
|Image Processing|Pillow + NumPy                 |
|Server          |Uvicorn                        |
|Deployment      |Railway                        |
|Container       |Dockerfile (python:3.11-slim)  |

-----

## 📁 Project Structure


banan-backend/
├── app/
│   ├── main.py
│   ├── config.py
│   ├── db/
│   │   ├── database.py
│   │   └── models.py
│   ├── models/
│   │   └── schemas.py
│   ├── routes/
│   │   ├── session.py
│   │   ├── challenge.py
│   │   ├── progress.py
│   │   ├── leaderboard.py
│   │   ├── user.py
│   │   ├── achievements.py
│   │   └── classify.py
│   └── services/
│       └── game_logic.py
├── ml/
│   ├── model.tflite       ← MLP model (63 inputs → 39 classes)
│   └── labels.json        ← 39 ArSL class names
├── .env
├── .env.example
├── Dockerfile
├── Procfile
└── requirements.txt


-----

## 📡 API Endpoints

### User

|Method|Endpoint         |Description                            |
|------|-----------------|---------------------------------------|
|POST  |/user/register |Register with email + password + avatar|
|POST  |/user/login    |Login with email + password            |
|PUT   |/user/update   |Update name / password / avatar        |
|GET   |/user/{user_id}|Get user info                          |

### Session

|Method|Endpoint        |Description                 |
|------|----------------|----------------------------|
|POST  |/session/start|Start a new game session    |
|POST  |/session/end  |End session and save results|

### Challenge

|Method|Endpoint           |Description                                              |
|------|-------------------|---------------------------------------------------------|
|POST  |/challenge/submit|Submit answer — calculates score and unlocks achievements|

### Progress & Stats

|Method|Endpoint                 |Description                               |
|------|-------------------------|------------------------------------------|
|GET   |/progress/{user_id}    |Total score + rank + achievements + avatar|
|GET   |/leaderboard           |Top 10 users by score                     |
|GET   |/achievements/{user_id}|All 6 achievements with unlock status     |

### Classification (AI)

|Method|Endpoint          |Description                                         |
|------|------------------|----------------------------------------------------|
|POST  |/classify/sign  |Detect hand + classify ArSL letter from base64 image|
|GET   |/classify/health|Check if model is loaded and ready                  |

### Default

|Method|Endpoint |Description     |
|------|---------|----------------|
|GET   |/health|API health check|

-----

## 🤖 Classification Endpoint

The /classify/sign endpoint combines MediaPipe hand detection and MLP TFLite classification in a single call.

### Pipeline


base64 image
→ MediaPipe Hands → 21 landmarks (x, y, z)
→ Normalize landmarks (wrist subtraction + scale)
→ MLP TFLite → 39 class probabilities
→ Top prediction + confidence


### Request

json
{
  "image": "BASE64_IMAGE_STRING"
}


### Response — hand detected

json
{
  "success": true,
  "data": {
    "detected": true,
    "label": "baa",
    "confidence": 0.97,
    "landmarks": [0.0, 0.0, 0.0, 0.12, -0.34, ...]
  },
  "message": "Sign classified"
}


### Response — no hand

json
{
  "success": true,
  "data": {
    "detected": false,
    "label": null,
    "confidence": null
  },
  "message": "No hand detected"
}


### Normalization (must match training exactly)

python
def normalize_landmarks(landmarks):
    pts = np.array([[lm.x, lm.y, lm.z] for lm in landmarks])
    wrist = pts[0].copy()
    pts -= wrist                    # subtract wrist from all points
    scale = np.max(np.abs(pts))     # find max absolute value
    if scale > 0:
        pts /= scale                # normalize to [-1, 1]
    return pts.flatten().tolist()   # 63 values


### Model Info

|Property            |Value                         |
|--------------------|------------------------------|
|Architecture        |MLP (63 → 256 → 128 → 64 → 39)|
|Classes             |39 ArSL letters               |
|Model size          |68.5 KB                       |
|Inference time      |~0.006 ms                     |
|Train accuracy      |99.78%                        |
|Val accuracy        |99.05%                        |
|Test accuracy       |99.54%                        |
|Confidence threshold|0.70                          |

-----

## 🎮 Game Logic

python
# Accept answer only if confidence >= 0.80
evaluate_answer(target, answer, confidence) → bool

# base=10 + time_bonus=max(0, int((10-time_taken)*0.5))
calculate_score(correct, time_taken) → int

# correct → streak+1 | wrong → streak=0
update_streak(current_streak, correct) → int


-----

## 🏆 Achievement Codes

|Code            |Condition                   |
|----------------|----------------------------|
|first_letter    |letters_count >= 1          |
|pro_speller     |5 words completed           |
|sign_speaker    |1 attempt with mode=free    |
|challenge_hero  |3 correct challenge attempts|
|fire_streak     |best_streak >= 5            |
|leaderboard_star|rank <= 3                   |

-----

## 🗄 Database Schema

### users

|Column       |Type    |Notes         |
|-------------|--------|--------------|
|id           |UUID    |Primary key   |
|username     |String  |Display name  |
|email        |String  |Unique        |
|password_hash|String  |SHA-256 + salt|
|avatar_name  |String  |e.g. “دولفي”  |
|avatar_emoji |String  |e.g. “🐬”      |
|created_at   |DateTime|              |

### sessions

|Column    |Type    |Notes                     |
|----------|--------|--------------------------|
|id        |UUID    |Primary key               |
|user_id   |UUID    |FK → users                |
|mode      |Enum    |letter/word/challenge/free|
|score     |Integer |Session score             |
|streak    |Integer |Current streak            |
|created_at|DateTime|                          |
|ended_at  |DateTime|Nullable                  |

### progress

|Column           |Type    |Notes               |
|-----------------|--------|--------------------|
|user_id          |UUID    |FK → users (unique) |
|total_score      |Integer |All-time score      |
|best_streak      |Integer |All-time best streak|
|letters_practiced|JSON    |{“ba”: 10, “al”: 5} |
|updated_at       |DateTime|                    |

### attempts

|Column    |Type    |Notes           |
|----------|--------|----------------|
|id        |UUID    |Primary key     |
|user_id   |UUID    |FK → users      |
|session_id|UUID    |FK → sessions   |
|mode      |Enum    |                |
|target    |String  |Expected letter |
|answer    |String  |Model prediction|
|correct   |Boolean |                |
|confidence|Float   |0.0 – 1.0       |
|time_taken|Float   |Seconds         |
|created_at|DateTime|                |

### achievements

|Column     |Type    |Notes           |
|-----------|--------|----------------|
|id         |UUID    |Primary key     |
|user_id    |UUID    |FK → users      |
|code       |String  |Achievement code|
|unlocked   |Boolean |                |
|unlocked_at|DateTime|Nullable        |

-----

## 📦 Standard Response Format

json
{
  "success": true,
  "data": {},
  "message": "OK"
}


-----

## ⚙️ Environment Variables

env
DATABASE_URL=postgresql+asyncpg://...supabase...
CONFIDENCE_THRESHOLD=0.80
COOLDOWN_SECONDS=1.0
NO_HAND_TIMEOUT=2.0


-----

## 🐳 Dockerfile

dockerfile
FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libxcb1 \
    libx11-6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]


*Notes:*

- Use opencv-python-headless not opencv-python
- Python 3.11 for MediaPipe compatibility
- System libraries required by MediaPipe installed via apt

-----

## 🏃 Run Locally

bash
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000


Open: http://localhost:8000/docs

-----

## 🚀 Deploy on Railway

1. Push code to GitHub
1. Open Railway → service → Settings → Build
1. Set builder to *Dockerfile*
1. Deploy
1. Verify at /docs

-----

## 📱 Flutter Integration

dart
const String baseUrl = "https://banan-sign-language-production.up.railway.app";

// Classify a sign from camera frame
final response = await http.post(
  Uri.parse('$baseUrl/classify/sign'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'image': base64Image}),
);

final data = jsonDecode(response.body);
if (data['data']['detected']) {
  String label = data['data']['label'];
  double confidence = data['data']['confidence'];
}


-----

## 🔗 Related

- *GitHub:* github.com/FO7S/banan-sign-language
- *Railway:* https://banan-sign-language-production.up.railway.app
- *Supabase:* db.nirjsafygtrfrzgwzhvg.supabase.co

-----

## 👥 Team

Built for deaf and hard-of-hearing children in Saudi Arabia — aligned with Vision 2030 inclusion goals.