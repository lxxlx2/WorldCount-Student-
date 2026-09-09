USE student_course_management;
SELECT s.student_id AS '学号', s.student_name AS '姓名',
       c.course_name AS '课程名称', sc.usual_score AS '平时成绩',
       sc.final_score AS '期末成绩', sc.total_score AS '总评成绩'
FROM tblStudent AS s
JOIN tblScore AS sc ON sc.student_id = s.student_id
JOIN tblCourse AS c ON c.course_id = sc.course_id
ORDER BY sc.total_score DESC, s.student_id
LIMIT 12;
