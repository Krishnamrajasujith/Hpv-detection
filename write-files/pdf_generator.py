import os
from datetime import datetime
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "backend", "static", "reports")
HEATMAP_DIR = os.path.join(os.path.dirname(__file__), "..", "backend", "static", "heatmaps")

_BLUE = colors.HexColor("#3d7fff")
_CYAN = colors.HexColor("#00c6ff")
_TEAL = colors.HexColor("#0ee7b0")
_RED = colors.HexColor("#ff4f6d")
_LIGHT = colors.HexColor("#b0c4de")
_ROW_BG = [colors.white, colors.HexColor("#f5f8ff")]
_HEADER_BG = colors.HexColor("#e8f0ff")
_GRID = colors.HexColor("#ccd9ff")

_LABEL_STYLE = TableStyle([
    ("BACKGROUND", (0, 0), (0, -1), _HEADER_BG),
    ("TEXTCOLOR", (0, 0), (0, -1), _BLUE),
    ("FONTNAME", (0, 0), (0, -1), "Helvetica-Bold"),
    ("FONTSIZE", (0, 0), (-1, -1), 10),
    ("GRID", (0, 0), (-1, -1), 0.5, _GRID),
    ("ROWBACKGROUNDS", (0, 0), (-1, -1), _ROW_BG),
    ("LEFTPADDING", (0, 0), (-1, -1), 8),
    ("RIGHTPADDING", (0, 0), (-1, -1), 8),
    ("TOPPADDING", (0, 0), (-1, -1), 6),
    ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
])


def _two_col_table(rows: list, accent_row: int | None = None, accent_color=None) -> Table:
    t = Table(rows, colWidths=[5 * cm, 12 * cm])
    style_cmds = list(_LABEL_STYLE._cmds)
    if accent_row is not None and accent_color:
        style_cmds += [
            ("TEXTCOLOR", (1, accent_row), (1, accent_row), accent_color),
            ("FONTNAME", (1, accent_row), (1, accent_row), "Helvetica-Bold"),
        ]
    t.setStyle(TableStyle(style_cmds))
    return t


def create_pdf(data: dict) -> str:
    """
    Generate a diagnostic PDF report and return the filename.

    Expected keys in data:
        report_id, patient_name, age, gender, sample_id, test_date,
        next_visit_date, result, confidence, risk, notes,
        daily_food_intake, heatmap_filename, username
    """
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    filename = f"report_{data['report_id']}.pdf"
    filepath = os.path.join(OUTPUT_DIR, filename)

    doc = SimpleDocTemplate(
        filepath,
        pagesize=A4,
        leftMargin=2 * cm, rightMargin=2 * cm,
        topMargin=2 * cm, bottomMargin=2 * cm,
    )

    styles = getSampleStyleSheet()
    title_style = ParagraphStyle("STitle", parent=styles["Title"], textColor=_BLUE, fontSize=14, spaceAfter=6)
    sub_style = ParagraphStyle("SSub", parent=styles["Normal"], textColor=_CYAN, fontSize=10, spaceAfter=4)

    story = []

    # ── Header ────────────────────────────────────────────────────────────────
    story.append(Paragraph("HPV DetectAI — Genomic Diagnostics Report", title_style))
    story.append(Paragraph("AI-Based HPV16 Detection Platform", sub_style))
    story.append(Spacer(1, 0.4 * cm))

    # ── Patient information ───────────────────────────────────────────────────
    story.append(Paragraph("Patient Information", title_style))
    story.append(_two_col_table([
        ["Patient Name",  data.get("patient_name", "—")],
        ["Age",           str(data.get("age", "—"))],
        ["Gender",        data.get("gender", "—")],
        ["Sample ID",     data.get("sample_id", "—")],
        ["Test Date",     data.get("test_date", "—")],
        ["Next Visit",    data.get("next_visit_date", "—") or "—"],
    ]))
    story.append(Spacer(1, 0.5 * cm))

    # ── Diagnostic result ────────────────────────────────────────────────────
    result_color = _RED if "Positive" in str(data.get("result", "")) else _TEAL
    story.append(Paragraph("Diagnostic Result", title_style))
    story.append(_two_col_table([
        ["Prediction",      data.get("result", "—")],
        ["Confidence",      f"{data.get('confidence', 0):.1f}%"],
        ["Risk Level",      data.get("risk", "—")],
        ["Clinical Notes",  data.get("notes", "—") or "None"],
    ], accent_row=0, accent_color=result_color))
    story.append(Spacer(1, 0.5 * cm))

    # ── Daily food intake ────────────────────────────────────────────────────
    food_raw = (data.get("daily_food_intake") or "").strip()
    if food_raw:
        story.append(Paragraph("Daily Food Intake", title_style))
        items = [i.strip() for i in food_raw.replace(";", "\n").split("\n") if i.strip()]
        ft = Table([[f"• {item}"] for item in items], colWidths=[17 * cm])
        ft.setStyle(TableStyle([
            ("FONTSIZE", (0, 0), (-1, -1), 10),
            ("TEXTCOLOR", (0, 0), (-1, -1), colors.HexColor("#1a2a3a")),
            ("ROWBACKGROUNDS", (0, 0), (-1, -1), _ROW_BG),
            ("LEFTPADDING", (0, 0), (-1, -1), 14),
            ("TOPPADDING", (0, 0), (-1, -1), 5),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
            ("GRID", (0, 0), (-1, -1), 0.3, _GRID),
        ]))
        story.append(ft)
        story.append(Spacer(1, 0.5 * cm))

    # ── Gene expression heatmap ───────────────────────────────────────────────
    heatmap_path = os.path.join(HEATMAP_DIR, data.get("heatmap_filename", ""))
    if data.get("heatmap_filename") and os.path.exists(heatmap_path):
        story.append(Paragraph("Gene Expression Heatmap", title_style))
        story.append(Image(heatmap_path, width=16 * cm, height=3 * cm))
        story.append(Spacer(1, 0.4 * cm))

    # ── Footer ────────────────────────────────────────────────────────────────
    story.append(Paragraph(
        f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  |  "
        f"Report ID: {data.get('report_id')}  |  User: {data.get('username', '—')}",
        ParagraphStyle("Footer", parent=styles["Normal"], textColor=_LIGHT, fontSize=8),
    ))

    doc.build(story)
    return filename
