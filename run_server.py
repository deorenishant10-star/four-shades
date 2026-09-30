"""Web Server Launcher for Smart Exam Evaluator & Remedial Generator."""

import sys
from pathlib import Path
import uvicorn

# Add project root to sys.path
BASE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE_DIR))

if __name__ == "__main__":
    print("=" * 70)
    print("  SMART EXAM EVALUATOR & REMEDIAL GENERATOR - WEB APPLICATION")
    print("=" * 70)
    print("  [+] Server starting on:  http://127.0.0.1:8000")
    print("  [+] Local access URL:    http://localhost:8000")
    print("  [+] API Docs (Swagger):  http://127.0.0.1:8000/docs")
    print("=" * 70)
    uvicorn.run("src.web.server:app", host="127.0.0.1", port=8000, reload=False)
