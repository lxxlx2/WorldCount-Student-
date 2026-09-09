#!/usr/bin/env bash
set -euo pipefail
HADOOP_HOME="${HADOOP_HOME:-/opt/homebrew/opt/hadoop/libexec}"
JAVA_HOME="${HADOOP_JAVA_HOME:-/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home}"
export HADOOP_HOME JAVA_HOME
export HADOOP_CONF_DIR="$(cd "$(dirname "$0")" && pwd)/conf"
"$HADOOP_HOME/bin/hdfs" --daemon stop datanode || true
"$HADOOP_HOME/bin/hdfs" --daemon stop namenode || true
