USE student_course_management;

SELECT 'tblStudent' AS table_name, COUNT(*) AS row_count FROM tblStudent
UNION ALL SELECT 'tblCourse', COUNT(*) FROM tblCourse
UNION ALL SELECT 'tblScore', COUNT(*) FROM tblScore;

SELECT COUNT(*) AS invalid_scores
FROM tblScore
WHERE usual_score NOT BETWEEN 0 AND 100
   OR final_score NOT BETWEEN 0 AND 100;

SELECT COUNT(*) AS orphan_scores
FROM tblScore sc
LEFT JOIN tblStudent s ON s.student_id = sc.student_id
LEFT JOIN tblCourse c ON c.course_id = sc.course_id
WHERE s.student_id IS NULL OR c.course_id IS NULL;

SELECT COUNT(*) AS view_rows FROM vw_student_course_score;

SELECT INDEX_NAME, COLUMN_NAME
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'student_course_management'
  AND TABLE_NAME = 'tblScore'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;
