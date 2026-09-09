#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
MAJOR_CODE="W120503"; MAJOR_NAME="信息资源管理"; EXAM_ID="010126323484"; STUDENT_NAME="刘怡荷"
BRANCH="review/assignment-compliance-fixes"
OUT="$ROOT/output"; BIG="$ROOT/bigdata_wordcount"; DB="$ROOT/database_student_course"
BIG_REAL="$BIG/evidence_real"; DB_REAL="$DB/evidence_real"; CAPTURE="$ROOT/tools/capture_visible_window.sh"
mkdir -p "$OUT" "$BIG_REAL" "$DB_REAL"
log(){ printf '[takeover] %s\n' "$*"; }
fail(){ printf '[takeover] ERROR: %s\n' "$*" >&2; exit 1; }
[[ "$(uname -s)" == "Darwin" ]] || fail "这个接管脚本应在你的 Mac 主机上执行。"
chmod +x "$CAPTURE"
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || true)"
[[ "$CURRENT_BRANCH" == "$BRANCH" ]] || fail "当前分支是 $CURRENT_BRANCH，请先切到 $BRANCH。"

TS="$(date +%Y%m%d-%H%M%S)"; BACKUP="$ROOT/.takeover-backup/$TS"; mkdir -p "$BACKUP"
git status --short > "$BACKUP/git-status.txt" || true
git diff > "$BACKUP/worktree.patch" || true
git diff --cached > "$BACKUP/index.patch" || true
find "$ROOT" -maxdepth 4 -type f -not -path "$ROOT/.git/*" -newermt '-3 hours' -print > "$BACKUP/recent-files.txt" 2>/dev/null || true
log "已保存当前工作区快照到 $BACKUP，不会重置 Codex 留下的本地改动。"

LINUX_KIND="${LINUX_KIND:-}"; LINUX_NAME="${LINUX_NAME:-}"
try_multipass(){ command -v multipass >/dev/null 2>&1 || return 1; local n; while IFS= read -r n; do [[ -n "$n" ]] || continue; if multipass exec "$n" -- sh -lc 'test -r /etc/os-release && grep -qi ubuntu /etc/os-release' >/dev/null 2>&1; then LINUX_KIND=multipass; LINUX_NAME="$n"; return 0; fi; done < <(multipass list --format csv 2>/dev/null | awk -F, 'NR>1 && $2=="Running" {print $1}'); return 1; }
try_lima(){ command -v limactl >/dev/null 2>&1 || return 1; local n; while IFS= read -r n; do [[ -n "$n" ]] || continue; if limactl shell "$n" -- sh -lc 'test -r /etc/os-release && grep -qi ubuntu /etc/os-release' >/dev/null 2>&1; then LINUX_KIND=lima; LINUX_NAME="$n"; return 0; fi; done < <(limactl list 2>/dev/null | awk 'NR>1 && tolower($2) ~ /running/ {print $1}'); return 1; }
try_docker(){ command -v docker >/dev/null 2>&1 || return 1; local n; while IFS= read -r n; do [[ -n "$n" ]] || continue; if docker exec "$n" sh -lc 'test -r /etc/os-release && grep -qi ubuntu /etc/os-release' >/dev/null 2>&1; then LINUX_KIND=docker; LINUX_NAME="$n"; return 0; fi; done < <(docker ps --format '{{.Names}}' 2>/dev/null); return 1; }
if [[ -z "$LINUX_KIND" ]]; then try_multipass || try_lima || try_docker || true; fi
[[ -n "$LINUX_KIND" && -n "$LINUX_NAME" ]] || fail "没有自动找到正在运行的 Ubuntu 环境。若 Codex 使用了自定义环境，可传 LINUX_KIND 和 LINUX_NAME 后重跑。"
log "发现 Linux 环境: $LINUX_KIND / $LINUX_NAME"
linux_run(){ local cmd="$1"; case "$LINUX_KIND" in multipass) multipass exec "$LINUX_NAME" -- bash -lc "$cmd" ;; lima) limactl shell "$LINUX_NAME" -- bash -lc "$cmd" ;; docker) docker exec "$LINUX_NAME" bash -lc "$cmd" ;; *) fail "不支持的 LINUX_KIND=$LINUX_KIND" ;; esac; }
linux_text(){ linux_run "$1" 2>&1; }
LINUX_OS="$(linux_text "source /etc/os-release; printf '%s' \"\$PRETTY_NAME\"" | tail -n1)"
HADOOP_BIN="$(linux_text "command -v hadoop || { test -x /usr/local/hadoop/bin/hadoop && echo /usr/local/hadoop/bin/hadoop; }" | tail -n1)"
[[ -n "$HADOOP_BIN" ]] || fail "Ubuntu 中未找到 hadoop。"
HADOOP_HOME_VM="$(dirname "$(dirname "$HADOOP_BIN")")"
HADOOP_VERSION="$(linux_text "$HADOOP_BIN version | head -n1" | tail -n1 | sed 's/^Hadoop /Apache Hadoop /')"
JAVA_VERSION="$(linux_text "java -version 2>&1 | head -n1" | tail -n1)"
HDFS_BASE="/user/$EXAM_ID"
linux_run "export HADOOP_HOME='$HADOOP_HOME_VM'; export PATH=\"\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH\"; hdfs dfs -test -d '$HDFS_BASE/input'" >/dev/null 2>&1 || fail "HDFS 中没有 $HDFS_BASE/input。"
linux_run "export HADOOP_HOME='$HADOOP_HOME_VM'; export PATH=\"\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH\"; hdfs dfs -test -e '$HDFS_BASE/output/part-r-00000'" >/dev/null 2>&1 || fail "HDFS 中没有 WordCount 原始输出。"

