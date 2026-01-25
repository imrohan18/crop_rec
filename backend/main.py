from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import joblib

from utils.fertilizer_calc import fertilizer_recommendation

# -----------------------------
# Load trained ML model
# -----------------------------
model, features = joblib.load("model/crop_model.pkl")

# -----------------------------
# Load ideal NPK reference
# -----------------------------
ideal_df = pd.read_excel("data/crop.xlsx")[["Crop", "N", "P", "K"]]
ideal_df["Crop"] = ideal_df["Crop"].str.strip()

# -----------------------------
# FastAPI app
# -----------------------------
app = FastAPI(title="Crop Recommendation API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Input schema
# -----------------------------
class SoilInput(BaseModel):
    N: float
    P: float
    K: float
    Temperature: float
    Humidity: float
    pH: float

# -----------------------------
# Output schema
# -----------------------------
class CropRecommendation(BaseModel):
    crop: str
    deficiency: dict
    fertilizer_recommendation: list[str]

class PredictionOutput(BaseModel):
    recommendations: list[CropRecommendation]

# -----------------------------
# Prediction endpoint
# -----------------------------
@app.post("/predict", response_model=PredictionOutput)
def predict_crop(data: SoilInput):
    try:
        # Prepare input
        input_df = pd.DataFrame([{
            "N": data.N,
            "P": data.P,
            "K": data.K,
            "Temperature": data.Temperature,
            "Humidity": data.Humidity,
            "pH": data.pH
        }])[features]

        # Predict probabilities
        proba = model.predict_proba(input_df)[0]
        classes = model.classes_

        # Top-3 crops
        top3_idx = proba.argsort()[-3:][::-1]
        top3_crops = [classes[i] for i in top3_idx]

        results = []

        for crop_name in top3_crops:
            row = ideal_df[ideal_df["Crop"] == crop_name]

            if row.empty:
                continue

            ideal_n = float(row.iloc[0]["N"])
            ideal_p = float(row.iloc[0]["P"])
            ideal_k = float(row.iloc[0]["K"])

            deficiency = {
                "N": max(0, round(ideal_n - data.N, 2)),
                "P": max(0, round(ideal_p - data.P, 2)),
                "K": max(0, round(ideal_k - data.K, 2)),
            }

            fertilizer = fertilizer_recommendation(deficiency)

            results.append({
                "crop": crop_name,
                "deficiency": deficiency,
                "fertilizer_recommendation": fertilizer
            })

        return {"recommendations": results}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
