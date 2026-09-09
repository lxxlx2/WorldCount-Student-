#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

HADOOP_HOME="${HADOOP_HOME:-/opt/homebrew/opt/hadoop/libexec}"
# 默认固定使用 Hadoop 3.5.0 的 Homebrew 依赖 JDK 17；如有需要可通过
# HADOOP_JAVA_HOME 显式覆盖，避免继承系统中不兼容的 JAVA_HOME。
JAVA_HOME="${HADOOP_JAVA_HOME:-/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home}"
export HADOOP_HOME JAVA_HOME
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin:$PATH"
export HADOOP_CONF_DIR="$PWD/conf"

STUDENT_ID="${STUDENT_ID:-student_demo}"
HDFS_BASE="/user/$STUDENT_ID"
LOG_DIR="$PWD/logs"
RESULT_DIR="$PWD/result"
mkdir -p "$LOG_DIR" "$RESULT_DIR"

if ! jps | grep -q NameNode; then
  if [ ! -d /tmp/hadoop-wordcount-practice/name/current ]; then
    hdfs namenode -format -force -nonInteractive > "$LOG_DIR/format.log" 2>&1
  fi
  hdfs --daemon start namenode
  hdfs --daemon start datanode
  # NameNode 重启后会短暂进入安全模式；等待退出后再修改 HDFS 内容。
  hdfs dfsadmin -safemode wait > "$LOG_DIR/safemode.log" 2>&1
fi

{
  echo "Hadoop version"
  hadoop version | head -n 2
  echo
  echo "Java version"
  java -version 2>&1 | head -n 2
  echo
  echo "Hadoop processes"
  jps
} | tee "$LOG_DIR/environment.log"

hdfs dfs -rm -r -f "$HDFS_BASE/input" "$HDFS_BASE/output" >/dev/null 2>&1 || true
hdfs dfs -mkdir -p "$HDFS_BASE/input"
hdfs dfs -put input/*.txt "$HDFS_BASE/input/"
hdfs dfs -ls "$HDFS_BASE/input" | tee "$LOG_DIR/hdfs_input.log"

EXAMPLE_JAR=$(find "$HADOOP_HOME/share/hadoop/mapreduce" -name 'hadoop-mapreduce-examples-*.jar' | head -n 1)
hadoop jar "$EXAMPLE_JAR" wordcount "$HDFS_BASE/input" "$HDFS_BASE/output" \
  2>&1 | tee "$LOG_DIR/wordcount.log"

hdfs dfs -get -f "$HDFS_BASE/output/part-r-00000" "$RESULT_DIR/downloaded-part-r-00000"
cp "$RESULT_DIR/downloaded-part-r-00000" "$RESULT_DIR/part-r-00000"
cat "$RESULT_DIR/part-r-00000"

awk '{sum += $2} END {print "单词总数:", sum}' "$RESULT_DIR/part-r-00000" | tee "$RESULT_DIR/summary.txt"
awk 'END {print "不同单词数量:", NR}' "$RESULT_DIR/part-r-00000" | tee -a "$RESULT_DIR/summary.txt"
sort -k2,2nr -k1,1 "$RESULT_DIR/part-r-00000" | head -n 5 \
  | tee "$RESULT_DIR/top5.txt"
hdfs dfsadmin -report > "$LOG_DIR/dfsadmin-report.log"

echo "WORDCOUNT_VERIFY=PASS"