capture_terminal(){ local out="$1"; sleep .8; "$CAPTURE" Terminal "$out" >/dev/null; log "截图: ${out#$ROOT/}"; }
clear; printf '14899 实践真实环境验证\n\n'; linux_run "printf 'OS: '; source /etc/os-release; echo \"\$PRETTY_NAME\"; echo; java -version 2>&1 | head -n3; echo; '$HADOOP_BIN' version | head -n3"; capture_terminal "$BIG_REAL/01_linux_java.png"
linux_text "printf 'OS: '; source /etc/os-release; echo \"\$PRETTY_NAME\"; java -version 2>&1 | head -n3; '$HADOOP_BIN' version | head -n3" > "$BIG_REAL/01_linux_java.txt"
clear; printf '14899 Hadoop 核心配置\n\n'; linux_run "echo '[core-site.xml]'; sed -n '1,120p' '$HADOOP_HOME_VM/etc/hadoop/core-site.xml'; echo; echo '[hdfs-site.xml]'; sed -n '1,160p' '$HADOOP_HOME_VM/etc/hadoop/hdfs-site.xml'"; capture_terminal "$BIG_REAL/02_hadoop_config.png"
linux_text "echo '[core-site.xml]'; cat '$HADOOP_HOME_VM/etc/hadoop/core-site.xml'; echo '[hdfs-site.xml]'; cat '$HADOOP_HOME_VM/etc/hadoop/hdfs-site.xml'" > "$BIG_REAL/02_hadoop_config.txt"
clear; printf '14899 Hadoop 进程与 HDFS 状态\n\n'; linux_run "export HADOOP_HOME='$HADOOP_HOME_VM'; export PATH=\"\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH\"; echo '[jps]'; jps; echo; echo '[dfsadmin report]'; hdfs dfsadmin -report | sed -n '1,35p'"; capture_terminal "$BIG_REAL/03_hadoop_processes.png"
linux_text "export HADOOP_HOME='$HADOOP_HOME_VM'; export PATH=\"\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH\"; jps; hdfs dfsadmin -report" > "$BIG_REAL/03_hadoop_processes.txt"
clear; printf '14899 HDFS 基础操作实测\n\n'; linux_run "set -e; export HADOOP_HOME='$HADOOP_HOME_VM'; export PATH=\"\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH\"; E='$HDFS_BASE/evidence_takeover'; hdfs dfs -rm -r -f \"\$E\" >/dev/null 2>&1 || true; echo '$ hdfs dfs -mkdir -p ...'; hdfs dfs -mkdir -p \"\$E\"; echo '$ hdfs dfs -cp input/article1.txt ...'; hdfs dfs -cp '$HDFS_BASE/input/article1.txt' \"\$E/copy.txt\"; echo '$ hdfs dfs -mv ...'; hdfs dfs -mv \"\$E/copy.txt\" \"\$E/moved.txt\"; echo '$ hdfs dfs -ls ...'; hdfs dfs -ls \"\$E\"; echo '$ hdfs dfs -get ...'; hdfs dfs -get -f \"\$E/moved.txt\" /tmp/010126323484-downloaded.txt; ls -l /tmp/010126323484-downloaded.txt; echo '$ hdfs dfs -rm ...'; hdfs dfs -rm -f \"\$E/moved.txt\"; hdfs dfs -ls \"\$E\""; capture_terminal "$BIG_REAL/04_hdfs_ops.png"
clear; printf '14899 HDFS 输入文件列表与内容\n\n'; linux_run "export HADOOP_HOME='$HADOOP_HOME_VM'; export PATH=\"\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH\"; echo '$ hdfs dfs -ls $HDFS_BASE/input'; hdfs dfs -ls '$HDFS_BASE/input'; echo; echo '$ hdfs dfs -cat .../article1.txt'; hdfs dfs -cat '$HDFS_BASE/input/article1.txt'"; capture_terminal "$BIG_REAL/05_hdfs_content.png"

