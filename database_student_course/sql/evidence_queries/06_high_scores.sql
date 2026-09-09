USE student_course_management;
SELECT s.student_id AS 学号,s.student_name AS 姓名,c.course_name AS 课程名,sc.total_score AS 总评成绩
FROM tblScore sc JOIN tblStudent s ON s.student_id=sc.student_id JOIN tblCourse c ON c.course_id=sc.course_id
WHERE sc.total_score>=90 ORDER BY sc.total_score DESC,s.student_id;
