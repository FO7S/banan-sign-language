# 🌿 Banan Backend | بنان

**REST API for the Banan Arabic Sign Language Learning Game**

Banan (بنان) is an AI-powered mobile app that teaches Arabic Sign Language to children — especially deaf and hard-of-hearing kids — through interactive gameplay. This repository contains the FastAPI backend responsible for game logic, user management, scoring, and progress tracking.

> The AI inference (MediaPipe + MobileNetV2 TFLite) runs **on-device** in Flutter. The backend only receives final results and manages game state.

---

## 🚀 Live API

```
https://banan-sign-language-production.up.railway.app
```

Interactive docs: [/docs](https://banan-sign-language-production.up.railway.app/docs)

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | FastAPI |
| Database | Supabase (PostgreSQL) |
| ORM | SQLAlchemy (async) |
| Driver | asyncpg + NullPool |
| Validation | Pydantic v2 |
| Server | Uvicorn |
| Deployment | Railway |

---

## 📁 Project Structure

```
banan-backend/
├── app/
│   ├── main.py           ← FastAPI app + CORS + lifespan
│   ├── config.py         ← Settings from .env
│   ├── db/
│   │   ├── database.py   ← Async engine + NullPool (pgbouncer compatible)
│   │   └── models.py     ← SQLAlchemy ORM tables
│   ├── models/
│   │   └── schemas.py    ← Pydantic v2 request/response models
│   ├── routes/
│   │   ├── session.py       ← POST /session/start, POST /session/end
│   │   ├── challenge.py     ← POST /challenge/submit
│   │   ├── progress.py      ← GET /progress/{user_id}
│   │   ├── leaderboard.py   ← GET /leaderboard
│   │   ├── user.py          ← POST /user/register, POST /user/login, PUT /user/update
│   │   └── achievements.py  ← GET /achievements/{user_id}
│   └── services/
│       └── game_logic.py ← evaluate_answer, calculate_score, update_streak
├── .env                  ← Local environment variables (never commit)
├── .env.example          ← Safe template
├── Procfile              ← Railway start command
└── requirements.txt
```

---

## 🗄 Database Schema

### users
| Column | Type | Notes |
|--------|------|-------|
| id | UUID | Primary key |
| username | String | Display name |
| email | String | Unique, for login |
| password_hash | String | SHA-256 with salt |
| avatar_name | String | e.g. "دولفي" |
| avatar_emoji | String | e.g. "🐬" |
| created_at | DateTime | |

### sessions
| Column | Type | Notes |
|--------|------|-------|
| id | UUID | Primary key |
| user_id | UUID | FK → users |
| mode | Enum | letter / word / challenge / free |
| score | Integer | Session score |
| streak | Integer | Current streak |
| created_at | DateTime | |
| ended_at | DateTime | Nullable |

### progress
| Column | Type | Notes |
|--------|------|-------|
| user_id | UUID | FK → users (unique) |
| total_score | Integer | All-time score |
| best_streak | Integer | All-time best streak |
| letters_practiced | JSON | `{"ba": 10, "al": 5}` |
| updated_at | DateTime | |

### attempts
| Column | Type | Notes |
|--------|------|-------|
| id | UUID | Primary key |
| user_id | UUID | FK → users |
| session_id | UUID | FK → sessions |
| mode | Enum | |
| target | String | Expected letter/word |
| answer | String | Model prediction |
| correct | Boolean | |
| confidence | Float | 0.0 – 1.0 |
| time_taken | Float | Seconds |
| created_at | DateTime | |

### achievements
| Column | Type | Notes |
|--------|------|-------|
| id | UUID | Primary key |
| user_id | UUID | FK → users |
| code | String | See codes below |
| unlocked | Boolean | |
| unlocked_at | DateTime | Nullable |

**Achievement codes:** `first_letter` · `pro_speller` · `sign_speaker` · `challenge_hero` · `fire_streak` · `leaderboard_star`

---

## 📡 API Endpoints

### User
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/user/register` | Register new user with email + password + avatar |
| POST | `/user/login` | Login with email + password |
| PUT | `/user/update` | Update name, password, or avatar |
| GET | `/user/{user_id}` | Get user info |

### Session
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/session/start` | Start a new game session |
| POST | `/session/end` | End session and save results |

### Challenge
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/challenge/submit` | Submit a letter/word answer |

### Progress & Stats
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/progress/{user_id}` | Full progress with rank + achievements + avatar |
| GET | `/leaderboard` | Top 10 users by score |
| GET | `/achievements/{user_id}` | All 6 achievements with unlock status |

---

## 🎮 Game Logic

```python
# Accept answer only if confidence >= 0.80
evaluate_answer(target, answer, confidence) → bool

# base_score=10 + time_bonus=max(0, int((10 - time_taken) * 0.5))
calculate_score(correct, time_taken) → int

# correct → streak+1 | wrong → streak=0
update_streak(current_streak, correct) → int
```

### Achievement Auto-unlock Conditions
| Achievement | Condition |
|-------------|-----------|
| first_letter | letters_count >= 1 |
| pro_speller | 5 words completed |
| sign_speaker | 1 attempt with mode="free" |
| challenge_hero | 3 correct challenge attempts |
| fire_streak | best_streak >= 5 |
| leaderboard_star | rank <= 3 |

---

## 📦 Standard Response Format

All endpoints return:
```json
{
  "success": true,
  "data": {},
  "message": "OK"
}
```

---

## ⚙️ Configuration

```env
DATABASE_URL=postgresql+asyncpg://...supabase...
CONFIDENCE_THRESHOLD=0.80
COOLDOWN_SECONDS=1.0
NO_HAND_TIMEOUT=2.0
```

---

## 🏃 Run Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Start server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Open docs
open http://localhost:8000/docs
```

---

## 🔗 Related Repositories

- **Flutter App:** Contains MobileNetV2 TFLite model + MediaPipe Hand Landmarker
- **ML Training:** Google Colab notebook — ArASL2018 dataset, 54,049 images, 32 classes, 98.91% test accuracy

---

## 👥 Team

Built with ❤️ for deaf and hard-of-hearing children in Saudi Arabia — aligned with Vision 2030 inclusion goals.