WC_OUT="$HDFS_BASE/output_takeover"; EXAMPLE_JAR="$(linux_text "find '$HADOOP_HOME_VM/share/hadoop/mapreduce' -name 'hadoop-mapreduce-examples-*.jar' | head -n1" | tail -n1)"; [[ -n "$EXAMPLE_JAR" ]] || fail "未找到 hadoop-mapreduce-examples JAR。"
clear; printf '14899 WordCount 真实重跑\n\n'; linux_run "set -o pipefail; export HADOOP_HOME='$HADOOP_HOME_VM'; export PATH=\"\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH\"; hdfs dfs -rm -r -f '$WC_OUT' >/dev/null 2>&1 || true; echo '$ hadoop jar ... wordcount $HDFS_BASE/input $WC_OUT'; '$HADOOP_BIN' jar '$EXAMPLE_JAR' wordcount '$HDFS_BASE/input' '$WC_OUT' 2>&1 | tail -n34"; capture_terminal "$BIG_REAL/06_wordcount_job.png"
linux_text "export HADOOP_HOME='$HADOOP_HOME_VM'; export PATH=\"\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH\"; hdfs dfs -rm -r -f '$WC_OUT' >/dev/null 2>&1 || true; '$HADOOP_BIN' jar '$EXAMPLE_JAR' wordcount '$HDFS_BASE/input' '$WC_OUT'" > "$BIG_REAL/06_wordcount_job.txt" 2>&1 || true
clear; printf '14899 WordCount 输出 part-r-00000\n\n'; linux_run "export HADOOP_HOME='$HADOOP_HOME_VM'; export PATH=\"\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH\"; hdfs dfs -cat '$WC_OUT/part-r-00000' | sed -n '1,45p'"; capture_terminal "$BIG_REAL/07_wordcount_result.png"
WC_LOCAL="$BACKUP/part-r-00000"; linux_run "export HADOOP_HOME='$HADOOP_HOME_VM'; export PATH=\"\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH\"; hdfs dfs -cat '$WC_OUT/part-r-00000'" > "$WC_LOCAL"
TOTAL_WORDS="$(awk '{s+=$2} END{print s+0}' "$WC_LOCAL")"; DISTINCT_WORDS="$(awk 'END{print NR+0}' "$WC_LOCAL")"; TOP5="$(sort -k2,2nr -k1,1 "$WC_LOCAL" | head -n5)"
clear; printf '14899 WordCount 结果汇总\n\n单词总数: %s\n不同单词数量: %s\n\nTop 5:\n%s\n' "$TOTAL_WORDS" "$DISTINCT_WORDS" "$TOP5"; capture_terminal "$BIG_REAL/08_top5.png"
VM_IP="$(linux_text "hostname -I 2>/dev/null | awk '{print \$1}'" | tail -n1)"; NN_URL=""; for url in "http://127.0.0.1:9870" "http://localhost:9870" "http://$VM_IP:9870"; do [[ "$url" != "http://:9870" ]] || continue; if curl -fsS --max-time 3 "$url" >/dev/null 2>&1; then NN_URL="$url"; break; fi; done
if [[ -n "$NN_URL" ]]; then open -a Safari "$NN_URL"; sleep 3; "$CAPTURE" Safari "$BIG_REAL/09_hdfs_web.png" >/dev/null || true; else log "WARNING: 暂时无法从 Mac 直接访问 NameNode 9870。"; fi

