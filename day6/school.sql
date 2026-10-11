```sql
-- Day 6 Assignment: A School Database

-- Remove existing tables so the script can be rerun.
DROP TABLE IF EXISTS enrolments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

-- 1. Create the students table.
CREATE TABLE students (
    student_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

-- 2. Create the courses table.
CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY,
    course_name TEXT NOT NULL,
    course_code TEXT NOT NULL UNIQUE
);

-- 3. Create the enrolments table.
-- This join table connects students and courses.
CREATE TABLE enrolments (
    enrolment_id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade TEXT,

    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),

    UNIQUE (student_id, course_id)
);

-- Sample students.
INSERT INTO students (student_id, name, email) VALUES
(1, 'Alice Wanjiku', 'alice@example.com'),
(2, 'Brian Otieno', 'brian@example.com'),
(3, 'Carol Achieng', 'carol@example.com'),
(4, 'David Mwangi', 'david@example.com');

-- Sample courses.
INSERT INTO courses (course_id, course_name, course_code) VALUES
(1, 'Database Systems', 'CCS301'),
(2, 'Web Development', 'CCS302'),
(3, 'Computer Networks', 'CCS303');

-- Sample enrolments.
INSERT INTO enrolments
    (enrolment_id, student_id, course_id, grade)
VALUES
(1, 1, 1, 'A'),
(2, 1, 2, 'B'),
(3, 2, 1, 'B'),
(4, 2, 3, 'A'),
(5, 3, 2, 'A');

-- QUERY 1:
-- Find all courses taken by one student, using their name.
SELECT s.name, c.course_name, e.grade
FROM students AS s
JOIN enrolments AS e ON s.student_id = e.student_id
JOIN courses AS c ON e.course_id = c.course_id
WHERE s.name = 'Alice Wanjiku';

-- QUERY 2:
-- Find all students enrolled on one course.
SELECT c.course_name, s.name, e.grade
FROM courses AS c
JOIN enrolments AS e ON c.course_id = e.course_id
JOIN students AS s ON e.student_id = s.student_id
WHERE c.course_name = 'Database Systems';

-- QUERY 3:
-- Count the students enrolled on each course, including courses
-- that currently have no enrolments.
SELECT
    c.course_name,
    COUNT(e.student_id) AS number_of_students
FROM courses AS c
LEFT JOIN enrolments AS e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name;

-- QUERY 4:
-- Find students who have no enrolments.
SELECT s.student_id, s.name, s.email
FROM students AS s
LEFT JOIN enrolments AS e ON s.student_id = e.student_id
WHERE e.student_id IS NULL;

-- QUERY 5:
-- Update one enrolment's grade.
UPDATE enrolments
SET grade = 'A'
WHERE student_id = 2 AND course_id = 1;

-- Verify the updated grade.
SELECT s.name, c.course_name, e.grade
FROM enrolments AS e
JOIN students AS s ON e.student_id = s.student_id
JOIN courses AS c ON e.course_id = c.course_id
WHERE e.student_id = 2 AND e.course_id = 1;
```
