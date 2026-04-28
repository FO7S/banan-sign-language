import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from app.db.database import engine
from app.db.models import Base
from app.routes import achievements, challenge, leaderboard, progress, session, user
from app.routes.detect import router as detect_router
from app.routes.classify import router as classify_router

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
            await conn.execute(text(
                "ALTER TABLE sessions ADD COLUMN IF NOT EXISTS ended_at TIMESTAMPTZ"
            ))
            await conn.execute(text(
                "ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT"
            ))
            await conn.execute(text(
                "ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT"
            ))
            await conn.execute(text(
                "ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_name TEXT"
            ))
            await conn.execute(text(
                "ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_emoji TEXT"
            ))
        logger.info("Database tables verified / created")
    except Exception as e:
        logger.warning(
            f"Startup DB check failed — server will still run: {e}"
        )
    yield
    try:
        await engine.dispose()
        logger.info("Database engine disposed")
    except Exception:
        pass


app = FastAPI(
    title="Banan API",
    description="Backend for Banan — Arabic Sign Language learning game",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(session.router)
app.include_router(challenge.router)
app.include_router(progress.router)
app.include_router(leaderboard.router)
app.include_router(user.router)
app.include_router(achievements.router)
app.include_router(detect_router, prefix="/detect", tags=["detect"])
app.include_router(classify_router, prefix="/classify", tags=["classify"])


@app.get("/health")
async def health_check():
    return {"status": "ok", "app": "Banan API"}