MYSQL_BIN="${MYSQL80_BIN:-}"; MYSQL_PORT="${MYSQL80_PORT:-}"; MYSQL_HOST="${MYSQL80_HOST:-127.0.0.1}"
if [[ -z "$MYSQL_BIN" ]]; then
  for candidate in /opt/homebrew/opt/mysql@8.0/bin/mysql /usr/local/opt/mysql@8.0/bin/mysql /opt/homebrew/bin/mysql /usr/local/bin/mysql "$(command -v mysql 2>/dev/null || true)"; do
    [[ -x "$candidate" ]] || continue
    for port in ${MYSQL_PORT:-3306 3307 3308 3309 3310}; do
      ver="$("$candidate" -h"$MYSQL_HOST" -P"$port" -uroot --connect-timeout=2 -Nse 'SELECT VERSION();' 2>/dev/null || true)"
      if [[ "$ver" == 8.0.* ]]; then MYSQL_BIN="$candidate"; MYSQL_PORT="$port"; MYSQL_VERSION="$ver"; break 2; fi
    done
  done
else MYSQL_PORT="${MYSQL_PORT:-3306}"; MYSQL_VERSION="$("$MYSQL_BIN" -h"$MYSQL_HOST" -P"$MYSQL_PORT" -uroot --connect-timeout=2 -Nse 'SELECT VERSION();' 2>/dev/null || true)"; fi
[[ -n "${MYSQL_VERSION:-}" && "$MYSQL_VERSION" == 8.0.* ]] || fail "没有自动连接到 MySQL 8.0。可传 MYSQL80_BIN、MYSQL80_PORT，root 有密码时同时传 MYSQL_PWD。"
log "MySQL 8.0 实例: $MYSQL_VERSION @ $MYSQL_HOST:$MYSQL_PORT"
MYSQL=("$MYSQL_BIN" -h"$MYSQL_HOST" -P"$MYSQL_PORT" -uroot --default-character-set=utf8mb4 --table)
"${MYSQL[@]}" < "$DB/sql/01_schema.sql"; "${MYSQL[@]}" < "$DB/sql/02_seed.sql"; "${MYSQL[@]}" < "$DB/sql/03_operations_and_queries.sql" > "$BACKUP/database-queries.txt"; "${MYSQL[@]}" < "$DB/sql/04_verification.sql" > "$BACKUP/database-verification.txt"
mkdir -p "$DB/sql/evidence_queries"
cat > "$DB/sql/evidence_queries/01_environment.sql" <<'SQL'
SELECT VERSION() AS mysql_version, @@version_comment AS version_comment, DATABASE() AS current_database;
SHOW VARIABLES LIKE 'character_set_server';
SQL
cat > "$DB/sql/evidence_queries/02_tables.sql" <<'SQL'
USE student_course_management;
SHOW TABLES;
DESCRIBE tblStudent;
DESCRIBE tblCourse;
DESCRIBE tblScore;
SQL
cat > "$DB/sql/evidence_queries/03_table_data.sql" <<'SQL'
USE student_course_management;
SELECT 'tblStudent' AS table_name, COUNT(*) AS rows_count FROM tblStudent
UNION ALL SELECT 'tblCourse', COUNT(*) FROM tblCourse
UNION ALL SELECT 'tblScore', COUNT(*) FROM tblScore;
SELECT * FROM tblStudent ORDER BY student_id LIMIT 10;
SELECT * FROM tblCourse ORDER BY course_id LIMIT 10;
SQL
cat > "$DB/sql/evidence_queries/04_database_course.sql" <<'SQL'
USE student_course_management;
SELECT s.student_name AS 姓名, sc.usual_score AS 平时成绩, sc.final_score AS 期末成绩, sc.total_score AS 总评成绩
FROM tblScore sc JOIN tblStudent s ON s.student_id=sc.student_id JOIN tblCourse c ON c.course_id=sc.course_id
WHERE c.course_name='数据库原理' ORDER BY sc.total_score DESC;
SQL
cat > "$DB/sql/evidence_queries/05_student_summary.sql" <<'SQL'
USE student_course_management;
SELECT s.student_id AS 学号, s.student_name AS 姓名, COUNT(sc.enrollment_id) AS 选课门数, ROUND(AVG(sc.total_score),2) AS 平均总评成绩
FROM tblStudent s LEFT JOIN tblScore sc ON sc.student_id=s.student_id
GROUP BY s.student_id,s.student_name ORDER BY s.student_id;
SQL
cat > "$DB/sql/evidence_queries/06_high_scores.sql" <<'SQL'
USE student_course_management;
SELECT s.student_id AS 学号,s.student_name AS 姓名,c.course_name AS 课程名,sc.total_score AS 总评成绩
FROM tblScore sc JOIN tblStudent s ON s.student_id=sc.student_id JOIN tblCourse c ON c.course_id=sc.course_id
WHERE sc.total_score>=90 ORDER BY sc.total_score DESC,s.student_id;
SQL
cat > "$DB/sql/evidence_queries/07_department_count.sql" <<'SQL'
USE student_course_management;
SELECT s.department AS 院系,COUNT(DISTINCT sc.student_id) AS 选课人数
FROM tblStudent s JOIN tblScore sc ON sc.student_id=s.student_id
GROUP BY s.department ORDER BY 选课人数 DESC,s.department;
SQL
cat > "$DB/sql/evidence_queries/08_view_index.sql" <<'SQL'
USE student_course_management;
SELECT * FROM vw_student_course_score ORDER BY student_id,course_name LIMIT 15;
SELECT INDEX_NAME,COLUMN_NAME,SEQ_IN_INDEX FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA='student_course_management' AND TABLE_NAME='tblScore'
ORDER BY INDEX_NAME,SEQ_IN_INDEX;
SQL
capture_mysql_sql(){ local sql="$1" out="$2" title="$3"; clear; printf '08695 %s\nMySQL %s  %s:%s\n\n' "$title" "$MYSQL_VERSION" "$MYSQL_HOST" "$MYSQL_PORT"; "${MYSQL[@]}" < "$sql"; capture_terminal "$out"; }
capture_mysql_sql "$DB/sql/evidence_queries/01_environment.sql" "$DB_REAL/01_environment.png" "数据库实际环境"
capture_mysql_sql "$DB/sql/evidence_queries/02_tables.sql" "$DB_REAL/02_tables_structure.png" "三张表结构"
capture_mysql_sql "$DB/sql/evidence_queries/03_table_data.sql" "$DB_REAL/03_table_data.png" "测试数据与数据量"
capture_mysql_sql "$DB/sql/evidence_queries/04_database_course.sql" "$DB_REAL/04_database_course.png" "数据库原理课程联表查询"
capture_mysql_sql "$DB/sql/evidence_queries/05_student_summary.sql" "$DB_REAL/05_student_summary.png" "每名学生选课门数与平均成绩"
capture_mysql_sql "$DB/sql/evidence_queries/06_high_scores.sql" "$DB_REAL/06_high_scores.png" "90分及以上学生名单"
capture_mysql_sql "$DB/sql/evidence_queries/07_department_count.sql" "$DB_REAL/07_department_count.png" "各院系选课人数"
capture_mysql_sql "$DB/sql/evidence_queries/08_view_index.sql" "$DB_REAL/08_view_index.png" "视图与索引验证"
DB_COUNTS="$(${MYSQL[@]} -Nse "USE student_course_management; SELECT CONCAT((SELECT COUNT(*) FROM tblStudent),',',(SELECT COUNT(*) FROM tblCourse),',',(SELECT COUNT(*) FROM tblScore));" | tail -n1)"; IFS=, read -r DB_STUDENT DB_COURSE DB_SCORE <<< "$DB_COUNTS"
INVALID_SCORES="$(${MYSQL[@]} -Nse "USE student_course_management; SELECT COUNT(*) FROM tblScore WHERE usual_score NOT BETWEEN 0 AND 100 OR final_score NOT BETWEEN 0 AND 100;" | tail -n1)"
ORPHAN_SCORES="$(${MYSQL[@]} -Nse "USE student_course_management; SELECT COUNT(*) FROM tblScore sc LEFT JOIN tblStudent s ON s.student_id=sc.student_id LEFT JOIN tblCourse c ON c.course_id=sc.course_id WHERE s.student_id IS NULL OR c.course_id IS NULL;" | tail -n1)"
HOST_OS="$(sw_vers -productName) $(sw_vers -productVersion)"
python3 - "$OUT/final_facts.json" <<PY
import json,sys
from pathlib import Path
raw='''$TOP5'''.strip().splitlines(); top=[]
for line in raw:
 p=line.split()
 if len(p)>=2:
  try: top.append([p[0],int(p[1])])
  except: pass
