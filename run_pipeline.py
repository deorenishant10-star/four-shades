import argparse
import sys
from pathlib import Path

# Ensure safe console output for Devanagari and Unicode strings
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

# Add project root to sys.path
sys.path.insert(0, str(Path(__file__).resolve().parent))

from src.pipeline import SmartExamPipeline
from src.config import SUPPORTED_SUBJECTS, DEFAULT_OCR_ENGINE, DEFAULT_EVALUATOR_MODE, MOCK_DATA_DIR


def main():
    parser = argparse.ArgumentParser(
        description="Smart Exam Evaluator & Remedial Generator Pipeline (Class 10)"
    )
    parser.add_argument(
        "--subject",
        choices=SUPPORTED_SUBJECTS + ["all"],
        default="all",
        help="Target subject to evaluate (English, Marathi, Science, Mathematics, or all)."
    )
    parser.add_argument(
        "--mode",
        choices=["auto", "llm", "rule"],
        default=DEFAULT_EVALUATOR_MODE,
        help="Evaluator engine mode: 'auto' (detects API key), 'llm' (requires key), or 'rule' (offline deterministic)."
    )
    parser.add_argument(
        "--ocr",
        choices=["mock", "tesseract", "vision"],
        default=DEFAULT_OCR_ENGINE,
        help="OCR transcription engine: 'mock' (simulated offline), 'tesseract' (local binary), 'vision' (Gemini vision)."
    )
    parser.add_argument(
        "--manifest",
        type=str,
        default=None,
        help="Path to JSON manifest specifying batch files and student metadata."
    )
    parser.add_argument(
        "--scan-dir",
        type=str,
        default=None,
        help="Path to directory containing scanned exam papers (PNG/JPG/PDF)."
    )
    parser.add_argument(
        "--reports-dir",
        type=str,
        default=None,
        help="Custom destination directory for generated PDF reports."
    )
    parser.add_argument(
        "--evaluations-dir",
        type=str,
        default=None,
        help="Custom destination directory for generated JSON evaluations."
    )
    parser.add_argument(
        "--gemini-key",
        type=str,
        default=None,
        help="Google Gemini API key (defaults to GEMINI_API_KEY environment variable)."
    )

    args = parser.parse_args()

    print("=" * 70)
    print("  SMART EXAM EVALUATOR & REMEDIAL GENERATOR (CLASS 10)")
    print("=" * 70)
    print(f"[*] OCR Engine:        {args.ocr.upper()}")
    print(f"[*] Evaluator Mode:    {args.mode.upper()}")
    print(f"[*] Target Subject:    {args.subject.upper()}")

    # Initialize Pipeline
    pipeline = SmartExamPipeline(
        ocr_engine=args.ocr,
        evaluator_mode=args.mode,
        reports_dir=args.reports_dir,
        evaluations_dir=args.evaluations_dir,
        gemini_api_key=args.gemini_key
    )

    results = []
    if args.manifest:
        print(f"[*] Ingesting batch manifest: {args.manifest}")
        submissions = pipeline.ingestion_module.ingest_batch_manifest(args.manifest)
        if args.subject != "all":
            submissions = [s for s in submissions if s.subject.lower() == args.subject.lower()]
        results = pipeline.process_batch(submissions)

    elif args.scan_dir:
        print(f"[*] Ingesting directory scans from: {args.scan_dir}")
        submissions = pipeline.ingestion_module.ingest_directory_scans(
            args.scan_dir,
            default_subject="English" if args.subject == "all" else args.subject
        )
        results = pipeline.process_batch(submissions)

    else:
        print("[*] No manifest or scan directory specified. Running standard verification batch...")
        all_results = pipeline.run_mock_verification_batch()
        if args.subject != "all":
            results = [r for r in all_results if r["subject"].lower() == args.subject.lower()]
        else:
            results = all_results

    print("\n" + "=" * 70)
    print("  EVALUATION BATCH SUMMARY")
    print("=" * 70)
    for r in results:
        print(
            f"- {r['student_name']:<25} | Subject: {r['subject']:<12} | "
            f"Score: {r['score']:>4.1f}/{r['max_marks']:<4.1f} ({r['percentage']:>5.1f}%) | "
            f"Grade: {r['grade']} | {r['status']}"
        )
        print(f"  --> Report: {r['pdf_path']}")

    print(f"\n[SUCCESS] Processed {len(results)} student examination paper(s).")
    print("=" * 70)


if __name__ == "__main__":
    main()
