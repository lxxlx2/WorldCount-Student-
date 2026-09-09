USE student_course_management;
SELECT s.student_id AS 学号, s.student_name AS 姓名, COUNT(sc.enrollment_id) AS 选课门数, ROUND(AVG(sc.total_score),2) AS 平均总评成绩
FROM tblStudent s LEFT JOIN tblScore sc ON sc.student_id=s.student_id
GROUP BY s.student_id,s.student_name ORDER BY s.student_id;
