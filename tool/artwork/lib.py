"""Geometry toolkit for authoring the coloring templates.

Every template is authored as an ordered list of shapes (later shapes sit on
top of earlier ones). The builder turns that stack into a *planar partition*:
each region keeps only its visible part, so regions never overlap, neighbours
share exactly the same boundary, and hit-testing is unambiguous. The outline
is generated from those same boundaries (plus non-fillable detail strokes such
as eyes and smiles), so fills and line art can never drift apart.

Coordinates use a 1000 x 1000 view box with y pointing down.
"""

import json
import math
import os

from shapely import affinity
from shapely.geometry import (
    GeometryCollection,
    LineString,
    MultiLineString,
    MultiPolygon,
    Point,
    Polygon,
    box,
)
from shapely.ops import linemerge, unary_union

VIEW = 1000
OUTLINE_WIDTH = 14
DETAIL_WIDTH = 11
INK = "#1F1B2E"
QUAD = 24

PALETTE = {
    "red": "#E53935",
    "orange": "#FB8C00",
    "yellow": "#FDD835",
    "green": "#43A047",
    "lightgreen": "#9CCC65",
    "blue": "#1E88E5",
    "skyblue": "#4FC3F7",
    "purple": "#8E24AA",
    "pink": "#F48FB1",
    "brown": "#8D6E63",
    "black": "#212121",
    "white": "#FFFFFF",
    "grey": "#9E9E9E",
    "peach": "#FFCCBC",
    "teal": "#26A69A",
    "darkblue": "#283593",
}

# --------------------------------------------------------------------------
# Primitive shapes
# --------------------------------------------------------------------------


def circle(cx, cy, r):
    return Point(cx, cy).buffer(r, quad_segs=QUAD)


def ellipse(cx, cy, rx, ry, rot=0):
    e = affinity.scale(Point(0, 0).buffer(1, quad_segs=QUAD), rx, ry, origin=(0, 0))
    if rot:
        e = affinity.rotate(e, rot, origin=(0, 0))
    return affinity.translate(e, cx, cy)


def rect(x, y, w, h, r=0):
    if r <= 0:
        return box(x, y, x + w, y + h)
    r = min(r, w / 2 - 0.01, h / 2 - 0.01)
    return box(x + r, y + r, x + w - r, y + h - r).buffer(r, quad_segs=QUAD)


def rounded(geom, r):
    """Rounds convex corners of a shape by r."""
    return geom.buffer(-r, quad_segs=QUAD, join_style=1).buffer(r, quad_segs=QUAD, join_style=1)


def poly(points, r=0):
    p = Polygon(points)
    if not p.is_valid:
        p = p.buffer(0)
    return rounded(p, r) if r else p


