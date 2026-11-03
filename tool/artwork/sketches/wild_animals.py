import math

from shapely.geometry import Polygon

from lib import Template, band, blob, circle, ellipse, lens, mirror, poly, rect, union

CAT = "wild_animals"


def hexagon(cx, cy, r, rot=0):
    return poly(
        [
            (cx + r * math.cos(math.radians(rot + 60 * i)), cy + r * math.sin(math.radians(rot + 60 * i)))
            for i in range(6)
        ],
        12,
    )


def wedge(cx, cy, a0, a1, r=900):
    pts = [(cx, cy)]
    steps = 12
    for i in range(steps + 1):
        a = math.radians(a0 + (a1 - a0) * i / steps)
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return Polygon(pts)


def elephant():
    t = Template("elephant", "Elephant", CAT)
    tail = union(band([(820, 470), (860, 560), (865, 620)], 20), ellipse(866, 640, 22, 32))
    t.region("tail", tail, "grey")
    legs = [(330, 590), (450, 600), (610, 600), (715, 590)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 100, 270, 42), "grey", label=f"Leg {i + 1}")
    t.region("body", ellipse(580, 500, 290, 210), "grey")
    t.region("head", circle(300, 400, 160), "grey")
    t.region("trunk", band([(205, 440), (165, 560), (175, 690), (240, 740)], 76), "grey")
    t.region("ear", ellipse(450, 420, 115, 150, -8), "pink")
    t.region("tusk", lens((235, 520), 160, 110, 40), "white")
    t.eye(250, 360, 21)
    t.smile(290, 470, 40, 14, 9)
    for x, y in legs:
        for k in range(3):
            t.line([(x + 22 + k * 28, y + 250), (x + 22 + k * 28, y + 232)], 8, smooth=False)
    return t


def turtle():
    t = Template("turtle", "Turtle", CAT)
    legs = [(300, 620), (390, 630), (580, 630), (670, 620)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 86, 140, 38), "lightgreen", label=f"Leg {i + 1}")
    t.region("tail", poly([(770, 575), (905, 640), (770, 665)], 14), "lightgreen")
    t.region("head", union(circle(195, 500, 100), band([(210, 545), (330, 600)], 100)), "lightgreen")
    dome = ellipse(510, 600, 300, 260).intersection(rect(150, 300, 720, 330))
    t.region("shell", dome, "green")
    plates = [
        hexagon(510, 470, 92, 0),
        hexagon(345, 535, 66, 0),
        hexagon(675, 535, 66, 0),
        hexagon(425, 385, 58, 0),
        hexagon(595, 385, 58, 0),
    ]
    for i, p in enumerate(plates):
        t.region(f"plate_{i + 1}", p.intersection(dome.buffer(-18)), "yellow", label=f"Shell part {i + 1}")
    t.region("rim", rect(200, 595, 620, 64, 32), "brown", label="Shell edge")
    t.eye(180, 475, 21)
    t.smile(170, 525, 50, 18)
    return t


def lion():
    t = Template("lion", "Lion", CAT)
    tail = union(band([(650, 860), (790, 830), (850, 730)], 28), circle(862, 705, 42))
    t.region("tail", tail, "yellow")
    t.region("body", ellipse(500, 760, 170, 170), "yellow")
    t.region("left_leg", rect(395, 790, 92, 140, 44), "yellow")
    t.region("right_leg", rect(513, 790, 92, 140, 44), "yellow")
    mane = union(
        circle(500, 390, 215),
        *[
            circle(500 + 205 * math.cos(math.radians(a)), 390 + 205 * math.sin(math.radians(a)), 70)
            for a in range(0, 360, 30)
        ],
    )
    for i in range(4):
        a0 = -135 + i * 90
        t.region(
            f"mane_{i + 1}",
            mane.intersection(wedge(500, 390, a0, a0 + 90)),
            ["orange", "brown"][i % 2],
            label=f"Mane {i + 1}",
        )
    t.region("left_ear", circle(395, 255, 46), "yellow")
    t.region("right_ear", circle(605, 255, 46), "yellow")
    t.region("face", circle(500, 400, 155), "yellow")
    t.region("muzzle", ellipse(500, 465, 88, 58), "peach")
    t.eyes(500, 375, 120, 21)
    t.shape_detail(poly([(472, 425), (528, 425), (500, 458)], 8))
    t.line([(500, 455), (500, 475)], 9, smooth=False)
    t.line([(460, 480), (480, 495), (500, 475), (520, 495), (540, 480)], 9)
    for x in (420, 450, 550, 580):
        t.line([(x, 908), (x, 928)], 8, smooth=False)
    return t


