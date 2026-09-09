USE student_course_management;
SELECT * FROM vw_student_course_score
ORDER BY total_score DESC, student_id
LIMIT 12;