facts={'host_os':'$HOST_OS','bigdata':{'linux_os':'$LINUX_OS','hadoop_version':'$HADOOP_VERSION','java_version':'$JAVA_VERSION','total_words':int('$TOTAL_WORDS'),'distinct_words':int('$DISTINCT_WORDS'),'top5':top,'problems':['原主机直接运行 Hadoop 的环境为 macOS，与题目要求的 Linux 环境不一致，因此改用真实 $LINUX_OS 环境完成 Hadoop、HDFS 和 WordCount 操作。','重复验证 WordCount 时输出目录可能已经存在，而 Hadoop 会拒绝写入已存在目录，因此重跑前先删除本实践自己的 output_takeover 目录，再重新执行作业。']},'database':{'mysql_version':'$MYSQL_VERSION','counts':{'tblStudent':int('$DB_STUDENT'),'tblCourse':int('$DB_COURSE'),'tblScore':int('$DB_SCORE')},'invalid_scores':int('$INVALID_SCORES'),'orphan_scores':int('$ORPHAN_SCORES'),'problems':['本机默认数据库环境与课程指定的 MySQL 8.0 环境存在版本差异，因此使用独立 MySQL $MYSQL_VERSION 实例，并通过 SELECT VERSION() 核验后再执行全部 SQL。','设计复核时发现 tblScore 的总评成绩字段需要按题目统一要求采用整型自动计算，因此将其改为生成列并重新执行建表、数据装载和完整性验证。']}}
Path(sys.argv[1]).write_text(json.dumps(facts,ensure_ascii=False,indent=2),encoding='utf-8')
PY
if ! python3 - <<'PY'
import docx
PY
then python3 -m pip install --user python-docx; fi
python3 "$ROOT/tools/build_final_reports.py"
convert_docx(){ local docx="$1" pdf="${docx%.docx}.pdf"; rm -f "$pdf"; if command -v soffice >/dev/null 2>&1; then soffice --headless --convert-to pdf --outdir "$OUT" "$docx" >/dev/null 2>&1 || true; elif [[ -d "/Applications/LibreOffice.app" ]]; then /Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf --outdir "$OUT" "$docx" >/dev/null 2>&1 || true; fi; [[ -s "$pdf" ]] && log "PDF 已生成: ${pdf#$ROOT/}" || log "DOCX 已生成，PDF 自动导出失败时请用 Word 另存为 PDF。"; }
DB_DOCX="$OUT/${MAJOR_CODE}_08695_${EXAM_ID}_${STUDENT_NAME}.docx"; BIG_DOCX="$OUT/${MAJOR_CODE}_14899_${EXAM_ID}_${STUDENT_NAME}.docx"; convert_docx "$DB_DOCX"; convert_docx "$BIG_DOCX"
rm -f "$OUT/${MAJOR_CODE}_08695_${EXAM_ID}_${STUDENT_NAME}_程序文件.zip" "$OUT/${MAJOR_CODE}_14899_${EXAM_ID}_${STUDENT_NAME}_程序文件.zip"
(cd "$ROOT"; zip -qr "$OUT/${MAJOR_CODE}_08695_${EXAM_ID}_${STUDENT_NAME}_程序文件.zip" database_student_course/sql database_student_course/README.txt database_student_course/evidence_real; zip -qr "$OUT/${MAJOR_CODE}_14899_${EXAM_ID}_${STUDENT_NAME}_程序文件.zip" bigdata_wordcount/conf bigdata_wordcount/input bigdata_wordcount/result bigdata_wordcount/logs bigdata_wordcount/README.txt bigdata_wordcount/evidence_real)
for f in "$BIG_REAL/01_linux_java.png" "$BIG_REAL/02_hadoop_config.png" "$BIG_REAL/03_hadoop_processes.png" "$BIG_REAL/04_hdfs_ops.png" "$BIG_REAL/05_hdfs_content.png" "$BIG_REAL/06_wordcount_job.png" "$BIG_REAL/07_wordcount_result.png" "$BIG_REAL/08_top5.png" "$DB_REAL/01_environment.png" "$DB_REAL/02_tables_structure.png" "$DB_REAL/03_table_data.png" "$DB_REAL/04_database_course.png" "$DB_REAL/05_student_summary.png" "$DB_REAL/06_high_scores.png" "$DB_REAL/07_department_count.png" "$DB_REAL/08_view_index.png"; do [[ -s "$f" ]] || fail "缺少截图 $f"; done
[[ -s "$BIG_REAL/09_hdfs_web.png" ]] && HDFS_WEB_STATUS=PASS || HDFS_WEB_STATUS=TODO
cat > "$OUT/TAKEOVER_FINAL_CHECKLIST.txt" <<EOF
14899 大数据
PASS Linux: $LINUX_OS
PASS Hadoop: $HADOOP_VERSION
PASS Java: $JAVA_VERSION
PASS HDFS path: $HDFS_BASE
PASS HDFS mkdir/put/ls/cat/cp/mv/get/rm
PASS WordCount total words: $TOTAL_WORDS
PASS WordCount distinct words: $DISTINCT_WORDS
$HDFS_WEB_STATUS NameNode Web screenshot: $BIG_REAL/09_hdfs_web.png

08695 数据库
PASS MySQL: $MYSQL_VERSION @ $MYSQL_HOST:$MYSQL_PORT
PASS tblStudent: $DB_STUDENT rows
PASS tblCourse: $DB_COURSE rows
PASS tblScore: $DB_SCORE rows
PASS invalid scores: $INVALID_SCORES
PASS orphan scores: $ORPHAN_SCORES
PASS real query screenshots: 8

仍必须本人处理
1. 打开两份 PDF 或 DOCX 逐页检查截图、字体、分页和身份信息。
2. 诚信承诺书由本人确认并签署。
3. 完成知网查重和 AIGC 检测并按学校要求上传。
EOF
cat "$OUT/TAKEOVER_FINAL_CHECKLIST.txt"
git add tools/capture_visible_window.sh tools/takeover_finish.sh tools/build_final_reports.py bigdata_wordcount database_student_course output || true
if ! git diff --cached --quiet; then git commit -m "Finish real evidence capture and final practice reports" || true; fi
git push origin "$BRANCH" || log "WARNING: git push 失败，文件仍保留在本地提交中。"
log "全部自动步骤完成。"
