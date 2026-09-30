# Smart Exam Evaluator & Remedial Generator

A production-ready, modular Python backend pipeline and interactive web dashboard for automated ingestion, OCR extraction, rubric-based evaluation, and diagnostic PDF generation for **Classes 7th to 12th** across all academic streams:
- **Science**: Physics, Chemistry, Biology, Mathematics, Computer Science, English Core, Marathi
- **Commerce**: Accountancy, Business Studies, Economics, Mathematics, English Core, Marathi
- **Arts (Humanities)**: History, Political Science, Geography, Economics, Psychology, English, Marathi
- **Middle & Secondary (7th–10th)**: Mathematics, Science, English, Marathi, Social Science, Hindi

---

## 🌐 Live Web Application & Dashboard Links

| Resource | URL |
| :--- | :--- |
| **Interactive Web Dashboard** | **[http://localhost:8000](http://localhost:8000)** or **[http://127.0.0.1:8000](http://127.0.0.1:8000)** |
| **Interactive API Docs (Swagger UI)** | **[http://localhost:8000/docs](http://localhost:8000/docs)** |
| **Alternative API Specs (ReDoc)** | **[http://localhost:8000/redoc](http://localhost:8000/redoc)** |

To launch the web dashboard server at any time:
```powershell
python run_server.py
```

---

## 🚀 Key Features

1. **🌗 Dark Mode & Light Mode Themes:**
   - Seamless one-click toggle switch in the navigation header.
   - Persistent theme state saved in browser storage (`localStorage`).
   - High-contrast visual tokens and modern glassmorphism aesthetic.

2. **🔐 Student Authentication & Persistent Achievements:**
   - Sign in and registration portal for students across Classes 7 to 12.
   - Persistent profile tracking:
     - Cumulative exams evaluated with direct PDF report download links.
     - Average performance percentage and score trends.
     - **Daily active streak** (`🔥 4 Days`).
     - **Earned mastery badges** (e.g. *Physics Explorer*, *Commerce Master*, *High Performer*, *Quiz Master*).

3. **🎓 Complete Academic Coverage (Classes 7 to 12 & All Streams):**
   - Dynamic subject grid that adjusts automatically based on the selected Class Grade and Stream (General, Science, Commerce, Arts).
   - Official Master Grading Keys for Senior Secondary subjects (Physics, Accountancy, History, etc.) in addition to Class 10 subjects.

4. **⚡ Subject Daily Quiz Engine:**
   - Interactive daily 5-question conceptual challenge tailored to each subject.
   - Instant score calculation, option-by-option explanations, and remedial hints.
   - Automatically awards XP points and increases the student's daily streak.

5. **☁️ Supabase Cloud Backend Integration:**
   - **Supabase GoTrue Auth**: Real-time cloud authentication, user signup/login, session tokens, and persistent user metadata.
   - **Supabase Storage**: Automatically uploads generated ReportLab diagnostic PDF scorecards and JSON evaluation reports to the public cloud bucket `reports/`.
   - **Supabase PostgreSQL / PostgREST**: Ready-to-run schema migration (`supabase_schema.sql`) for `students`, `evaluations`, and `quiz_attempts` with Row Level Security (RLS) policies.
   - **Zero-Downtime Resilience**: Seamless hybrid fallback ensures the system works 100% offline or synced with Supabase Cloud.

6. **📄 Automated Diagnostic & Remedial PDF Generation:**
   - ReportLab Platypus engine generating publication-grade multi-page diagnostic cards.
   - Native Unicode Devanagari font rendering (`Nirmala.ttc`) for Marathi and Hindi.
   - Detailed scorecard, question error analysis matrix, and **3 to 5 custom remedial practice problems** targeting identified mistakes.

---

## 📁 Project Structure

```
application/
├── .env                           # Supabase & Evaluator configuration
├── supabase_schema.sql            # Supabase PostgreSQL schema migration script
├── data/
│   ├── grading_keys/              # Master Grading Keys (Class 10 & 12)
│   │   ├── english_class10.json
│   │   ├── marathi_class10.json
│   │   ├── science_class10.json
│   │   ├── mathematics_class10.json
│   │   ├── physics_class12.json
│   │   ├── accountancy_class12.json
│   │   └── history_class12.json
│   ├── mock_data/                 # Batch manifests & mock student data
│   │   └── batch_manifest.json
│   └── sample_scans/              # Target folder for scanned papers
├── output/
│   ├── reports/                   # Publication-ready student PDF reports
│   └── evaluations/               # Structured JSON evaluation exports
├── src/
│   ├── __init__.py
│   ├── config.py                  # Paths, fonts, subject definitions, and API keys
│   ├── models.py                  # Pydantic schemas (Keys, Submissions, Reports)
│   ├── ocr/                       # Ingestion & OCR processing modules
│   │   ├── base.py
│   │   ├── batch_ingestion.py
│   │   ├── mock_ocr.py
│   │   ├── multimodal_ocr.py
│   │   └── tesseract_ocr.py
│   ├── evaluator/                 # LLM evaluation & routing
│   │   ├── base.py
│   │   ├── llm_evaluator.py
│   │   ├── prompts.py
│   │   ├── router.py
│   │   └── rule_evaluator.py
│   ├── generator/                 # ReportLab PDF generation
│   │   ├── font_manager.py
│   │   └── pdf_report.py
│   ├── quiz/                      # Daily quiz question bank & engine
│   │   └── daily_quiz.py
│   ├── auth.py                    # Student authentication & streak manager
│   ├── supabase_client.py         # Supabase GoTrue Auth, Storage & PostgREST client
│   └── pipeline.py                # End-to-end pipeline orchestrator
├── tests/
│   └── test_pipeline_mock.py      # Automated end-to-end verification test suite
├── requirements.txt
├── run_pipeline.py                # Command-line interface (CLI)
└── README.md
```

---

## 🛠️ Installation & Setup

1. **Clone or navigate to the repository:**
   ```powershell
   cd c:\Users\Admin\Documents\application
   ```

2. **Install Python dependencies:**
   ```powershell
   python -m pip install -r requirements.txt
   ```

3. **(Optional) Configure Tesseract OCR for Local Images:**
   - Install Tesseract-OCR with the Marathi language pack (`mar.traineddata`).
   - If installed in a custom directory, set the environment variable:
     ```powershell
     $env:TESSERACT_CMD = "C:\Program Files\Tesseract-OCR\tesseract.exe"
     ```

4. **(Optional) Configure Gemini LLM API Key:**
   ```powershell
   $env:GEMINI_API_KEY = "your-gemini-api-key-here"
   ```

---

## 🚀 Running the Pipeline

### 1. Run Verification Test Suite (Offline)
Runs mock OCR text across all 4 subjects, verifies question segmentation, scores against the Master Grading Keys, and validates generated multi-page PDFs:
```powershell
python tests/test_pipeline_mock.py
```

### 2. Run CLI Pipeline on All Subjects
```powershell
python run_pipeline.py
```

### 3. Evaluate a Single Subject
```powershell
python run_pipeline.py --subject Marathi
python run_pipeline.py --subject English
python run_pipeline.py --subject Science
python run_pipeline.py --subject Mathematics
```

### 4. Process Batch Manifest of Scanned Files
```powershell
python run_pipeline.py --manifest data/mock_data/batch_manifest.json
```

### 5. Process a Directory of Scanned Exam Images
```powershell
python run_pipeline.py --scan-dir data/sample_scans --subject Science --ocr tesseract
```

---

## 📝 Master Grading Keys

Master grading keys reside in `data/grading_keys/` and follow this JSON schema:

```json
{
  "subject": "Mathematics",
  "exam_name": "Class 10 Mathematics Preliminary Examination 2026",
  "total_marks": 15.0,
  "passing_marks": 6.0,
  "questions": [
    {
      "question_id": "Q1",
      "question_text": "Find roots of 2x^2 - 7x + 3 = 0 using quadratic formula.",
      "topic": "Algebra - Quadratic Equations",
      "max_marks": 4.0,
      "rubrics": [
        {
          "criterion": "Discriminant D = b^2 - 4ac",
          "max_marks": 1.5,
          "guidance": "D = (-7)^2 - 4(2)(3) = 25"
        }
      ],
      "model_answer": "D = 25, x = (7 ± 5)/4 => x = 3, 1/2",
      "essential_keywords": ["D = 25", "x = 3", "x = 1/2"],
      "common_misconceptions": ["Sign error in -(-7)"]
    }
  ]
}
```
