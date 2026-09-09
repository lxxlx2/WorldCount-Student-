from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

MESSAGE = r'''
已停用自动生成最终实践报告。

原因：
1. 原脚本硬编码了 macOS、Homebrew、student_demo 等不符合 14899 最终提交要求的信息。
2. 原脚本使用重新改写的诚信承诺书，未保持学校模板原文。
3. 原脚本直接引用由日志绘制出的仿终端图片，这些图片不属于真实操作截图。
4. 学校要求考生本人根据真实实践过程填写报告，并进行知网查重和 AIGC 检测。

请按以下流程处理：
- 先阅读仓库根目录 REVIEW_REQUIRED.md。
- 14899 在 Linux 中使用本人准考证号重新完成实操并获取真实截图。
- 08695 使用实际 MySQL 环境重新执行 SQL，并在 MySQL Workbench/真实终端中截图。
- 最终报告直接填写学校提供的原始实践报告模板，保留固定栏目和诚信承诺书原文。
- 可将本仓库 SQL、日志、运行结果作为本人整理报告时的事实依据。
'''

if __name__ == "__main__":
    print(MESSAGE.strip())
    raise SystemExit(2)
