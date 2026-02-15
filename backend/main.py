from jose import JWTError, jwt
from datetime import datetime, timedelta
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException, Depends, Header
from pydantic import BaseModel
import pandas as pd
import joblib
from sqlalchemy.orm import Session
import bcrypt
import json

from utils.fertilizer_calc import fertilizer_recommendation
from database import SessionLocal
from models.user import User
from models.prediction_history import PredictionHistory

# =============================
# ===== JWT CONFIG ============
# =============================
SECRET_KEY = "supersecretkey"
ALGORITHM = "HS256"
TOKEN_EXPIRE_MINUTES = 60 * 24

def create_token(user_id: int):
    payload = {
        "sub": str(user_id),
        "exp": datetime.utcnow() + timedelta(minutes=TOKEN_EXPIRE_MINUTES)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


# ✅ SAFE HEADER PARSER (fixes Flutter missing header error)
def get_current_user_id(authorization: str | None = Header(default=None)):
    if authorization is None:
        raise HTTPException(status_code=401, detail="Authorization header missing")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization format")

    token = authorization.replace("Bearer ", "")

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token payload")
        return int(user_id)
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


# =============================
# ===== PASSWORD UTILS =======
# =============================
def hash_password(password: str) -> str:
    password = password.encode("utf-8")[:72]
    return bcrypt.hashpw(password, bcrypt.gensalt()).decode("utf-8")

def verify_password(password: str, hashed: str) -> bool:
    password = password.encode("utf-8")[:72]
    return bcrypt.checkpw(password, hashed.encode("utf-8"))


# =============================
# ===== LOAD ML MODEL =========
# =============================
model, features = joblib.load("model/crop_model.pkl")


# =============================
# ===== LOAD IDEAL NPK ========
# =============================
ideal_df = pd.read_excel("data/crop.xlsx")[["Crop", "N", "P", "K"]]
ideal_df["Crop"] = ideal_df["Crop"].str.strip()


# =============================
# ===== FASTAPI APP ===========
# =============================
app = FastAPI(title="Crop Recommendation API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =============================
# ===== DB DEPENDENCY =========
# =============================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# =============================
# ===== SCHEMAS ===============
# =============================
class SoilInput(BaseModel):
    N: float
    P: float
    K: float
    Temperature: float
    Humidity: float
    pH: float

class CropRecommendation(BaseModel):
    crop: str
    deficiency: dict
    fertilizer_recommendation: list[str]

class PredictionOutput(BaseModel):
    recommendations: list[CropRecommendation]

class RegisterInput(BaseModel):
    username: str
    email: str
    password: str

class LoginInput(BaseModel):
    email: str
    password: str


# =============================
# ===== REGISTER API ==========
# =============================
@app.post("/register")
def register_user(data: RegisterInput, db: Session = Depends(get_db)):

    if db.query(User).filter(User.email == data.email).first():
        raise HTTPException(status_code=400, detail="Email already exists")

    user = User(
        username=data.username,
        email=data.email,
        password=hash_password(data.password)
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return {"message": "User registered successfully"}


# =============================
# ===== LOGIN API =============
# =============================
@app.post("/login")
def login_user(data: LoginInput, db: Session = Depends(get_db)):

    user = db.query(User).filter(User.email == data.email).first()

    if not user:
        raise HTTPException(status_code=400, detail="User not found")

    if not verify_password(data.password, user.password):
        raise HTTPException(status_code=400, detail="Incorrect password")

    token = create_token(user.id)

    return {
        "message": "Login successful",
        "token": token,
        "user": {
            "id": user.id,
            "username": user.username,
            "email": user.email
        }
    }


# =============================
# ===== PREDICT API ===========
# =============================
@app.post("/predict", response_model=PredictionOutput)
def predict_crop(
    data: SoilInput,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id)
):

    try:

        input_df = pd.DataFrame([{
            "N": data.N,
            "P": data.P,
            "K": data.K,
            "Temperature": data.Temperature,
            "Humidity": data.Humidity,
            "pH": data.pH
        }])[features]

        proba = model.predict_proba(input_df)[0]
        classes = model.classes_

        top3_idx = proba.argsort()[-3:][::-1]
        top3_crops = [classes[i] for i in top3_idx]

        results = []

        for crop_name in top3_crops:

            row = ideal_df[ideal_df["Crop"] == crop_name]
            if row.empty:
                continue

            deficiency = {
                "N": max(0, round(row.iloc[0]["N"] - data.N, 2)),
                "P": max(0, round(row.iloc[0]["P"] - data.P, 2)),
                "K": max(0, round(row.iloc[0]["K"] - data.K, 2)),
            }

            fertilizer = fertilizer_recommendation(deficiency)

            results.append({
                "crop": crop_name,
                "deficiency": deficiency,
                "fertilizer_recommendation": fertilizer
            })

        # ✅ SAVE history for logged user
        history = PredictionHistory(
            user_id=user_id,
            N=data.N,
            P=data.P,
            K=data.K,
            Temperature=data.Temperature,
            Humidity=data.Humidity,
            pH=data.pH,
            result=json.dumps(results)
        )

        db.add(history)
        db.commit()

        return {"recommendations": results}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =============================
# ===== HISTORY API ===========
# =============================
@app.get("/history")
def get_history(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id)
):

    records = (
        db.query(PredictionHistory)
        .filter(PredictionHistory.user_id == user_id)
        .order_by(PredictionHistory.id.desc())
        .all()
    )

    return [
        {
            "N": r.N,
            "P": r.P,
            "K": r.K,
            "Temperature": r.Temperature,
            "Humidity": r.Humidity,
            "pH": r.pH,
            "result": json.loads(r.result),
            "created_at": r.created_at
        }
        for r in records
    ]
