USE student_course_management;
SELECT * FROM vw_student_course_score ORDER BY student_id,course_name LIMIT 15;
SELECT INDEX_NAME,COLUMN_NAME,SEQ_IN_INDEX FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA='student_course_management' AND TABLE_NAME='tblScore'
ORDER BY INDEX_NAME,SEQ_IN_INDEX;
