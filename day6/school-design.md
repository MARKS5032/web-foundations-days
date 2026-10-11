# School Database Design

## 1. Tables and Entities

### Students table

The `students` table stores information about each student. It contains `student_id`, `name`, and `email`. The student ID is the primary key, which uniquely identifies each student. The email is also unique so that two students cannot register with the same email address. The name and email fields cannot be NULL.

### Courses table

The `courses` table stores information about courses offered by the school. It contains `course_id`, `course_name`, and `course_code`. The course ID is the primary key, and the course code is unique. The course name and course code are required fields.

### Enrolments table

The `enrolments` table records which students are taking which courses. It contains `enrolment_id`, `student_id`, `course_id`, and `grade`. The enrolment ID is the primary key. The student ID and course ID are foreign keys referencing the students and courses tables. The grade stores the student's result for that course and can be NULL until a grade is assigned.

The combination of `student_id` and `course_id` is UNIQUE. This prevents the same student from enrolling in the same course more than once.

## 2. Relationships

### One-to-many relationship

A student can have many enrolment records, but each enrolment belongs to one student. This creates a one-to-many relationship between students and enrolments.

Similarly, one course can have many enrolment records, but each enrolment belongs to one course. This creates a one-to-many relationship between courses and enrolments.

### Many-to-many relationship

Students and courses have a many-to-many relationship because one student can take several courses, and one course can have many students.

A join table called `enrolments` is needed to represent this relationship in a relational database. It connects the two tables through foreign keys and stores additional information, such as the grade earned by a student in a course.

## 3. Index

I would add an index on `enrolments.course_id` to make it faster to find students enrolled in a particular course and to retrieve enrolment records for that course. This can improve query performance when the database contains many enrolments.

## 4. SQL or NoSQL?

I would choose SQL for this school database because the data is structured and has clear relationships between students, courses, and enrolments. A relational database supports primary keys, foreign keys, UNIQUE constraints, and JOIN queries, which help maintain data integrity and avoid duplicate enrolments. SQL is also suitable for counting students per course and updating grades. A NoSQL database can be useful for flexible or rapidly changing data structures, but a relational database such as SQLite is a better fit for this system.
