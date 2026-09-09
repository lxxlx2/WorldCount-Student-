# 提交前必须处理的合规问题

本分支 `review/assignment-compliance-fixes` 从 `codex/complete-assignments` 派生，用于修正原分支中会影响实践考核真实性和题目匹配度的问题。原分支保留不动。

## 14899 大数据技术基础（实践）

### 已确认的问题

1. 原实践在 macOS Homebrew Hadoop 上运行，而题目明确要求在 Linux（Ubuntu 或 CentOS）环境完成。原报告中“macOS Unix 命令与 Linux 一致”的解释不能替代题目规定的 Linux 实践环境。
2. 原 HDFS 个人目录使用 `/user/student_demo`。正式实践应使用 `/user/本人准考证号/`。
3. 原流程没有完整覆盖题目和评分表中的 HDFS `cp`、`mv`、`rm` 等操作。
4. 原 `tools/build_evidence_images.py` 会把 `.txt` 日志绘制成仿终端 PNG。这些图片不是真实截图，不能作为实践操作截图提交。
5. 原生成报告直接引用上述仿终端图片，且硬编码 macOS、Homebrew、`student_demo` 等信息，因此原 output 中的报告不应直接提交。
6. 原报告使用自定义重写版诚信承诺书。正式版应保持学校模板中的诚信承诺内容，并由考生本人填写和签署。
7. 最终文件名必须按学校要求改为 `专业代码_14899_准考证号_姓名.pdf`。

### 已在本分支修正

- `bigdata_wordcount/run_wordcount.sh` 仅允许 Linux 执行。
- 强制要求设置本人 `STUDENT_ID`。
- 增加 `mkdir / put / ls / cat / cp / mv / get / rm / dfsadmin -report` 的真实 HDFS 操作。
- `bigdata_wordcount/README.txt` 改为 Linux 正式流程。
- 停止从日志生成仿终端截图。
- 已从本分支删除原来由脚本生成的仿终端 PNG。
- 已删除本分支中旧的 Word/PDF/ZIP 输出，避免误提交旧结果。

### 仍需本人完成

1. 在 Ubuntu/CentOS 中真实安装并配置 JDK、Hadoop。
2. 使用本人准考证号重新执行 `run_wordcount.sh`。
3. 在真实终端和 `http://<Linux-IP>:9870` 页面获取截图。
4. 用真实截图和真实运行结果填写学校原实践报告模板。
5. “实践中遇到的问题”只写本次 Linux 重跑时真实发生的问题。
6. 完成知网查重和 AIGC 检测后按学校要求打包。

## 08695 数据库及其应用操作（实践）

### 已确认的问题

1. 原 `tblScore` 增加了模板中没有的 `selected_at` 字段。
2. 原 `total_score` 使用 `DECIMAL(5,2)`，而题目模板要求“整型/自动计算”。
3. 原报告中的运行截图由 `.txt` 输出重新绘制成仿终端图片，不属于真实操作截图。
4. 原报告写的是 MySQL 8.4.11 + 命令行客户端。学校方案列出的推荐组合为 MySQL 8.0 Community Server + Navicat/Workbench；为了降低争议，正式截图建议使用 MySQL 8.0 + MySQL Workbench。
5. 原“实践中遇到的问题”多为预先设计的说明，未能证明这些问题确实在本人实践中发生。正式报告应换成本人实际执行时遇到的 2～3 个真实问题。
6. 原诚信承诺书被重新改写。正式提交应使用学校模板原文并由本人填写签署。
7. 最终文件名必须按学校要求改为 `专业代码_08695_准考证号_姓名.pdf`。

### 已在本分支修正

- `tblScore` 恢复为模板指定的 6 个字段。
- `total_score` 改为整型生成列。
- 更新测试数据和 DML 脚本，与新表结构一致。
- README 改为推荐 MySQL 8.0 + Workbench，并强调真实截图。
- 停止从日志生成仿终端截图。
- 已从本分支删除原来由脚本生成的数据库运行 PNG，保留 E-R 图这种允许自行绘制的设计图。
- 已删除本分支中旧的 Word/PDF/ZIP 输出，避免误提交旧结果。

### 仍需本人完成

1. 用 MySQL 8.0 实际运行 `sql/01_schema.sql` 到 `sql/04_verification.sql`。
2. 确认三张表最终数据分别不少于 10 条。
3. 在 MySQL Workbench 中真实截图：所有表结构、三张表数据、关系图、至少 5 个查询结果、视图与索引。
4. 使用学校原模板填写实践报告，保持固定栏目和诚信承诺书。
5. 记录本人真实遇到的 2～3 个问题及解决过程。
6. 完成知网查重和 AIGC 检测后按学校要求提交。

## 报告排版提醒

学校模板要求 A4，正文宋体小四、1.5 倍行距，一级标题三号黑体、二级标题小三黑体、三级标题四号宋体或黑体，页码连续、图表编号清楚。原自动生成报告使用 Noto Sans SC 等自定义样式，正式提交时建议直接在学校原模板中填写，避免版式和固定内容偏离。
