import math

from lib import (
    Template,
    band,
    blob,
    circle,
    ellipse,
    halfplane_above,
    lens,
    petal,
    poly,
    rect,
    union,
)

CAT = "flowers_garden"


def flower():
    t = Template("flower", "Flower", CAT)
    t.region("left_leaf", lens((497, 835), -150, 230, 105), "green")
    t.region("right_leaf", lens((503, 750), -30, 230, 105), "lightgreen")
    t.region("stem", band([(500, 470), (508, 640), (494, 800), (500, 935)], 36), "green")
    c = (500, 360)
    for i in range(5):
        a = -90 + i * 72
        base = (c[0] + 60 * math.cos(math.radians(a)), c[1] + 60 * math.sin(math.radians(a)))
        t.region(
            f"petal_{i + 1}",
            petal(base, a, 245, 170),
            ["red", "pink", "purple", "orange", "pink"][i],
            label=f"Petal {i + 1}",
        )
    t.region("center", circle(*c, 105), "yellow")
    t.eyes(500, 345, 70, 15)
    t.smile(500, 385, 60, 22)
    t.line([(470, 860), (480, 900)], 9, smooth=False)
    return t


def flower_pot():
    t = Template("flower_pot", "Flower Pot", CAT)
    t.region("stem", band([(500, 600), (495, 450), (500, 330)], 40), "green")
    t.region("left_leaf", lens((498, 565), -155, 250, 120), "green")
    t.region("right_leaf", lens((502, 565), -25, 250, 120), "lightgreen")
    t.region("soil", ellipse(500, 610, 172, 34), "brown")
    t.region("pot", poly([(325, 640), (675, 640), (630, 930), (370, 930)], 22), "orange")
    t.region("rim", rect(295, 590, 410, 78, 26), "red")
    head = union(
        circle(500, 265, 125),
        *[
            circle(
                500 + 118 * math.cos(math.radians(a)),
                265 + 118 * math.sin(math.radians(a)),
                78,
            )
            for a in range(-90, 270, 45)
        ],
    )
    t.region("flower", head, "purple")
    t.region("flower_center", circle(500, 265, 72), "yellow")
    t.eyes(500, 255, 50, 12)
    t.smile(500, 280, 40, 15, 9)
    return t


def tree():
    t = Template("tree", "Tree", CAT)
    t.region("grass", ellipse(500, 935, 400, 50), "lightgreen")
    trunk = poly(
        [(400, 945), (450, 880), (455, 640), (430, 560), (570, 560), (545, 640), (550, 880), (600, 945)],
        14,
    )
    t.region("trunk", trunk, "brown")
    t.region("leaves_left", circle(335, 470, 190), "green")
    t.region("leaves_right", circle(665, 470, 190), "lightgreen")
    t.region("leaves_top", circle(500, 300, 220), "green")
    apples = [(330, 520), (640, 560), (560, 220), (400, 300), (700, 380)]
    for i, (x, y) in enumerate(apples):
        t.region(f"apple_{i + 1}", circle(x, y, 44), "red", label=f"Apple {i + 1}")
        t.line([(x, y - 44), (x + 6, y - 62)], 9, smooth=False)
    return t


def mushroom():
    t = Template("mushroom", "Mushroom", CAT)
    t.region("ground", ellipse(500, 890, 340, 62), "lightgreen")
    t.region(
        "stem",
        blob([(390, 880), (405, 720), (430, 560), (570, 560), (595, 720), (610, 880), (500, 905)]),
        "peach",
    )
    cap = union(
        ellipse(500, 540, 340, 300).intersection(halfplane_above(540)),
        ellipse(500, 540, 340, 62),
    )
    t.region("cap", cap, "red")
    spots = [(370, 380, 58), (560, 335, 64), (690, 450, 52), (480, 480, 46), (270, 500, 38)]
    for i, (x, y, r) in enumerate(spots):
        t.region(f"spot_{i + 1}", circle(x, y, r).intersection(cap.buffer(-16)), "white", label=f"Spot {i + 1}")
    t.eyes(500, 690, 80, 17)
    t.smile(500, 740, 60, 24)
    t.line([(250, 850), (270, 800)], 9, smooth=False)
    t.line([(740, 850), (725, 805)], 9, smooth=False)
    return t


def leaf():
    t = Template("leaf", "Leaf", CAT)
    from shapely import affinity
    from shapely.geometry import Polygon

    t.region("stem", band([(150, 880), (230, 790), (300, 730)], 34), "brown")
    length, width = 780, 440
    body = lens((0, 0), 0, length, width)
    veins = [140, 290, 450, 610]
    slant = 120
    cells = []
    for side in (-1, 1):
        edges = [0] + veins + [length + 300]
        for j in range(len(edges) - 1):
            a, b = edges[j], edges[j + 1]
            cell = Polygon(
                [
                    (a, 0),
                    (a + slant, side * 400),
                    (b + slant, side * 400),
                    (b, 0),
                ]
            )
            cells.append(cell)
    angle = -40
    origin = (270, 760)

    def place(g):
        return affinity.translate(affinity.rotate(g, angle, origin=(0, 0)), *origin)

    colours = ["green", "lightgreen"]
    for i, cell in enumerate(cells):
        piece = cell.intersection(body)
        if piece.area < 2000:
            continue
        t.region(f"section_{i + 1}", place(piece), colours[(i + i // 5) % 2], label=f"Leaf part {i + 1}")
    from shapely.geometry import LineString

    rib = LineString([(10, 0), (length - 40, 0)]).buffer(15, cap_style=1)
    t.region("vein", place(rib.intersection(body.buffer(-6))), "yellow", label="Middle vein")
    return t


TEMPLATES = [flower, flower_pot, tree, mushroom, leaf]
