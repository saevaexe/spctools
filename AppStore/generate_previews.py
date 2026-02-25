from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Paths — relative to this script's location
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(SCRIPT_DIR, "Previews")
SCREENSHOTS_DIR = os.path.join(SCRIPT_DIR, "Screenshots")

# Screenshots per language
SCREENSHOTS = {
    "en": {
        "home": os.path.join(SCREENSHOTS_DIR, "02_home_en.png"),
        "paywall": os.path.join(SCREENSHOTS_DIR, "07_paywall_en.png"),
        "home_ipad": os.path.join(SCREENSHOTS_DIR, "02_home_ipad_en.png"),
        "paywall_ipad": os.path.join(SCREENSHOTS_DIR, "07_paywall_ipad_en.png"),
    },
    "tr": {
        "home": os.path.join(SCREENSHOTS_DIR, "02_home_tr.png"),
        "paywall": os.path.join(SCREENSHOTS_DIR, "07_paywall_tr.png"),
        "home_ipad": os.path.join(SCREENSHOTS_DIR, "02_home_ipad_tr.png"),
        "paywall_ipad": os.path.join(SCREENSHOTS_DIR, "07_paywall_ipad_tr.png"),
    },
}

# Fonts
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_REG = "/System/Library/Fonts/Supplemental/Arial.ttf"
FONT_BOLD_TL = "/System/Library/Fonts/SFCompact.ttf"  # ₺ symbol support

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

# Localized texts
TEXTS = {
    "en": {
        "hero_1": "15 Professional",
        "hero_2": "SPC Calculators",
        "hero_sub_1": "Quality engineering calculations",
        "hero_sub_2": "now in your pocket",
        "feat_title_1": "All SPC Tools",
        "feat_title_2": "In One Place",
        "features": [
            "Cp/Cpk & Pp/Ppk Analysis",
            "OEE & Sigma Level",
            "Control Charts & Histogram",
            "Pareto & FMEA Analysis",
            "Gage R&R & Hypothesis Test",
        ],
        "pro_title": "SPC Tools PRO",
        "pro_sub": "Unlimited access, 7-day free trial",
        "benefits": [
            "15 professional SPC calculators",
            "Unlimited calculation history",
            "All SPC tools and analysis",
        ],
        "monthly": "$2.99 / mo",
        "monthly_sub": "Monthly plan",
        "yearly": "$19.99 / yr",
        "yearly_sub": "Save 44%",
    },
    "tr": {
        "hero_1": "15 Profesyonel",
        "hero_2": "SPC Hesaplayıcı",
        "hero_sub_1": "Kalite mühendisliği hesaplamalarınız",
        "hero_sub_2": "artık cebinizde",
        "feat_title_1": "Tüm SPC Araçları",
        "feat_title_2": "Tek Yerde",
        "features": [
            "Cp/Cpk & Pp/Ppk Analizi",
            "OEE & Sigma Seviyesi",
            "Kontrol Grafikleri & Histogram",
            "Pareto & FMEA Analizi",
            "Gage R&R & Hipotez Testi",
        ],
        "pro_title": "SPC Tools PRO",
        "pro_sub": "Sınırsız erişim, 7 gün ücretsiz",
        "benefits": [
            "15 profesyonel SPC hesaplayıcı",
            "Sınırsız hesaplama geçmişi",
            "Tüm SPC araçları ve analiz",
        ],
        "monthly": "₺49,99 / ay",
        "monthly_sub": "Aylık abonelik",
        "yearly": "₺349,99 / yıl",
        "yearly_sub": "%42 tasarruf",
    },
}


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


def add_tablet_frame(canvas, screenshot_path, pos, tablet_size, corner_radius=40):
    """Frameless modern style for iPad: wider aspect ratio, rounded + drop shadow."""
    screenshot = Image.open(screenshot_path).convert("RGBA")
    screenshot = screenshot.resize(tablet_size, Image.LANCZOS)
    radius = int(tablet_size[0] * 0.04)

    rounded = round_corners(screenshot, radius)

    shadow_pad = 50
    shadow = Image.new("RGBA", (tablet_size[0] + shadow_pad * 2, tablet_size[1] + shadow_pad * 2), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [(shadow_pad, shadow_pad),
         (tablet_size[0] + shadow_pad - 1, tablet_size[1] + shadow_pad - 1)],
        radius=radius, fill=(0, 0, 0, 50)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=30))
    canvas.paste(shadow, (pos[0] - shadow_pad, pos[1] - shadow_pad + 12), shadow)
    canvas.paste(rounded, pos, rounded)


