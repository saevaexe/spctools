from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Paths — relative to this script's location
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(SCRIPT_DIR, "Previews")
SCREENSHOTS_DIR = os.path.join(SCRIPT_DIR, "Screenshots")
SCREENSHOT_HOME = os.path.join(SCREENSHOTS_DIR, "02_home.png")
SCREENSHOT_PAYWALL = os.path.join(SCREENSHOTS_DIR, "07_paywall.png")

# Fonts
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_REG = "/System/Library/Fonts/Supplemental/Arial.ttf"

# App Store required sizes
SIZES = {
    "iphone65": (1242, 2688),   # iPhone 6.5" (required)
    "ipad13": (2048, 2732),     # iPad 13" (required)
}

# SPC Tools brand colors
BLUE = (0, 122, 255)
WHITE = (255, 255, 255)
DARK = (30, 30, 30)
LIGHT_BG = (245, 245, 247)
GREEN = (52, 199, 89)


def create_gradient(size, top_color, bot_color):
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    for y in range(h):
        r = y / h
        for x in range(w):
            px[x, y] = tuple(int(top_color[i] + (bot_color[i] - top_color[i]) * r) for i in range(3))
    return img


def round_corners(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([(0, 0), img.size], radius=radius, fill=255)
    result = img.copy()
    result.putalpha(mask)
    return result


def add_phone_frame(canvas, screenshot_path, pos, phone_size, corner_radius=40):
    """Frameless modern style: rounded screenshot + drop shadow."""
    screenshot = Image.open(screenshot_path).convert("RGBA")
    screenshot = screenshot.resize(phone_size, Image.LANCZOS)
    radius = int(phone_size[0] * 0.1)

    rounded = round_corners(screenshot, radius)

    shadow_pad = 40
    shadow = Image.new("RGBA", (phone_size[0] + shadow_pad * 2, phone_size[1] + shadow_pad * 2), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [(shadow_pad, shadow_pad),
         (phone_size[0] + shadow_pad - 1, phone_size[1] + shadow_pad - 1)],
        radius=radius, fill=(0, 0, 0, 60)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=25))
    canvas.paste(shadow, (pos[0] - shadow_pad, pos[1] - shadow_pad + 10), shadow)
    canvas.paste(rounded, pos, rounded)


