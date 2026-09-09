USE student_course_management;
SELECT 'tblStudent' AS table_name, COUNT(*) AS row_count FROM tblStudent
UNION ALL SELECT 'tblCourse', COUNT(*) FROM tblCourse
UNION ALL SELECT 'tblScore', COUNT(*) FROM tblScore;
SELECT COUNT(*) AS invalid_scores
FROM tblScore
WHERE usual_score NOT BETWEEN 0 AND 100
   OR final_score NOT BETWEEN 0 AND 100
   OR total_score NOT BETWEEN 0 AND 100;