def catmull(points, closed=True, n=12):
    pts = list(points)
    count = len(pts)
    out = []
    segs = count if closed else count - 1
    for i in range(segs):
        if closed:
            p0, p1, p2, p3 = (
                pts[(i - 1) % count],
                pts[i],
                pts[(i + 1) % count],
                pts[(i + 2) % count],
            )
        else:
            p0 = pts[max(i - 1, 0)]
            p1 = pts[i]
            p2 = pts[i + 1]
            p3 = pts[min(i + 2, count - 1)]
        for k in range(n):
            t = k / n
            t2, t3 = t * t, t * t * t
            x = 0.5 * (
                2 * p1[0]
                + (-p0[0] + p2[0]) * t
                + (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * t2
                + (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * t3
            )
            y = 0.5 * (
                2 * p1[1]
                + (-p0[1] + p2[1]) * t
                + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t2
                + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * t3
            )
            out.append((x, y))
    if not closed:
        out.append(pts[-1])
    return out


def blob(points):
    """Smooth closed shape through the given points."""
    return Polygon(catmull(points, True)).buffer(0)


def band(points, width, smooth=True):
    """A thick rounded stroke along a (smoothed) polyline."""
    line = LineString(catmull(points, False) if smooth and len(points) > 2 else points)
    return line.buffer(width / 2, quad_segs=QUAD, cap_style=1, join_style=1)


def lens(base, angle, length, width):
    """A pointed leaf / petal shape starting at `base`, pointing at `angle`
    degrees (0 = right, 90 = down)."""
    half = length / 2
    s = width / 2
    radius = (half * half + s * s) / (2 * s)
    off = radius - s
    a = Point(0, -off).buffer(radius, quad_segs=QUAD * 2)
    b = Point(0, off).buffer(radius, quad_segs=QUAD * 2)
    shape = a.intersection(b)  # centred at origin, horizontal
    shape = affinity.translate(shape, half, 0)
    shape = affinity.rotate(shape, angle, origin=(0, 0))
    return affinity.translate(shape, base[0], base[1])


def petal(base, angle, length, width):
    """A rounded oval petal starting at `base` pointing at `angle`."""
    e = ellipse(length / 2, 0, length / 2, width / 2)
    e = affinity.rotate(e, angle, origin=(0, 0))
    return affinity.translate(e, base[0], base[1])


def star(cx, cy, r_out, r_in=None, n=5, rot=-90, r=8):
    r_in = r_in or r_out * 0.48
    pts = []
    for i in range(n * 2):
        a = math.radians(rot + i * 180 / n)
        rr = r_out if i % 2 == 0 else r_in
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    return poly(pts, r)


def teardrop(cx, cy, r, height=2.3, rot=0):
    """Rounded drop with its tip pointing up (before rotation)."""
    tip = (cx, cy - r * height)
    tri = Polygon([(cx - r * 0.95, cy - r * 0.3), tip, (cx + r * 0.95, cy - r * 0.3)])
    shape = rounded(unary_union([circle(cx, cy, r), tri]), r * 0.12)
    return affinity.rotate(shape, rot, origin=(cx, cy)) if rot else shape


def annulus(cx, cy, r_out, r_in):
    return circle(cx, cy, r_out).difference(circle(cx, cy, r_in))


def union(*geoms):
    return unary_union(list(geoms))


def mirror(geom, axis_x=500):
    return affinity.scale(geom, -1, 1, origin=(axis_x, 0))


def mirror_pts(points, axis_x=500):
    return [(2 * axis_x - x, y) for x, y in points]


def arc_pts(cx, cy, r, a0, a1, n=24, ry=None):
    ry = ry if ry is not None else r
    return [
        (
            cx + r * math.cos(math.radians(a0 + (a1 - a0) * i / n)),
            cy + ry * math.sin(math.radians(a0 + (a1 - a0) * i / n)),
        )
        for i in range(n + 1)
    ]


def halfplane_below(y):
    return box(-100, y, VIEW + 100, VIEW + 100)


def halfplane_above(y):
    return box(-100, -100, VIEW + 100, y)


# --------------------------------------------------------------------------
# Template builder
# --------------------------------------------------------------------------


class Template:
    def __init__(self, tid, title, category, audio_label=None):
        self.id = tid
        self.title = title
        self.category = category
        self.audio_label = audio_label or title
        self.regions = []  # (id, geometry, label, demo color)
        self.lines = []  # (points, width)
        self.dots = []  # (geometry, colour)

    # Fillable regions, in back-to-front order.
    def region(self, rid, geom, demo="white", label=None):
        assert all(r[0] != rid for r in self.regions), f"{self.id}: duplicate {rid}"
        self.regions.append((rid, geom, label or rid.replace("_", " ").capitalize(), demo))
        return geom

    # Non-fillable detail strokes drawn as part of the outline.
    def line(self, points, width=DETAIL_WIDTH, smooth=True):
        pts = catmull(points, False) if smooth and len(points) > 2 else list(points)
        self.lines.append((pts, width))

    def closed_line(self, points, width=DETAIL_WIDTH):
        pts = catmull(points, True)
        pts.append(pts[0])
        self.lines.append((pts, width))

    def arc(self, cx, cy, r, a0, a1, width=DETAIL_WIDTH, ry=None):
        self.lines.append((arc_pts(cx, cy, r, a0, a1, ry=ry), width))

    def dot(self, cx, cy, r, colour=INK):
        self.dots.append((circle(cx, cy, r), colour))

    def shape_detail(self, geom, colour=INK):
        self.dots.append((geom, colour))

    # Friendly face helpers ------------------------------------------------
    def eye(self, cx, cy, r=20):
        self.dot(cx, cy, r)
        self.dot(cx + r * 0.32, cy - r * 0.35, r * 0.32, "#FFFFFF")

    def eyes(self, cx, cy, spacing, r=20):
        self.eye(cx - spacing / 2, cy, r)
        self.eye(cx + spacing / 2, cy, r)

    def smile(self, cx, cy, w, depth=None, width=DETAIL_WIDTH):
        depth = depth if depth is not None else w * 0.45
        self.line([(cx - w / 2, cy), (cx, cy + depth), (cx + w / 2, cy)], width)

    def sleepy_eye(self, cx, cy, w, width=DETAIL_WIDTH):
        self.line([(cx - w / 2, cy), (cx, cy + w * 0.35), (cx + w / 2, cy)], width)

    # ---------------------------------------------------------------------
    def build(self):
        canvas = box(0, 0, VIEW, VIEW)
        geoms = [r[1] for r in self.regions]
        visible = []
        for i, (rid, geom, label, demo) in enumerate(self.regions):
            above = unary_union(geoms[i + 1 :]) if i + 1 < len(geoms) else None
            vis = geom.intersection(canvas)
            if above is not None and not above.is_empty:
                vis = vis.difference(above)
            vis = _polygons(vis)
            if vis.is_empty or vis.area < 400:
                raise ValueError(f"{self.id}/{rid}: region is hidden (area {vis.area:.0f})")
            visible.append((rid, vis, label, demo))

        # Outline = every visible boundary, merged so shared edges appear once.
        rings = []
        for _, vis, _, _ in visible:
            for p in vis.geoms:
                rings.append(LineString(p.exterior.coords))
                rings.extend(LineString(i.coords) for i in p.interiors)
        merged = linemerge(unary_union(rings))
        outline_lines = list(merged.geoms) if isinstance(merged, MultiLineString) else [merged]
        outline_lines = [l.simplify(0.4) for l in outline_lines if l.length > 1]

        fills = []
        for rid, vis, label, demo in visible:
            # Open the shape slightly to drop hair-thin slivers (always hidden
            # under the 14 unit outline anyway), then simplify.
            fill = _polygons(vis.buffer(-1.5, quad_segs=4).buffer(1.5, quad_segs=4))
            fill = _polygons(fill.intersection(vis.buffer(0.01)))
            fill = MultiPolygon([p for p in fill.geoms if p.area > 120])
            fills.append(_polygons(fill.simplify(0.35, preserve_topology=True)))
        # Simplifying each region separately can make neighbours overlap by a
        # fraction of a unit; trim every region by the ones above it so the
        # shipped geometry is an exact partition (any hairline gap is far
        # narrower than the outline drawn over it).
        for i in range(len(fills)):
            above = unary_union(fills[i + 1 :]) if i + 1 < len(fills) else None
            if above is not None and not above.is_empty:
                trimmed = _polygons(fills[i].difference(above.buffer(0.15, quad_segs=2)))
                fills[i] = MultiPolygon([p for p in trimmed.geoms if p.area > 120])

        regions_json = []
        for z, (rid, vis, label, demo) in enumerate(visible):
            fill = fills[z]
            regions_json.append(
                {
                    "id": rid,
                    "label": label,
                    "z": z,
                    "fillable": True,
                    "demoColor": PALETTE[demo],
                    "area": round(vis.area),
                    "bounds": [round(v, 1) for v in vis.bounds],
                    "path": _polygon_path(fill),
                }
            )
        return visible, outline_lines, regions_json

    def write(self, root):
        visible, outline_lines, regions_json = self.build()
        folder = os.path.join(root, self.category, self.id)
        os.makedirs(folder, exist_ok=True)
        with open(os.path.join(folder, "regions.json"), "w") as f:
            json.dump(
                {
                    "version": 1,
                    "templateId": self.id,
                    "viewBox": [0, 0, VIEW, VIEW],
                    "regions": regions_json,
                },
                f,
                separators=(",", ":"),
            )
        with open(os.path.join(folder, "outline.svg"), "w") as f:
            f.write(self._outline_svg(outline_lines))
        simple = len(regions_json) <= 8
        with open(os.path.join(folder, "template.json"), "w") as f:
            json.dump(
                {
                    "id": self.id,
                    "title": self.title,
                    "categoryId": self.category,
                    "viewBox": [0, 0, VIEW, VIEW],
                    "outline": "outline.svg",
                    "regions": "regions.json",
                    "thumbnail": "thumbnail.png",
                    "audioLabel": self.audio_label,
                    "level": "little" if simple else "explorer",
                    "regionCount": len(regions_json),
                    "features": ["fill", "draw", "stickers"],
                },
                f,
                indent=2,
            )
        return visible, outline_lines

    def _outline_svg(self, outline_lines):
        out = [
            f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {VIEW} {VIEW}" '
            f'width="{VIEW}" height="{VIEW}">'
        ]
        for line in outline_lines:
            out.append(
                f'<path d="{_line_path(line.coords, line.is_ring)}" fill="none" stroke="{INK}" '
                f'stroke-width="{OUTLINE_WIDTH}" stroke-linecap="round" stroke-linejoin="round"/>'
            )
        for pts, width in self.lines:
            out.append(
                f'<path d="{_line_path(LineString(pts).simplify(0.4).coords, False)}" fill="none" '
                f'stroke="{INK}" stroke-width="{width}" stroke-linecap="round" '
                f'stroke-linejoin="round"/>'
            )
        for geom, colour in self.dots:
            out.append(
                f'<path d="{_polygon_path(_polygons(geom).simplify(0.3))}" fill="{colour}" '
                f'stroke="none"/>'
            )
        out.append("</svg>\n")
        return "\n".join(out)


def _polygons(geom):
    if isinstance(geom, Polygon):
        return MultiPolygon([geom]) if not geom.is_empty else MultiPolygon()
    if isinstance(geom, MultiPolygon):
        return geom
    if isinstance(geom, GeometryCollection):
        polys = []
        for g in geom.geoms:
            polys.extend(_polygons(g).geoms)
        return MultiPolygon(polys)
    return MultiPolygon()


def _fmt(v):
    s = f"{v:.1f}"
    return s[:-2] if s.endswith(".0") else s


def _line_path(coords, closed):
    coords = list(coords)
    if closed and len(coords) > 1 and coords[0] == coords[-1]:
        coords = coords[:-1]
    parts = [f"M{_fmt(coords[0][0])} {_fmt(coords[0][1])}"]
    parts.extend(f"L{_fmt(x)} {_fmt(y)}" for x, y in coords[1:])
    if closed:
        parts.append("Z")
    return "".join(parts)


def _polygon_path(mp):
    parts = []
    for p in _polygons(mp).geoms:
        parts.append(_line_path(p.exterior.coords, True))
        for interior in p.interiors:
            parts.append(_line_path(interior.coords, True))
    return "".join(parts)
