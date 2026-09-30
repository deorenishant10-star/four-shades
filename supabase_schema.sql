-- =====================================================================
-- SMART EXAM EVALUATOR & REMEDIAL GENERATOR - SUPABASE SCHEMA MIGRATION
-- Run this script in the Supabase Dashboard SQL Editor (https://supabase.com/dashboard/project/egpbyaqiokxkajkrbltr/sql)
-- =====================================================================

-- 1. Profiles / Students Table
CREATE TABLE IF NOT EXISTS public.students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    student_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    roll_number VARCHAR(50),
    class_grade VARCHAR(50) DEFAULT 'Class 10',
    stream VARCHAR(50) DEFAULT 'General',
    streak INT DEFAULT 1,
    total_points INT DEFAULT 100,
    badges TEXT[] DEFAULT ARRAY['Welcome Scholar'],
    last_active_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Exam Evaluations Table
CREATE TABLE IF NOT EXISTS public.evaluations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id VARCHAR(50) NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    roll_number VARCHAR(50),
    subject VARCHAR(100) NOT NULL,
    exam_name VARCHAR(255),
    total_marks_obtained NUMERIC(5,2) NOT NULL,
    max_marks NUMERIC(5,2) NOT NULL,
    percentage NUMERIC(5,2) NOT NULL,
    grade VARCHAR(20) NOT NULL,
    status VARCHAR(50) NOT NULL,
    identified_weak_areas JSONB DEFAULT '[]'::jsonb,
    remedial_problems JSONB DEFAULT '[]'::jsonb,
    question_evaluations JSONB DEFAULT '[]'::jsonb,
    pdf_url TEXT,
    evaluated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Daily Quiz Attempts Table
CREATE TABLE IF NOT EXISTS public.quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id VARCHAR(50) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    class_grade VARCHAR(50) DEFAULT 'Class 10',
    score INT NOT NULL,
    total_questions INT NOT NULL,
    percentage NUMERIC(5,2) NOT NULL,
    points_earned INT DEFAULT 0,
    answers JSONB DEFAULT '[]'::jsonb,
    attempted_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_attempts ENABLE ROW LEVEL SECURITY;

-- 5. Create Permissive Policies for Service Role & Authenticated Reads
DO $$
BEGIN
    -- Public / Authenticated read policies
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow public read access to evaluations') THEN
        CREATE POLICY "Allow public read access to evaluations" ON public.evaluations FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow service role full access to evaluations') THEN
        CREATE POLICY "Allow service role full access to evaluations" ON public.evaluations FOR ALL USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow public read access to quiz_attempts') THEN
        CREATE POLICY "Allow public read access to quiz_attempts" ON public.quiz_attempts FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow service role full access to quiz_attempts') THEN
        CREATE POLICY "Allow service role full access to quiz_attempts" ON public.quiz_attempts FOR ALL USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow public read access to students') THEN
        CREATE POLICY "Allow public read access to students" ON public.students FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow service role full access to students') THEN
        CREATE POLICY "Allow service role full access to students" ON public.students FOR ALL USING (true);
    END IF;
END $$;

-- 6. Indexes for High Performance Queries
CREATE INDEX IF NOT EXISTS idx_evaluations_student_id ON public.evaluations(student_id);
CREATE INDEX IF NOT EXISTS idx_evaluations_subject ON public.evaluations(subject);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_student_id ON public.quiz_attempts(student_id);
CREATE INDEX IF NOT EXISTS idx_students_email ON public.students(email);
