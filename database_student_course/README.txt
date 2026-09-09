08695《数据库及其应用操作（实践）》题目一：学生选课管理系统

开发环境
- macOS 26.6.2（脚本同样适用于 Linux）
- MySQL 8.4.11，字符集 utf8mb4
- 数据库名：student_course_management

运行方法
1. 确认本机 MySQL 服务已启动，且 root 用户可在本机登录。
2. 若 root 需要密码，请编辑 run_all.sh 中 MYSQL 数组，增加 -p 或改为合适账号。
3. 在本目录执行：chmod +x run_all.sh && ./run_all.sh

文件说明
- sql/01_schema.sql：数据库、3 张表、约束、索引、视图。
- sql/02_seed.sql：10 名学生、10 门课程、21 条选课成绩。
- sql/03_operations_and_queries.sql：UPDATE、DELETE 和 6 类查询。
- sql/04_verification.sql：行数、成绩范围、外键孤儿、视图及索引验证。

注意
- 01_schema.sql 会先删除同名数据库再重建，仅用于本实践项目。
- 总评成绩由生成列自动计算：平时成绩×30%＋期末成绩×70%。
