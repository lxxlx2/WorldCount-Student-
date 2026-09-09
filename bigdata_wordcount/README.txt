14899《大数据技术基础（实践）》题目三：Hadoop 平台搭建与 WordCount

重要说明
- 本题实践要求在 Linux 环境完成，建议 Ubuntu 22.04/24.04 或 CentOS。
- 旧版本在 macOS Homebrew Hadoop 上执行，虽然命令可运行，但与题目规定的 Linux 环境不一致，不应作为最终提交证据。
- 正式运行必须把 STUDENT_ID 设置为本人准考证号，HDFS 个人目录应为 /user/准考证号/。
- 报告中的运行截图必须由本人在真实终端、HDFS Web 页面中实际截取。不得用脚本把日志文字绘制成“终端截图”。

推荐环境
- Ubuntu Linux
- Apache Hadoop 3.x
- OpenJDK 11 或 17
- HDFS 单节点伪分布式模式，副本数 1
- Hadoop 自带 MapReduce WordCount 示例

运行前检查
1. java -version
2. hadoop version
3. HADOOP_HOME 已指向 Hadoop 安装目录，例如 /usr/local/hadoop
4. conf/core-site.xml、conf/hdfs-site.xml、conf/mapred-site.xml 已作为当前 HADOOP_CONF_DIR 使用
5. Linux 可以访问 http://<Linux-IP>:9870

运行方法
1. 赋予执行权限：chmod +x run_wordcount.sh stop_hdfs.sh
2. 使用本人准考证号运行：
   STUDENT_ID=你的准考证号 HADOOP_HOME=/usr/local/hadoop ./run_wordcount.sh
3. 查看 HDFS Web 界面：http://<Linux-IP>:9870
4. 完成后可停止进程：./stop_hdfs.sh

脚本覆盖的 HDFS 操作
- mkdir：创建个人 input 目录
- put：上传 3 个输入文件
- ls：查看目录和输出文件
- cat：查看 HDFS 文件内容
- cp：复制 HDFS 文件
- mv：移动/重命名 HDFS 文件
- get：从 HDFS 下载文件
- rm：删除 HDFS 文件/旧目录
- dfsadmin -report：查看 HDFS 容量和 DataNode 状态

项目材料
- conf/：core-site.xml、hdfs-site.xml、mapred-site.xml
- input/：3 个输入文本文件
- result/part-r-00000：WordCount 原始结果
- result/summary.txt：单词总数、不同单词数量
- result/top5.txt：出现次数最多的 5 个单词
- logs/all-commands.log：关键命令和输出
- logs/environment.log：Linux、Hadoop、JDK、jps 信息
- logs/wordcount.log：MapReduce 运行日志
- logs/dfsadmin-report.log：HDFS 容量报告

正式提交前必须重新获取真实截图
建议至少包括：Linux 系统、java -version、hadoop version、配置文件、Hadoop 启动、jps、HDFS mkdir/put/ls/cat/cp/mv/get/rm、9870 Web 页面、WordCount 命令、运行成功状态、part-r-00000 和 Top 5 统计。
