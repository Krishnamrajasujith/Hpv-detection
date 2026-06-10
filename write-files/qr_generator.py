import os
import qrcode
from PIL import Image

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "backend", "static", "qr")


def generate_qr(report_id: int, base_url: str) -> str:
    """Generate a QR code PNG for the given report download URL and return the filename."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    url = f"{base_url.rstrip('/')}/api/predictions/download/{report_id}"

    qr = qrcode.QRCode(version=1, box_size=6, border=2)
    qr.add_data(url)
    qr.make(fit=True)

    img: Image.Image = qr.make_image(fill_color="black", back_color="white")

    filename = f"qr_{report_id}.png"
    filepath = os.path.join(OUTPUT_DIR, filename)
    img.save(filepath)

    return filename
