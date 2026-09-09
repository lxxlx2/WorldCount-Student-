#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# 本实践题目明确要求在 Linux 环境完成。为避免再次生成不符合要求的 macOS 结果，
# 脚本在非 Linux 系统直接退出。
if [[ "$(uname -s)" != "Linux" ]]; then
  echo "ERROR: 14899 实践要求使用 Linux（Ubuntu/CentOS）。请在 Linux 环境运行本脚本。" >&2
  exit 2
fi

# 正式实践必须使用本人准考证号作为 HDFS 个人目录。
: "${STUDENT_ID:?请先设置 STUDENT_ID=你的准考证号，例如 STUDENT_ID=123456789012 ./run_wordcount.sh}"
if [[ "$STUDENT_ID" == "student_demo" || "$STUDENT_ID" == "EXAM_ID" ]]; then
  echo "ERROR: STUDENT_ID 仍为占位值，请改为本人准考证号。" >&2
  exit 2
fi

HADOOP_HOME="${HADOOP_HOME:-/usr/local/hadoop}"
if [[ ! -x "$HADOOP_HOME/bin/hadoop" ]]; then
  echo "ERROR: 未找到 $HADOOP_HOME/bin/hadoop，请正确设置 HADOOP_HOME。" >&2
  exit 2
fi

if [[ -z "${JAVA_HOME:-}" ]]; then
  JAVA_BIN="$(readlink -f "$(command -v java)")"
  JAVA_HOME="$(dirname "$(dirname "$JAVA_BIN")")"
fi
export HADOOP_HOME JAVA_HOME
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin:$PATH"
export HADOOP_CONF_DIR="$PWD/conf"

HDFS_BASE="/user/$STUDENT_ID"
LOG_DIR="$PWD/logs"
RESULT_DIR="$PWD/result"
mkdir -p "$LOG_DIR" "$RESULT_DIR"
: > "$LOG_DIR/all-commands.log"

run() {
  printf '\n$ ' | tee -a "$LOG_DIR/all-commands.log"
  printf '%q ' "$@" | tee -a "$LOG_DIR/all-commands.log"
  printf '\n' | tee -a "$LOG_DIR/all-commands.log"
  "$@" 2>&1 | tee -a "$LOG_DIR/all-commands.log"
}

# 仅在本实践专用 NameNode 数据目录不存在时格式化，避免误格式化已有 HDFS。
if ! jps | grep -q '[N]ameNode'; then
  if [[ ! -d /tmp/hadoop-wordcount-practice/name/current ]]; then
    hdfs namenode -format -force -nonInteractive > "$LOG_DIR/format.log" 2>&1
  fi
  run hdfs --daemon start namenode
  run hdfs --daemon start datanode
  run hdfs --daemon start secondarynamenode
  hdfs dfsadmin -safemode wait > "$LOG_DIR/safemode.log" 2>&1
fi

{
  echo "Operating system"
  uname -a
  if [[ -f /etc/os-release ]]; then cat /etc/os-release; fi
  echo
  echo "Hadoop version"
  hadoop version | head -n 3
  echo
  echo "Java version"
  java -version 2>&1 | head -n 3
  echo
  echo "Hadoop processes"
  jps
} | tee "$LOG_DIR/environment.log"

# 清理本次实践自己的旧目录，保证重复运行时结果一致。
run hdfs dfs -rm -r -f "$HDFS_BASE/input" "$HDFS_BASE/output" || true
run hdfs dfs -rm -f "$HDFS_BASE/article1_copy.txt" "$HDFS_BASE/article1_moved.txt" || true

# HDFS 基础操作：mkdir、put、ls、cat、cp、mv、get、rm。
run hdfs dfs -mkdir -p "$HDFS_BASE/input"
run hdfs dfs -put input/article1.txt input/article2.txt input/article3.txt "$HDFS_BASE/input/"
run hdfs dfs -ls "$HDFS_BASE/input"
run hdfs dfs -cat "$HDFS_BASE/input/article1.txt"
run hdfs dfs -cp "$HDFS_BASE/input/article1.txt" "$HDFS_BASE/article1_copy.txt"
run hdfs dfs -mv "$HDFS_BASE/article1_copy.txt" "$HDFS_BASE/article1_moved.txt"
run hdfs dfs -get -f "$HDFS_BASE/article1_moved.txt" "$RESULT_DIR/downloaded-input.txt"
run hdfs dfs -rm -f "$HDFS_BASE/article1_moved.txt"

hdfs dfs -ls "$HDFS_BASE/input" > "$LOG_DIR/hdfs_input.log" 2>&1
hdfs dfsadmin -report > "$LOG_DIR/dfsadmin-report.log" 2>&1

EXAMPLE_JAR="$(find "$HADOOP_HOME/share/hadoop/mapreduce" -name 'hadoop-mapreduce-examples-*.jar' | head -n 1)"
if [[ -z "$EXAMPLE_JAR" ]]; then
  echo "ERROR: 未找到 hadoop-mapreduce-examples-*.jar" >&2
  exit 3
fi

printf '\n$ hadoop jar %q wordcount %q %q\n' "$EXAMPLE_JAR" "$HDFS_BASE/input" "$HDFS_BASE/output" \
  | tee -a "$LOG_DIR/all-commands.log"
hadoop jar "$EXAMPLE_JAR" wordcount "$HDFS_BASE/input" "$HDFS_BASE/output" \
  2>&1 | tee "$LOG_DIR/wordcount.log" | tee -a "$LOG_DIR/all-commands.log"

run hdfs dfs -ls "$HDFS_BASE/output"
run hdfs dfs -cat "$HDFS_BASE/output/part-r-00000"
run hdfs dfs -get -f "$HDFS_BASE/output/part-r-00000" "$RESULT_DIR/downloaded-part-r-00000"
cp "$RESULT_DIR/downloaded-part-r-00000" "$RESULT_DIR/part-r-00000"

awk '{sum += $2} END {print "单词总数:", sum}' "$RESULT_DIR/part-r-00000" | tee "$RESULT_DIR/summary.txt"
awk 'END {print "不同单词数量:", NR}' "$RESULT_DIR/part-r-00000" | tee -a "$RESULT_DIR/summary.txt"
sort -k2,2nr -k1,1 "$RESULT_DIR/part-r-00000" | head -n 5 | tee "$RESULT_DIR/top5.txt"

jps | tee "$LOG_DIR/jps.log"

echo "HDFS_BASE=$HDFS_BASE"
echo "NameNode Web UI 通常为 http://<Linux-IP>:9870"
echo "WORDCOUNT_VERIFY=PASS"