def monkey():
    t = Template("monkey", "Monkey", CAT)
    t.region(
        "tail", band([(620, 810), (790, 800), (870, 700), (830, 610), (760, 620), (765, 690)], 32), "brown"
    )
    t.region("body", ellipse(500, 690, 155, 175), "brown")
    t.region("belly", ellipse(500, 715, 92, 112), "peach")
    t.region("left_arm", band([(390, 590), (320, 690), (370, 790), (420, 800)], 62), "brown")
    t.region("right_arm", mirror(band([(390, 590), (320, 690), (370, 790), (420, 800)], 62)), "brown")
    t.region("left_leg", ellipse(410, 860, 88, 52, 10), "brown")
    t.region("right_leg", ellipse(590, 860, 88, 52, -10), "brown")
    t.region("left_ear", circle(320, 370, 70), "peach")
    t.region("right_ear", circle(680, 370, 70), "peach")
    t.region("head", circle(500, 370, 165), "brown")
    face = union(circle(445, 355, 72), circle(555, 355, 72), ellipse(500, 440, 115, 75))
    t.region("face", face, "peach")
    t.eyes(500, 350, 110, 21)
    t.dot(485, 418, 8)
    t.dot(515, 418, 8)
    t.smile(500, 450, 90, 34)
    return t


def giraffe():
    t = Template("giraffe", "Giraffe", CAT)
    t.region("back_legs", union(rect(650, 640, 52, 290, 24), rect(720, 640, 52, 290, 24)), "yellow")
    t.region("front_legs", union(rect(440, 640, 52, 290, 24), rect(510, 640, 52, 290, 24)), "yellow")
    tail = union(band([(800, 560), (850, 660)], 16), ellipse(856, 690, 20, 32))
    t.region("tail", tail, "yellow")
    body = ellipse(605, 580, 220, 115)
    t.region("body", body, "yellow")
    neck = poly([(300, 260), (415, 235), (585, 545), (450, 610)], 30)
    t.region("neck", neck, "yellow")
    horns = union(
        band([(300, 175), (290, 105)], 18), circle(290, 98, 22), band([(350, 170), (360, 100)], 18), circle(362, 94, 22)
    )
    t.region("horns", horns, "brown")
    t.region("head", union(ellipse(320, 225, 105, 70, -12), ellipse(240, 255, 62, 50, -12)), "yellow")
    spots = [
        (body, ellipse(560, 560, 52, 40, 20)),
        (body, ellipse(690, 600, 50, 42, -10)),
        (body, ellipse(700, 510, 34, 28)),
        (neck, ellipse(430, 420, 38, 50, -30)),
        (neck, ellipse(370, 310, 30, 38, -30)),
    ]
    for i, (host, s) in enumerate(spots):
        t.region(f"spot_{i + 1}", s.intersection(host.buffer(-14)), "orange", label=f"Spot {i + 1}")
    t.eye(325, 205, 19)
    t.dot(212, 248, 8)
    t.smile(255, 280, 40, 12, 9)
    for x in (440, 510, 650, 720):
        t.line([(x + 6, 895), (x + 46, 895)], 8, smooth=False)
    return t


TEMPLATES = [elephant, turtle, lion, monkey, giraffe]
