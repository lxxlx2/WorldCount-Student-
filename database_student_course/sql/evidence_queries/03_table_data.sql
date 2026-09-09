USE student_course_management;
SELECT 'tblStudent' AS table_name, COUNT(*) AS rows_count FROM tblStudent
UNION ALL SELECT 'tblCourse', COUNT(*) FROM tblCourse
UNION ALL SELECT 'tblScore', COUNT(*) FROM tblScore;
SELECT * FROM tblStudent ORDER BY student_id LIMIT 10;
SELECT * FROM tblCourse ORDER BY course_id LIMIT 10;
