08695《数据库及其应用操作（实践）》题目一：学生选课管理系统

推荐正式环境
- MySQL 8.0 Community Server
- MySQL Workbench（用于表结构、数据、关系和查询结果的真实截图）
- 数据库名：student_course_management
- 字符集：utf8mb4

说明
- SQL 脚本可在 macOS、Windows 或 Linux 上执行；数据库课程本身允许 MySQL 环境。
- 正式报告中的截图必须来自本人实际运行的 MySQL Workbench 或真实命令行界面。
- 不要把 .txt 日志重新绘制成“终端截图”。

运行方法
1. 确认 MySQL 服务已启动，并使用有建库权限的账号登录。
2. 命令行方式可执行：chmod +x run_all.sh && ./run_all.sh
3. 如 root 需要密码，可手工执行 mysql -uroot -p，或按本机账号调整 run_all.sh。
4. 最终截图建议在 MySQL Workbench 中重新执行对应 SQL 后获取。

文件说明
- sql/01_schema.sql：数据库、3 张表、主键/外键、检查约束、索引、视图。
- sql/02_seed.sql：10 名学生、10 门课程、21 条选课成绩。
- sql/03_operations_and_queries.sql：INSERT、UPDATE、DELETE 和 6 类查询。
- sql/04_verification.sql：行数、成绩范围、外键孤儿、视图及索引验证。

与题目模板保持一致的关键点
- tblStudent：7 个指定字段。
- tblCourse：6 个指定字段。
- tblScore：6 个指定字段，不增加“选课日期”等模板外字段。
- total_score：整型生成列，按 平时成绩×30%＋期末成绩×70% 自动计算。
- tblStudent 到 tblScore、tblCourse 到 tblScore 均为 1:N，外键启用级联更新。
- tblScore.student_id 建立索引。
- 视图显示学号、姓名、课程名、总评成绩。

注意
- 01_schema.sql 会先删除同名数据库再重建，仅用于本实践项目。
- 最终报告中的“实践中遇到的问题”应记录本人真实执行时实际遇到的 2～3 个问题，不要直接照搬预写示例。
