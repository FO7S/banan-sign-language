# 🌿 Banan Backend | بنان

**REST API for the Banan Arabic Sign Language Learning Game**

Banan (بنان) is an AI-powered mobile app that teaches Arabic Sign Language to children — especially deaf and hard-of-hearing kids — through interactive gameplay. This repository contains the FastAPI backend responsible for game logic, user management, scoring, progress tracking, and optional hand detection testing.

> The main AI inference runs **on-device** in Flutter for real-time performance.  
> The backend also provides an optional MediaPipe `/detect/hand` endpoint for testing, demos, or fallback use.

---

## 🚀 Live API

```text
https://banan-sign-language-production.up.railway.app
````

Interactive docs:

```text
https://banan-sign-language-production.up.railway.app/docs
```

---

## 🛠 Tech Stack

| Layer            | Technology          |
| ---------------- | ------------------- |
| Framework        | FastAPI             |
| Database         | Supabase PostgreSQL |
| ORM              | SQLAlchemy async    |
| Driver           | asyncpg + NullPool  |
| Validation       | Pydantic v2         |
| Hand Detection   | MediaPipe Hands     |
| Image Processing | Pillow + NumPy      |
| Deployment       | Railway             |
| Container        | Dockerfile          |
| Server           | Uvicorn             |

---

## 📁 Project Structure

```text
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
│   │   └── detect.py
│   └── services/
│       └── game_logic.py
├── .env
├── .env.example
├── Dockerfile
├── Procfile
└── requirements.txt
```

---

## 📡 API Endpoints

### User

| Method | Endpoint          | Description       |
| ------ | ----------------- | ----------------- |
| POST   | `/user/register`  | Register new user |
| POST   | `/user/login`     | Login user        |
| PUT    | `/user/update`    | Update user info  |
| GET    | `/user/{user_id}` | Get user info     |

### Session

| Method | Endpoint         | Description        |
| ------ | ---------------- | ------------------ |
| POST   | `/session/start` | Start game session |
| POST   | `/session/end`   | End game session   |

### Challenge

| Method | Endpoint            | Description                       |
| ------ | ------------------- | --------------------------------- |
| POST   | `/challenge/submit` | Submit answer and calculate score |

### Progress & Stats

| Method | Endpoint                  | Description           |
| ------ | ------------------------- | --------------------- |
| GET    | `/progress/{user_id}`     | Get user progress     |
| GET    | `/leaderboard`            | Get top users         |
| GET    | `/achievements/{user_id}` | Get user achievements |

### Detection

| Method | Endpoint       | Description                             |
| ------ | -------------- | --------------------------------------- |
| POST   | `/detect/hand` | Detect hand landmarks from base64 image |

### Health

| Method | Endpoint  | Description      |
| ------ | --------- | ---------------- |
| GET    | `/health` | Check API status |

---

## 🖐 Hand Detection Endpoint

The backend includes an optional MediaPipe hand detection endpoint.

This endpoint receives a base64 image and returns 21 normalized hand landmarks.

### Request

```json
{
  "image": "BASE64_IMAGE_STRING"
}
```

### Success Response

```json
{
  "success": true,
  "data": {
    "detected": true,
    "landmarks": [
      0.0,
      0.0,
      0.0
    ]
  },
  "message": "Hand detected"
}
```

### No Hand Detected Response

```json
{
  "success": true,
  "data": {
    "detected": false,
    "landmarks": null
  },
  "message": "No hand detected"
}
```

### Notes

* The endpoint uses MediaPipe Hands.
* It extracts 21 hand landmarks.
* Each landmark has `x`, `y`, and `z`.
* Total output = 63 values.
* Landmarks are normalized relative to the wrist.
* This endpoint is useful for testing and demos.
* For real-time gameplay, on-device detection in Flutter is still recommended.

---

## 🎮 Game Logic

```python
evaluate_answer(target, answer, confidence) -> bool

calculate_score(correct, time_taken) -> int

