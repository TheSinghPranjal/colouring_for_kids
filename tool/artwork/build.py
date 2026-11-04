"""Generates every coloring template into assets/coloring/.

Usage (from the project root, with shapely + pillow installed):
    python3 tool/artwork/build.py [--preview OUT_DIR] [category ...]

For each sketch this writes outline.svg, regions.json and template.json.
Thumbnails are rendered afterwards by the Flutter renderer itself:
    flutter test tool/render_thumbnails_test.dart
"""

import importlib
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from lib import INK, OUTLINE_WIDTH  # noqa: E402

CATEGORIES = [
    "flowers_garden",
    "pets_farm",
    "wild_animals",
    "birds_insects",
    "underwater_world",
    "vehicles",
    "buildings_places",
    "fruits_vegetables",
    "sky_weather",
    "toys_imagination",
]

ROOT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "coloring")


def preview(templates_built, path, size=300):
    from PIL import Image, ImageDraw

    ss = 2
    cell = size * ss
    sheet = Image.new("RGB", (cell * len(templates_built), cell * 2), "white")
    draw = ImageDraw.Draw(sheet)
    k = cell / 1000
    for col, (t, visible, outline_lines) in enumerate(templates_built):
        for row in range(2):
            ox, oy = col * cell, row * cell
            if row == 0:
                for _, vis, _, demo in visible:
                    from lib import PALETTE

                    for p in vis.geoms:
                        pts = [(ox + x * k, oy + y * k) for x, y in p.exterior.coords]
                        draw.polygon(pts, fill=PALETTE[demo])
            def stroke(coords, w):
                pts = [(ox + x * k, oy + y * k) for x, y in coords]
                width = max(1, int(w * k))
                draw.line(pts, fill=INK, width=width, joint="curve")
                for x, y in (pts[0], pts[-1]):
                    draw.ellipse([x - width / 2, y - width / 2, x + width / 2, y + width / 2], fill=INK)

            for line in outline_lines:
                stroke(line.coords, OUTLINE_WIDTH)
            for pts, w in t.lines:
                stroke(pts, w)
            for geom, colour in t.dots:
                for p in getattr(geom, "geoms", [geom]):
                    draw.polygon([(ox + x * k, oy + y * k) for x, y in p.exterior.coords], fill=colour)
            draw.text((ox + 10, oy + 10), f"{t.id} ({len(visible)})", fill="black")
    sheet = sheet.resize((size * len(templates_built), size * 2), Image.LANCZOS)
    sheet.save(path)


def main():
    args = sys.argv[1:]
    preview_dir = None
    if "--preview" in args:
        i = args.index("--preview")
        preview_dir = args[i + 1]
        del args[i : i + 2]
    cats = args or CATEGORIES
    for cat in cats:
        module = importlib.import_module(f"sketches.{cat}")
        built = []
        for factory in module.TEMPLATES:
            t = factory()
            assert t.category == cat, f"{t.id} has category {t.category}"
            visible, outline_lines = t.write(ROOT)
            smallest = min(visible, key=lambda v: v[1].area)
            print(
                f"{cat}/{t.id}: {len(visible)} regions, smallest "
                f"{smallest[0]}={smallest[1].area:.0f}"
            )
            built.append((t, visible, outline_lines))
        assert len(built) == 10, f"{cat} must have exactly ten sketches"
        if preview_dir:
            os.makedirs(preview_dir, exist_ok=True)
            preview(built, os.path.join(preview_dir, f"{cat}.png"))


if __name__ == "__main__":
    main()
