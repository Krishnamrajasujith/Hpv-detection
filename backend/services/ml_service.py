import os
import io
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

MODEL_PATH = os.getenv("MODEL_PATH", os.path.join(os.path.dirname(__file__), "..", "hpv_model.pkl"))

TOP_GENES = [
    "CXCL8", "CXCL10", "CCL20", "IFIT1", "MX1", "OAS1", "ISG15", "RSAD2",
    "IFIT2", "IFIT3", "BST2", "XAF1", "CXCL9", "CXCL11", "IRF7", "STAT1",
    "IRF1", "GBP1", "HLA-F", "TAP1", "PSMB9", "SAMD9", "USP18", "DDX58",
    "IFIH1", "MDA5", "CXCL2", "CXCR4",
]


class VirusDetector:
    def __init__(self):
        self.model = None
        self.scaler = None
        self.trained_genes: list[str] = TOP_GENES[:]
        self.load_model()

    def load_model(self):
        if not os.path.exists(MODEL_PATH):
            return
        try:
            saved = joblib.load(MODEL_PATH)
            if isinstance(saved, dict):
                # New format: {"model": ..., "scaler": ..., "genes": [...]}
                self.model = saved.get("model")
                self.scaler = saved.get("scaler")
                self.trained_genes = saved.get("genes", TOP_GENES[:])
            else:
                # Legacy format: bare sklearn model saved directly
                self.model = saved
                self.scaler = None
                self.trained_genes = TOP_GENES[:]
        except Exception:
            pass

    def is_trained(self) -> bool:
        return self.model is not None

    def train_model(self, file_bytes: bytes) -> dict:
        df = pd.read_csv(io.BytesIO(file_bytes))
        df.columns = [c.strip() for c in df.columns]

        if "HPV_Status" not in df.columns:
            raise ValueError("CSV must contain an 'HPV_Status' column.")

        genes_present = [g for g in TOP_GENES if g in df.columns]
        if not genes_present:
            raise ValueError("No recognised gene columns found in the uploaded CSV.")

        # Fill any missing gene columns with 0 so every sample has all TOP_GENES
        for g in TOP_GENES:
            if g not in df.columns:
                df[g] = 0.0
        genes_present = TOP_GENES[:]  # always train on all 28

        X = df[genes_present].fillna(0).values
        y = (df["HPV_Status"].str.lower().str.strip() == "positive").astype(int).values

        scaler = StandardScaler()
        X_scaled = scaler.fit_transform(X)
        X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)

        clf = HistGradientBoostingClassifier(max_iter=200, random_state=42)
        clf.fit(X_train, y_train)
        accuracy = float(clf.score(X_test, y_test))

        joblib.dump({"model": clf, "scaler": scaler, "genes": genes_present}, MODEL_PATH)
        self.model = clf
        self.scaler = scaler
        self.trained_genes = genes_present

        return {"accuracy": round(accuracy * 100, 2), "samples": len(df)}

    def predict(self, file_bytes: bytes) -> tuple[float, dict]:
        if not self.is_trained():
            raise RuntimeError("Model not trained yet. Please train the model first.")

        df = pd.read_csv(io.BytesIO(file_bytes))
        df.columns = [c.strip() for c in df.columns]

        # Align to exactly the genes the model was trained on (fill missing with 0)
        for g in self.trained_genes:
            if g not in df.columns:
                df[g] = 0.0

        row = df[self.trained_genes].fillna(0).iloc[0]
        X = row.values.reshape(1, -1)

        # Apply scaler only if one was saved with the model
        X_input = self.scaler.transform(X) if self.scaler is not None else X

        proba = self.model.predict_proba(X_input)[0]
        # proba[1] = probability of positive class
        confidence = float(proba[1]) * 100

        feature_values = {g: float(row[g]) for g in self.trained_genes}

        return confidence, feature_values


detector = VirusDetector()

_SEED_CSV = os.path.join(os.path.dirname(__file__), "..", "seed_training.csv")


def auto_train_if_needed():
    if detector.is_trained():
        return
    if not os.path.exists(_SEED_CSV):
        return
    with open(_SEED_CSV, "rb") as f:
        result = detector.train_model(f.read())
    print(f"[HPV DetectAI] Auto-trained from seed data — {result['samples']} samples, accuracy {result['accuracy']}%")


def get_risk(confidence: float) -> tuple[str, str]:
    if confidence >= 75:
        return "HPV Positive", "High Risk"
    if confidence >= 45:
        return "HPV Positive", "Moderate Risk"
    return "HPV Negative", "Low Risk"
