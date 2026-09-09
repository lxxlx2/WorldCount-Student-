-- 08695 数据库及其应用操作（实践）
-- 题目一：学生选课管理系统（MySQL 8.0）
DROP DATABASE IF EXISTS student_course_management;
CREATE DATABASE student_course_management
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE student_course_management;

CREATE TABLE tblStudent (
  student_id CHAR(10) PRIMARY KEY COMMENT '学号',
  student_name VARCHAR(30) NOT NULL COMMENT '姓名',
  gender ENUM('男', '女') NOT NULL COMMENT '性别',
  birth_date DATE NOT NULL COMMENT '出生日期',
  department VARCHAR(50) NOT NULL COMMENT '所在院系',
  enrollment_year YEAR NOT NULL COMMENT '入学年份',
  phone VARCHAR(20) NOT NULL COMMENT '联系电话',
  CONSTRAINT uq_student_phone UNIQUE (phone)
) ENGINE=InnoDB COMMENT='学生表';

CREATE TABLE tblCourse (
  course_id CHAR(6) PRIMARY KEY COMMENT '课程号',
  course_name VARCHAR(60) NOT NULL COMMENT '课程名',
  credits TINYINT UNSIGNED NOT NULL COMMENT '学分',
  class_hours SMALLINT UNSIGNED NOT NULL COMMENT '学时',
  course_type ENUM('必修', '选修', '公选') NOT NULL COMMENT '课程类别',
  offering_department VARCHAR(50) NOT NULL COMMENT '开课院系',
  CONSTRAINT chk_course_credits CHECK (credits BETWEEN 1 AND 6),
  CONSTRAINT chk_course_hours CHECK (class_hours > 0)
) ENGINE=InnoDB COMMENT='课程表';

CREATE TABLE tblScore (
  enrollment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '选课编号',
  student_id CHAR(10) NOT NULL COMMENT '学号',
  course_id CHAR(6) NOT NULL COMMENT '课程号',
  usual_score TINYINT UNSIGNED NOT NULL COMMENT '平时成绩',
  final_score TINYINT UNSIGNED NOT NULL COMMENT '期末成绩',
  total_score DECIMAL(5,2)
    GENERATED ALWAYS AS (ROUND(usual_score * 0.30 + final_score * 0.70, 2)) STORED
    COMMENT '总评成绩',
  selected_at DATE NOT NULL COMMENT '选课日期',
  CONSTRAINT uq_student_course UNIQUE (student_id, course_id),
  CONSTRAINT chk_usual_score CHECK (usual_score BETWEEN 0 AND 100),
  CONSTRAINT chk_final_score CHECK (final_score BETWEEN 0 AND 100),
  CONSTRAINT fk_score_student FOREIGN KEY (student_id)
    REFERENCES tblStudent(student_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_score_course FOREIGN KEY (course_id)
    REFERENCES tblCourse(course_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='选课成绩表';

CREATE INDEX idx_score_student_id ON tblScore(student_id);

CREATE VIEW vw_student_course_score AS
SELECT s.student_id, s.student_name, c.course_name, sc.total_score
FROM tblScore AS sc
JOIN tblStudent AS s ON s.student_id = sc.student_id
JOIN tblCourse AS c ON c.course_id = sc.course_id;