def text_centered(draw, text, y, font, fill, w):
    bbox = draw.textbbox((0, 0), text, font=font)
    draw.text(((w - (bbox[2] - bbox[0])) // 2, y), text, font=font, fill=fill)


def generate_preview_1(size, prefix):
    """Hero: Blue gradient + phone mockup showing home screen."""
    w, h = size
    s = w / 1242

    canvas = create_gradient(size, (0, 140, 255), (0, 70, 200)).convert("RGBA")

    ov = Image.new("RGBA", size, (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    for i in range(80):
        a = max(0, 25 - i)
        od.line([(int(w * 0.2) + i * 4, 0), (0, int(h * 0.3) + i * 4)], fill=(255, 255, 255, a), width=3)
    canvas = Image.alpha_composite(canvas, ov)
    draw = ImageDraw.Draw(canvas)

    tf = ImageFont.truetype(FONT_BOLD, int(78 * s))
    sf = ImageFont.truetype(FONT_REG, int(38 * s))

    text_centered(draw, "15 Profesyonel", int(120 * s), tf, WHITE, w)
    text_centered(draw, "SPC Hesaplayıcı", int(120 * s + 95 * s), tf, WHITE, w)
    text_centered(draw, "Kalite mühendisliği hesaplamalarınız", int(120 * s + 220 * s), sf, (255, 255, 255, 210), w)
    text_centered(draw, "artık cebinizde", int(120 * s + 270 * s), sf, (255, 255, 255, 210), w)

    pw = int(580 * s)
    ph = int(1250 * s)
    px = (w - pw) // 2
    py = int(480 * s)

    add_phone_frame(canvas, SCREENSHOT_HOME, (px, py), (pw, ph), int(45 * s))

    canvas.convert("RGB").save(os.path.join(OUT_DIR, f"{prefix}_preview_1.png"))
    print(f"  Saved {prefix}_preview_1.png")


def generate_preview_2(size, prefix):
    """Features: Light bg + feature cards + phone mockup."""
    w, h = size
    s = w / 1242

    canvas = Image.new("RGBA", size, LIGHT_BG)
    draw = ImageDraw.Draw(canvas)

    draw.rectangle([(0, 0), (w, int(10 * s))], fill=BLUE)

    tf = ImageFont.truetype(FONT_BOLD, int(68 * s))
    ff = ImageFont.truetype(FONT_REG, int(38 * s))
    cf = ImageFont.truetype(FONT_BOLD, int(26 * s))

    text_centered(draw, "Tüm SPC Araçları", int(100 * s), tf, DARK, w)
    text_centered(draw, "Tek Yerde", int(100 * s + 85 * s), tf, BLUE, w)

    features = [
        "Cp/Cpk & Pp/Ppk Analizi",
        "OEE & Sigma Seviyesi",
        "Kontrol Grafikleri & Histogram",
        "Pareto & FMEA Analizi",
        "Gage R&R & Hipotez Testi",
    ]

    margin = int(100 * s)
    y0 = int(320 * s)
    row_h = int(95 * s)

    for i, text in enumerate(features):
        y = y0 + i * row_h
        draw.rounded_rectangle([(margin, y), (w - margin, y + int(70 * s))], radius=int(16 * s), fill=WHITE)
        cx = margin + int(45 * s)
        cy = y + int(35 * s)
        r = int(20 * s)
        draw.ellipse([(cx - r, cy - r), (cx + r, cy + r)], fill=BLUE)
        draw.text((cx - int(8 * s), cy - int(14 * s)), "✓", font=cf, fill=WHITE)
        draw.text((cx + r + int(22 * s), y + int(15 * s)), text, font=ff, fill=DARK)

    pw = int(560 * s)
    ph = int(1210 * s)
    px = (w - pw) // 2
    py = int(820 * s)

    add_phone_frame(canvas, SCREENSHOT_HOME, (px, py), (pw, ph), int(42 * s))

    canvas.convert("RGB").save(os.path.join(OUT_DIR, f"{prefix}_preview_2.png"))
    print(f"  Saved {prefix}_preview_2.png")


def generate_preview_3(size, prefix):
    """PRO: Dark bg + blue glow + benefits + paywall mockup."""
    w, h = size
    s = w / 1242

    canvas = create_gradient(size, (35, 35, 40), (18, 18, 22)).convert("RGBA")

    glow = Image.new("RGBA", size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    cx = w // 2
    for r in range(int(500 * s), 0, -3):
        a = max(0, int(35 * (1 - r / (500 * s))))
        gd.ellipse([(cx - r, int(100 * s) - r), (cx + r, int(100 * s) + r)], fill=(0, 122, 255, a))
    canvas = Image.alpha_composite(canvas, glow)
    draw = ImageDraw.Draw(canvas)

    tf = ImageFont.truetype(FONT_BOLD, int(74 * s))
    sf = ImageFont.truetype(FONT_REG, int(38 * s))
    bf = ImageFont.truetype(FONT_REG, int(36 * s))
    cf = ImageFont.truetype(FONT_BOLD, int(24 * s))
    pf = ImageFont.truetype(FONT_BOLD, int(42 * s))
    lf = ImageFont.truetype(FONT_REG, int(28 * s))

    text_centered(draw, "SPC Tools PRO", int(100 * s), tf, BLUE, w)
    text_centered(draw, "Sınırsız erişim, 7 gün ücretsiz", int(100 * s + 95 * s), sf, (180, 180, 180), w)

    benefits = [
        "15 profesyonel SPC hesaplayıcı",
        "Sınırsız hesaplama geçmişi",
        "Tüm SPC araçları ve analiz",
    ]

    y0 = int(320 * s)
    for i, text in enumerate(benefits):
        y = y0 + i * int(75 * s)
        cx2 = int(160 * s)
        r = int(18 * s)
        draw.ellipse([(cx2 - r, y - r + int(5 * s)), (cx2 + r, y + r + int(5 * s))], fill=GREEN)
        draw.text((cx2 - int(7 * s), y - int(9 * s)), "✓", font=cf, fill=WHITE)
        draw.text((cx2 + r + int(20 * s), y - int(8 * s)), text, font=bf, fill=WHITE)

    py = int(580 * s)
    bw = int(460 * s)
    bh = int(110 * s)
    gap = int(30 * s)

    mx = w // 2 - bw - gap // 2
    draw.rounded_rectangle([(mx, py), (mx + bw, py + bh)], radius=int(20 * s), fill=(55, 55, 60))
    draw.text((mx + int(30 * s), py + int(18 * s)), "$2.99 / ay", font=pf, fill=WHITE)
    draw.text((mx + int(30 * s), py + int(68 * s)), "Aylık abonelik", font=lf, fill=(150, 150, 150))

    yx = w // 2 + gap // 2
    draw.rounded_rectangle([(yx, py), (yx + bw, py + bh)], radius=int(20 * s), fill=BLUE)
    draw.text((yx + int(30 * s), py + int(18 * s)), "$19.99 / yıl", font=pf, fill=WHITE)
    draw.text((yx + int(30 * s), py + int(68 * s)), "%44 tasarruf", font=lf, fill=(255, 255, 255, 220))

    pw = int(560 * s)
    ph2 = int(1210 * s)
    ppx = (w - pw) // 2
    ppy = int(780 * s)

    add_phone_frame(canvas, SCREENSHOT_PAYWALL, (ppx, ppy), (pw, ph2), int(42 * s))

    canvas.convert("RGB").save(os.path.join(OUT_DIR, f"{prefix}_preview_3.png"))
    print(f"  Saved {prefix}_preview_3.png")


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)

    print(f"Screenshots: {SCREENSHOTS_DIR}")
    print(f"Output: {OUT_DIR}\n")

    for name, size in SIZES.items():
        print(f"--- {name} ({size[0]}x{size[1]}) ---")
        generate_preview_1(size, name)
        generate_preview_2(size, name)
        generate_preview_3(size, name)

    print(f"\nDone! {len(SIZES) * 3} previews generated.")