update_streak(current_streak, correct) -> int
```

### Rules

* Answer is accepted if confidence is high enough.
* Correct answer increases streak.
* Wrong answer resets streak.
* Score depends on correctness and response time.

---

## 🗄 Database Schema

### users

| Column        | Type     | Notes           |
| ------------- | -------- | --------------- |
| id            | UUID     | Primary key     |
| username      | String   | Display name    |
| email         | String   | Unique          |
| password_hash | String   | Hashed password |
| avatar_name   | String   | Avatar name     |
| avatar_emoji  | String   | Avatar emoji    |
| created_at    | DateTime | Creation time   |

### sessions

| Column     | Type     | Notes                            |
| ---------- | -------- | -------------------------------- |
| id         | UUID     | Primary key                      |
| user_id    | UUID     | FK to users                      |
| mode       | Enum     | letter / word / challenge / free |
| score      | Integer  | Session score                    |
| streak     | Integer  | Current streak                   |
| created_at | DateTime | Start time                       |
| ended_at   | DateTime | End time                         |

### progress

| Column            | Type     | Notes             |
| ----------------- | -------- | ----------------- |
| user_id           | UUID     | FK to users       |
| total_score       | Integer  | Total score       |
| best_streak       | Integer  | Best streak       |
| letters_practiced | JSON     | Practiced letters |
| updated_at        | DateTime | Last update       |

### attempts

| Column     | Type     | Notes             |
| ---------- | -------- | ----------------- |
| id         | UUID     | Primary key       |
| user_id    | UUID     | FK to users       |
| session_id | UUID     | FK to sessions    |
| mode       | Enum     | Game mode         |
| target     | String   | Expected answer   |
| answer     | String   | User/model answer |
| correct    | Boolean  | Correct or not    |
| confidence | Float    | Model confidence  |
| time_taken | Float    | Time in seconds   |
| created_at | DateTime | Attempt time      |

### achievements

| Column      | Type     | Notes            |
| ----------- | -------- | ---------------- |
| id          | UUID     | Primary key      |
| user_id     | UUID     | FK to users      |
| code        | String   | Achievement code |
| unlocked    | Boolean  | Unlock status    |
| unlocked_at | DateTime | Unlock time      |

---

## 🏆 Achievement Codes

```text
first_letter
pro_speller
sign_speaker
challenge_hero
fire_streak
leaderboard_star
```

---

## 📦 Standard Response Format

All endpoints follow this format:

```json
{
  "success": true,
  "data": {},
  "message": "OK"
}
```

---

## ⚙️ Environment Variables

Create a `.env` file locally:

```env
DATABASE_URL=postgresql+asyncpg://...
CONFIDENCE_THRESHOLD=0.80
COOLDOWN_SECONDS=1.0
NO_HAND_TIMEOUT=2.0
```

---

## 🐳 Docker Deployment

Railway uses the `Dockerfile` to run the backend.

MediaPipe requires system libraries that are not always available in Railway default builds, such as:

```text
libgl1
libglib2.0-0
libxcb1
libx11-6
libxext6
```

The Dockerfile installs these dependencies manually.

### Dockerfile

```dockerfile
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
```

### Important Notes

Use:

```text
opencv-python-headless
```

Do not use:

```text
opencv-python
```

because the headless version is better for server environments.

Python 3.11 is used because MediaPipe works more reliably with it.

---

## 📦 Requirements

Important packages:

```text
fastapi
uvicorn
sqlalchemy
asyncpg
pydantic
python-dotenv
mediapipe==0.10.13
opencv-python-headless
Pillow==10.4.0
numpy
```

---

## 🏃 Run Locally

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Open:

```text
http://localhost:8000/docs
```

---

## 🚀 Deploy on Railway

1. Push code to GitHub.
2. Open Railway project.
3. Go to service settings.
4. Set builder to Dockerfile.
5. Deploy.
6. Open `/docs` and verify the API.

Check:

```text
GET /health
POST /detect/hand
```

---

## 🔗 Frontend Integration

Base URL:

```dart
const String baseUrl = "https://banan-sign-language-production.up.railway.app";
```

Health check example:

```dart
final response = await http.get(
  Uri.parse('$baseUrl/health'),
);

print(response.body);
```

Detection example:

```dart
final response = await http.post(
  Uri.parse('$baseUrl/detect/hand'),
  headers: {
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'image': base64Image,
  }),
);

print(response.body);
```

---

## 📱 Recommended Real-Time Architecture

For best real-time performance:

```text
Flutter Camera
↓
MediaPipe on-device
↓
63 landmarks
↓
TFLite model
↓
Predicted letter
↓
Send final result to backend
```

The backend should mainly handle:

* users
* sessions
* challenges
* scoring
* progress
* leaderboard
* achievements

---

## 🔗 Related Repositories

* Flutter App: contains the mobile app and TFLite model.
* ML Training: contains model training notebooks and dataset processing.

---

## 👥 Team

Built for deaf and hard-of-hearing children in Saudi Arabia, supporting accessibility and inclusive learning.

هذا مبني على الـ README الحالي اللي رفعته، مع تعديل وصف الـ AI وإضافة Docker + detect endpoint بدل النص القديم اللي كان يقول إن كل الـ AI فقط on-device. :contentReference[oaicite:0]{index=0}
```