def text_centered(draw, text, y, font, fill, w):
    bbox = draw.textbbox((0, 0), text, font=font)
    draw.text(((w - (bbox[2] - bbox[0])) // 2, y), text, font=font, fill=fill)


def generate_preview_1(size, prefix, lang, screenshots):
    """Hero: Blue gradient + device mockup showing home screen."""
    w, h = size
    s = w / 1242
    is_ipad = prefix.startswith("ipad")
    t = TEXTS[lang]

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

    text_centered(draw, t["hero_1"], int(120 * s), tf, WHITE, w)
    text_centered(draw, t["hero_2"], int(120 * s + 95 * s), tf, WHITE, w)
    text_centered(draw, t["hero_sub_1"], int(120 * s + 220 * s), sf, (255, 255, 255, 210), w)
    text_centered(draw, t["hero_sub_2"], int(120 * s + 270 * s), sf, (255, 255, 255, 210), w)

    if is_ipad:
        pw = int(900 * s)
        ph = int(1200 * s)
        px = (w - pw) // 2
        py = int(480 * s)
        add_tablet_frame(canvas, screenshots["home_ipad"], (px, py), (pw, ph))
    else:
        pw = int(580 * s)
        ph = int(1250 * s)
        px = (w - pw) // 2
        py = int(480 * s)
        add_phone_frame(canvas, screenshots["home"], (px, py), (pw, ph), int(45 * s))

    canvas.convert("RGB").save(os.path.join(OUT_DIR, f"{prefix}_preview_1_{lang}.png"))
    print(f"  Saved {prefix}_preview_1_{lang}.png")


def generate_preview_2(size, prefix, lang, screenshots):
    """Features: Light bg + feature cards + device mockup."""
    w, h = size
    s = w / 1242
    is_ipad = prefix.startswith("ipad")
    t = TEXTS[lang]

    canvas = Image.new("RGBA", size, LIGHT_BG)
    draw = ImageDraw.Draw(canvas)

    draw.rectangle([(0, 0), (w, int(10 * s))], fill=BLUE)

    tf = ImageFont.truetype(FONT_BOLD, int(68 * s))
    ff = ImageFont.truetype(FONT_REG, int(38 * s))
    cf = ImageFont.truetype(FONT_BOLD, int(26 * s))

    text_centered(draw, t["feat_title_1"], int(100 * s), tf, DARK, w)
    text_centered(draw, t["feat_title_2"], int(100 * s + 85 * s), tf, BLUE, w)

    margin = int(100 * s)
    y0 = int(320 * s)
    row_h = int(95 * s)

    for i, text in enumerate(t["features"]):
        y = y0 + i * row_h
        draw.rounded_rectangle([(margin, y), (w - margin, y + int(70 * s))], radius=int(16 * s), fill=WHITE)
        cx = margin + int(45 * s)
        cy = y + int(35 * s)
        r = int(20 * s)
        draw.ellipse([(cx - r, cy - r), (cx + r, cy + r)], fill=BLUE)
        draw.text((cx - int(8 * s), cy - int(14 * s)), "✓", font=cf, fill=WHITE)
        draw.text((cx + r + int(22 * s), y + int(15 * s)), text, font=ff, fill=DARK)

    if is_ipad:
        pw = int(880 * s)
        ph = int(1170 * s)
        px = (w - pw) // 2
        py = int(820 * s)
        add_tablet_frame(canvas, screenshots["home_ipad"], (px, py), (pw, ph))
    else:
        pw = int(560 * s)
        ph = int(1210 * s)
        px = (w - pw) // 2
        py = int(820 * s)
        add_phone_frame(canvas, screenshots["home"], (px, py), (pw, ph), int(42 * s))

    canvas.convert("RGB").save(os.path.join(OUT_DIR, f"{prefix}_preview_2_{lang}.png"))
    print(f"  Saved {prefix}_preview_2_{lang}.png")


def generate_preview_3(size, prefix, lang, screenshots):
    """PRO: Dark bg + blue glow + benefits + paywall mockup."""
    w, h = size
    s = w / 1242
    is_ipad = prefix.startswith("ipad")
    t = TEXTS[lang]

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
    price_font = FONT_BOLD_TL if lang == "tr" else FONT_BOLD
    label_font = FONT_BOLD_TL if lang == "tr" else FONT_REG
    pf = ImageFont.truetype(price_font, int(42 * s))
    lf = ImageFont.truetype(label_font, int(28 * s))

    text_centered(draw, t["pro_title"], int(100 * s), tf, BLUE, w)
    text_centered(draw, t["pro_sub"], int(100 * s + 95 * s), sf, (180, 180, 180), w)

    y0 = int(320 * s)
    for i, text in enumerate(t["benefits"]):
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
    draw.text((mx + int(30 * s), py + int(18 * s)), t["monthly"], font=pf, fill=WHITE)
    draw.text((mx + int(30 * s), py + int(68 * s)), t["monthly_sub"], font=lf, fill=(150, 150, 150))

    yx = w // 2 + gap // 2
    draw.rounded_rectangle([(yx, py), (yx + bw, py + bh)], radius=int(20 * s), fill=BLUE)
    draw.text((yx + int(30 * s), py + int(18 * s)), t["yearly"], font=pf, fill=WHITE)
    draw.text((yx + int(30 * s), py + int(68 * s)), t["yearly_sub"], font=lf, fill=(255, 255, 255, 220))

    # TR: home screenshot (paywall shows $ prices), EN: paywall screenshot
    if is_ipad:
        pw = int(880 * s)
        ph2 = int(1170 * s)
        ppx = (w - pw) // 2
        ppy = int(780 * s)
        shot = screenshots["home_ipad"] if lang == "tr" else screenshots["paywall_ipad"]
        add_tablet_frame(canvas, shot, (ppx, ppy), (pw, ph2))
    else:
        pw = int(560 * s)
        ph2 = int(1210 * s)
        ppx = (w - pw) // 2
        ppy = int(780 * s)
        shot = screenshots["home"] if lang == "tr" else screenshots["paywall"]
        add_phone_frame(canvas, shot, (ppx, ppy), (pw, ph2), int(42 * s))

    canvas.convert("RGB").save(os.path.join(OUT_DIR, f"{prefix}_preview_3_{lang}.png"))
    print(f"  Saved {prefix}_preview_3_{lang}.png")


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)

    print(f"Screenshots: {SCREENSHOTS_DIR}")
    print(f"Output: {OUT_DIR}\n")

    for lang, screenshots in SCREENSHOTS.items():
        print(f"\n=== Language: {lang.upper()} ===")
        for name, size in SIZES.items():
            print(f"\n--- {name} ({size[0]}x{size[1]}) ---")
            generate_preview_1(size, name, lang, screenshots)
            generate_preview_2(size, name, lang, screenshots)
            generate_preview_3(size, name, lang, screenshots)

    print(f"\nDone! Output: {OUT_DIR}")
