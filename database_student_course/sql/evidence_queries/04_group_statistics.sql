USE student_course_management;
SELECT s.department AS '院系', COUNT(DISTINCT sc.student_id) AS '选课人数',
       ROUND(AVG(sc.total_score), 2) AS '平均总评成绩'
FROM tblStudent AS s
JOIN tblScore AS sc ON sc.student_id = s.student_id
GROUP BY s.department
ORDER BY `选课人数` DESC, s.department;

