from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import textwrap

ROOT = Path(__file__).resolve().parents[1]
MONO = "/System/Library/Fonts/Monaco.ttf"
CN = "/System/Library/Fonts/STHeiti Medium.ttc"


def terminal_image(source: Path, output: Path, title: str, max_lines: int = 48):
    lines = source.read_text(encoding="utf-8").splitlines()[:max_lines]
    font = ImageFont.truetype(CN, 20)
    small = ImageFont.truetype(CN, 17)
    width = 1600
    line_h = 28
    height = 80 + line_h * max(3, len(lines)) + 36
    im = Image.new("RGB", (width, height), "#101418")
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, width - 1, 52), radius=12, fill="#252b31")
    for i, c in enumerate(("#ff5f57", "#febc2e", "#28c840")):
        d.ellipse((18 + i * 30, 17, 34 + i * 30, 33), fill=c)
    d.text((120, 14), title, font=small, fill="#e6edf3")
    y = 67
    for line in lines:
        d.text((24, y), line, font=font, fill="#d7e2ea")
        y += line_h
    output.parent.mkdir(parents=True, exist_ok=True)
    im.save(output)


def er_diagram(output: Path):
    im = Image.new("RGB", (1600, 900), "white")
    d = ImageDraw.Draw(im)
    title_font = ImageFont.truetype(CN, 44)
    head_font = ImageFont.truetype(CN, 30)
    body_font = ImageFont.truetype(CN, 23)
    d.text((800, 50), "学生选课管理系统 E-R 图", font=title_font, fill="#111827", anchor="ma")

    boxes = {
        "student": (90, 220, 500, 700, "学生 tblStudent", ["PK 学号", "姓名", "性别", "出生日期", "所在院系", "入学年份", "联系电话"]),
        "score": (595, 190, 1005, 730, "选课成绩 tblScore", ["PK 选课编号", "FK 学号", "FK 课程号", "平时成绩", "期末成绩", "总评成绩", "选课日期"]),
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
            y += 48

    d.line((500, 440, 595, 440), fill="#c2410c", width=6)
    d.text((515, 405), "1", font=head_font, fill="#c2410c")
    d.text((560, 405), "N", font=head_font, fill="#c2410c")
    d.line((1005, 440, 1100, 440), fill="#c2410c", width=6)
    d.text((1020, 405), "N", font=head_font, fill="#c2410c")
    d.text((1065, 405), "1", font=head_font, fill="#c2410c")
    d.text((800, 810), "学生与课程构成 M:N 关系，由选课成绩实体分解为两个 1:N 关系", font=body_font, fill="#374151", anchor="mm")
    output.parent.mkdir(parents=True, exist_ok=True)
    im.save(output)


def main():
    db = ROOT / "database_student_course" / "evidence"
    mapping = {
        "01_tables_structure.txt": ("fig01_tables_structure.png", "MySQL - 数据库表结构"),
        "02_table_data.txt": ("fig02_table_data.png", "MySQL - 三张表测试数据"),
        "04_database_course.txt": ("fig04_database_course.png", "MySQL - 数据库原理课程查询"),
        "05_student_summary.txt": ("fig05_student_summary.png", "MySQL - 学生选课门数与平均成绩"),
        "06_high_scores.txt": ("fig06_high_scores.png", "MySQL - 90 分及以上成绩"),
        "07_department_count.txt": ("fig07_department_count.png", "MySQL - 各院系选课人数"),
        "08_view_index.txt": ("fig08_view_index.png", "MySQL - 视图与索引验证"),
    }
    for src, (name, title) in mapping.items():
        terminal_image(db / src, db / name, title)
    er_diagram(db / "fig03_er_diagram.png")

    big = ROOT / "bigdata_wordcount" / "evidence"
    if big.exists():
        for src in sorted(big.glob("*.txt")):
            terminal_image(src, src.with_suffix(".png"), "Hadoop - " + src.stem.replace("_", " "), max_lines=42)


if __name__ == "__main__":
    main()
