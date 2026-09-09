USE student_course_management;
SELECT s.student_name AS 姓名, sc.usual_score AS 平时成绩, sc.final_score AS 期末成绩, sc.total_score AS 总评成绩
FROM tblScore sc JOIN tblStudent s ON s.student_id=sc.student_id JOIN tblCourse c ON c.course_id=sc.course_id
WHERE c.course_name='数据库原理' ORDER BY sc.total_score DESC;
