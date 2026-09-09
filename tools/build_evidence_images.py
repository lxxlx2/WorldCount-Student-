from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
CN = "/System/Library/Fonts/STHeiti Medium.ttc"


def er_diagram(output: Path):
    """Generate the E-R diagram only.

    The E-R diagram is a designed figure, so programmatic generation is appropriate.
    Runtime screenshots must be captured from the real DB/Hadoop applications by the student.
    """
    im = Image.new("RGB", (1600, 900), "white")
    d = ImageDraw.Draw(im)
    title_font = ImageFont.truetype(CN, 44)
    head_font = ImageFont.truetype(CN, 30)
    body_font = ImageFont.truetype(CN, 23)
    d.text((800, 50), "学生选课管理系统 E-R 图", font=title_font, fill="#111827", anchor="ma")

    boxes = {
        "student": (90, 220, 500, 700, "学生 tblStudent", ["PK 学号", "姓名", "性别", "出生日期", "所在院系", "入学年份", "联系电话"]),
        "score": (595, 220, 1005, 700, "选课成绩 tblScore", ["PK 选课编号", "FK 学号", "FK 课程号", "平时成绩", "期末成绩", "总评成绩"]),
        "course": (1100, 220, 1510, 700, "课程 tblCourse", ["PK 课程号", "课程名", "学分", "学时", "课程类别", "开课院系"]),
    }
    for x1, y1, x2, y2, head, fields in boxes.values():
        d.rounded_rectangle((x1, y1, x2, y2), radius=18, fill="#f8fafc", outline="#1f4e79", width=4)
        d.rounded_rectangle((x1, y1, x2, y1 + 70), radius=18, fill="#1f4e79")
        d.rectangle((x1, y1 + 52, x2, y1 + 70), fill="#1f4e79")
        d.text(((x1 + x2) / 2, y1 + 34), head, font=head_font, fill="white", anchor="mm")
        y = y1 + 100
        for field in fields:
            d.text((x1 + 30, y), field, font=body_font, fill="#111827")
            y += 52

    d.line((500, 440, 595, 440), fill="#c2410c", width=6)
    d.text((515, 405), "1", font=head_font, fill="#c2410c")
    d.text((560, 405), "N", font=head_font, fill="#c2410c")
    d.line((1005, 440, 1100, 440), fill="#c2410c", width=6)
    d.text((1020, 405), "N", font=head_font, fill="#c2410c")
    d.text((1065, 405), "1", font=head_font, fill="#c2410c")
    d.text((800, 810), "学生与课程构成 M:N 关系，由选课成绩实体分解为两个 1:N 关系", font=body_font, fill="#374151", anchor="mm")
    output.parent.mkdir(parents=True, exist_ok=True)
    im.save(output)


def check_real_screenshots():
    """Check for manually captured real screenshots.

    This tool intentionally does not convert text/log files into screenshot-like PNGs.
    The course requires screenshots of the real operation process and results.
    """
    required = {
        ROOT / "database_student_course" / "evidence": [
            "fig01_tables_structure.png",
            "fig02_table_data.png",
            "fig04_database_course.png",
            "fig05_student_summary.png",
            "fig06_high_scores.png",
            "fig07_department_count.png",
            "fig08_view_index.png",
        ],
        ROOT / "bigdata_wordcount" / "evidence": [
            "01_linux_java.png",
            "02_hadoop_version.png",
            "03_configuration.png",
            "04_processes.png",
            "05_hdfs_input.png",
            "06_input_content.png",
            "07_wordcount_job.png",
            "08_result.png",
            "09_summary_top5.png",
            "10_hdfs_web.png",
        ],
    }

    missing = []
    for folder, names in required.items():
        for name in names:
            path = folder / name
            if not path.exists():
                missing.append(path.relative_to(ROOT))

    if missing:
        print("以下运行截图尚未提供，必须由本人从真实软件/终端界面截图：")
        for path in missing:
            print(f"  - {path}")
        raise SystemExit(2)

    print("运行截图文件均已存在。提交前仍需人工确认它们确实来自真实操作界面。")


def main():
    er_diagram(ROOT / "database_student_course" / "evidence" / "fig03_er_diagram.png")
    check_real_screenshots()


if __name__ == "__main__":
    main()
