14899《大数据技术基础（实践）》题目三：Hadoop 平台搭建与 WordCount

开发环境
- macOS 26.6.2（类 Unix 命令与 Linux 一致）
- Apache Hadoop 3.5.0
- OpenJDK 17
- HDFS 伪分布式模式，MapReduce 本地执行模式

运行方法
1. 使用 Homebrew 安装：brew install hadoop
2. 在本目录执行：chmod +x run_wordcount.sh stop_hdfs.sh
3. 可将准考证号作为 HDFS 个人目录名：STUDENT_ID=你的准考证号 ./run_wordcount.sh
4. 查看 HDFS Web 界面：http://localhost:9870
5. 完成后可停止进程：./stop_hdfs.sh

提交内容
- conf/：core-site.xml、hdfs-site.xml、mapred-site.xml
- input/：3 个输入文本文件
- result/part-r-00000：Hadoop WordCount 原始结果
- result/summary.txt：单词总数、不同单词数量
- result/top5.txt：出现次数最多的 5 个单词
- logs/：环境、HDFS、MapReduce 及容量报告日志

注意
- 第一次运行会格式化专用于本实践的 /tmp/hadoop-wordcount-practice 数据目录。
- output 已存在时 Hadoop 会拒绝运行，脚本会在运行前删除本项目自己的旧目录。
