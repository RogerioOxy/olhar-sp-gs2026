from pathlib import Path

from PIL import Image, ImageDraw

VERDE = (11, 93, 82, 255)
VERDE_CLARO = (213, 237, 231, 255)
AMBAR = (242, 169, 0, 255)
BRANCO = (255, 255, 255, 255)

TAMANHOS = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}


def desenhar(lado):
    escala = 4
    s = lado * escala
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, s - 1, s - 1], radius=int(s * 0.22), fill=VERDE)
    base = int(s * 0.80)
    larguras = [0.14, 0.14, 0.14]
    alturas = [0.28, 0.42, 0.20]
    x = int(s * 0.16)
    for lw, lh in zip(larguras, alturas):
        w = int(s * lw)
        d.rectangle([x, base - int(s * lh), x + w, base], fill=VERDE_CLARO)
        x += w + int(s * 0.03)
    cx, cy, r = int(s * 0.68), int(s * 0.40), int(s * 0.17)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=BRANCO)
    d.polygon([(cx - int(r * 0.86), cy + int(r * 0.5)), (cx + int(r * 0.86), cy + int(r * 0.5)), (cx, cy + int(r * 2.1))], fill=BRANCO)
    ri = int(r * 0.48)
    d.ellipse([cx - ri, cy - ri, cx + ri, cy + ri], fill=AMBAR)
    d.rectangle([int(s * 0.12), base, int(s * 0.88), base + int(s * 0.035)], fill=VERDE_CLARO)
    return img.resize((lado, lado), Image.LANCZOS)


if __name__ == "__main__":
    raiz = Path(__file__).resolve().parent.parent / "android" / "app" / "src" / "main" / "res"
    for pasta, lado in TAMANHOS.items():
        desenhar(lado).save(raiz / f"mipmap-{pasta}" / "ic_launcher.png")
    desenhar(512).save(Path(__file__).resolve().parent.parent / "assets" / "icone.png")
