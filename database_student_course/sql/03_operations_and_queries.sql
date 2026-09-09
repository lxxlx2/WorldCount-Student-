USE student_course_management;

-- DML：修改一门课程的学分。
UPDATE tblCourse
SET credits = 4
WHERE course_id = 'CS0005';

-- DML：插入一条专门用于演示 DELETE 的选课记录，然后删除。
-- 先插入后删除，可以证明 DELETE 已真实执行，同时保留最终有效数据集。
INSERT INTO tblScore(student_id, course_id, usual_score, final_score)
VALUES ('2026000010', 'GE0001', 80, 82);

DELETE FROM tblScore
WHERE student_id = '2026000010' AND course_id = 'GE0001';

-- 查询 1：所有学生基本信息，按学号排序。
SELECT *
FROM tblStudent
ORDER BY student_id;

-- 查询 2：选修“数据库原理”的学生姓名和成绩（多表连接）。
SELECT s.student_name AS 姓名,
       sc.usual_score AS 平时成绩,
       sc.final_score AS 期末成绩,
       sc.total_score AS 总评成绩
FROM tblScore AS sc
JOIN tblStudent AS s ON s.student_id = sc.student_id
JOIN tblCourse AS c ON c.course_id = sc.course_id
WHERE c.course_name = '数据库原理'
ORDER BY sc.total_score DESC;

-- 查询 3：每名学生的选课门数和平均总评成绩（聚合与分组）。
SELECT s.student_id AS 学号,
       s.student_name AS 姓名,
       COUNT(sc.enrollment_id) AS 选课门数,
       ROUND(AVG(sc.total_score), 2) AS 平均总评成绩
FROM tblStudent AS s
LEFT JOIN tblScore AS sc ON sc.student_id = s.student_id
GROUP BY s.student_id, s.student_name
ORDER BY s.student_id;

-- 查询 4：总评成绩在 90 分及以上的学生名单。
SELECT s.student_id AS 学号,
       s.student_name AS 姓名,
       c.course_name AS 课程名,
       sc.total_score AS 总评成绩
FROM tblScore AS sc
JOIN tblStudent AS s ON s.student_id = sc.student_id
JOIN tblCourse AS c ON c.course_id = sc.course_id
WHERE sc.total_score >= 90
ORDER BY sc.total_score DESC, s.student_id;

-- 查询 5：各院系有选课记录的学生人数统计。
SELECT s.department AS 院系,
       COUNT(DISTINCT sc.student_id) AS 选课人数
FROM tblStudent AS s
JOIN tblScore AS sc ON sc.student_id = s.student_id
GROUP BY s.department
ORDER BY 选课人数 DESC, s.department;

-- 查询 6：通过视图查看学生、课程和总评成绩。
SELECT *
FROM vw_student_course_score
ORDER BY student_id, course_name;
