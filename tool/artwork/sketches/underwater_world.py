import math

from lib import (
    Template,
    band,
    blob,
    circle,
    ellipse,
    halfplane_below,
    lens,
    mirror,
    poly,
    rect,
    teardrop,
    union,
)

CAT = "underwater_world"


def fish():
    t = Template("fish", "Fish", CAT)
    t.region("tail", poly([(720, 500), (910, 340), (870, 500), (910, 660)], 26), "orange")
    t.region("top_fin", poly([(400, 360), (540, 210), (660, 370)], 24), "orange")
    t.region("bottom_fin", poly([(500, 640), (580, 760), (650, 630)], 20), "orange")
    body = ellipse(470, 500, 290, 185)
    t.region("body", body, "yellow")
    for i, (x, y) in enumerate([(560, 430), (560, 575), (680, 500)]):
        t.region(f"scale_{i + 1}", circle(x, y, 62).intersection(body.buffer(-12)), "orange", label=f"Scale {i + 1}")
    t.region("side_fin", lens((400, 560), 25, 140, 66), "red")
    t.region("eye", circle(290, 450, 50), "white")
    t.dot(298, 452, 24)
    t.dot(306, 442, 8, "#FFFFFF")
    t.arc(250, 520, 50, 20, 130, 10)
    t.arc(320, 500, 95, 300, 420, 10)
    return t


def octopus():
    t = Template("octopus", "Octopus", CAT)
    colours = ["purple", "pink"]
    for i in range(8):
        a = math.radians(165 - i * (150 / 7))
        cx, cy = 500, 560
        base = (cx + 130 * math.cos(a), cy + 30 * math.sin(a))
        mid = (cx + 270 * math.cos(a), cy + 230 * math.sin(a) + 40)
        end = (cx + 380 * math.cos(a - 0.15), cy + 340 * math.sin(a - 0.15) + 30)
        curl = (end[0] + 50 * math.cos(a + 1.4), end[1] + 50 * math.sin(a + 1.4) - 20)
        t.region(
            f"tentacle_{i + 1}",
            band([base, mid, end, curl], 62),
            colours[i % 2],
            label=f"Tentacle {i + 1}",
        )
    t.region("body", ellipse(500, 560, 210, 85), "purple")
    head = union(ellipse(500, 360, 240, 230).intersection(rect(0, 0, 1000, 560)), ellipse(500, 540, 240, 60))
    t.region("head", head, "purple")
    t.region("spot_1", circle(370, 260, 40), "pink", label="Spot 1")
    t.region("spot_2", circle(640, 230, 32), "pink", label="Spot 2")
    t.eyes(500, 400, 140, 26)
    t.smile(500, 465, 90, 34)
    return t


def whale():
    t = Template("whale", "Whale", CAT)
    spout = union(
        band([(330, 300), (330, 200)], 30),
        teardrop(260, 200, 32, rot=-50),
        teardrop(400, 200, 32, rot=50),
        teardrop(330, 140, 34),
    )
    t.region("spout", spout, "skyblue", label="Water spout")
    tail = union(lens((800, 420), -70, 170, 80), lens((800, 420), -5, 170, 80))
    t.region("tail", tail, "blue")
    body = union(ellipse(450, 530, 330, 210), band([(640, 560), (800, 430)], 130))
    t.region("body", body, "blue")
    t.region("belly", ellipse(430, 670, 300, 120).intersection(body.buffer(-12)), "skyblue")
    t.region("fin", lens((430, 610), 135, 170, 80), "darkblue")
    t.region("cheek", circle(330, 545, 38), "pink")
    t.eye(270, 480, 24)
    t.line([(160, 548), (205, 580), (262, 578)], 10)
    for k in range(3):
        t.line([(200 + k * 90, 690 + k * 18), (290 + k * 90, 700 + k * 22)], 8, smooth=False)
    return t


def crab():
    t = Template("crab", "Crab", CAT)
    left_legs = union(
        *[
            band([(370, 580 + k * 50), (250, 560 + k * 70), (190, 650 + k * 70)], 34)
            for k in range(3)
        ]
    )
    t.region("left_legs", left_legs, "red")
    t.region("right_legs", mirror(left_legs), "red")
    claw = union(
        band([(370, 500), (300, 420), (260, 380)], 46),
        circle(230, 300, 92).difference(poly([(230, 300), (110, 170), (200, 150)])),
    )
    t.region("left_claw", claw, "orange")
    t.region("right_claw", mirror(claw), "orange")
    eye = union(band([(440, 470), (430, 360)], 26), circle(430, 330, 50))
    t.region("left_eye", eye, "white")
    t.region("right_eye", mirror(eye), "white")
    t.region("body", ellipse(500, 590, 230, 155), "red")
    t.dot(436, 330, 22)
    t.dot(444, 320, 7, "#FFFFFF")
    t.dot(564, 330, 22)
    t.dot(572, 320, 7, "#FFFFFF")
    t.smile(500, 600, 110, 40)
    return t


def seahorse():
    t = Template("seahorse", "Seahorse", CAT)
    t.region("fin", lens((610, 470), -10, 150, 110), "pink")
    t.region(
        "tail",
        band([(560, 640), (580, 780), (530, 890), (430, 890), (410, 820), (470, 800)], 64),
        "yellow",
    )
    crown = union(
        poly([(390, 210), (400, 130), (450, 200)], 10),
        poly([(440, 205), (480, 120), (510, 215)], 10),
        poly([(495, 225), (560, 160), (560, 250)], 10),
    )
    t.region("crown", crown, "orange")
    body = blob([(470, 320), (590, 360), (640, 480), (620, 610), (550, 690), (470, 650), (440, 530), (430, 420)])
    t.region("body", body, "yellow")
    belly = ellipse(470, 520, 70, 150).intersection(body.buffer(-10))
    for i, (y0, y1) in enumerate([(300, 470), (470, 560), (560, 800)]):
        t.region(
            f"belly_{i + 1}",
            belly.intersection(rect(300, y0, 400, y1 - y0)),
            ["peach", "orange", "peach"][i],
            label=f"Belly stripe {i + 1}",
        )
    head = union(ellipse(450, 290, 115, 95, -20), band([(380, 310), (250, 345)], 56), circle(240, 348, 32))
    t.region("head", head, "yellow")
    t.eye(450, 270, 22)
    t.region("cheek", circle(420, 330, 26), "pink")
    return t


def starfish():
    t = Template("starfish", "Starfish", CAT)
    from lib import star

    t.region("body", star(500, 500, 280, 120, 5), "orange")
    t.region("center", circle(500, 500, 90), "yellow")
    t.region("dot_1", circle(500, 320, 28), "red")
    t.region("dot_2", circle(650, 450, 28), "red")
    t.region("dot_3", circle(600, 650, 28), "red")
    t.region("dot_4", circle(400, 650, 28), "red")
    t.region("dot_5", circle(350, 450, 28), "red")
    t.eyes(500, 480, 55, 12)
    t.smile(500, 530, 40, 14)
    return t


def dolphin():
    t = Template("dolphin", "Dolphin", CAT)
    t.region("body", ellipse(480, 520, 260, 120, -15), "skyblue")
    t.region("belly", ellipse(480, 560, 180, 60, -15), "white")
    t.region("head", ellipse(720, 480, 110, 80, -10), "skyblue")
    t.region("fin", poly([(480, 420), (520, 300), (560, 420)], 14), "blue")
    t.region("tail", poly([(220, 520), (120, 440), (140, 560), (120, 620)], 16), "blue")
    t.region("flipper", ellipse(500, 600, 70, 35, 30), "blue")
    t.eyes(740, 460, 40, 12)
    t.smile(780, 500, 35, 12)
    return t


def jellyfish():
    t = Template("jellyfish", "Jellyfish", CAT)
    t.region("dome", ellipse(500, 380, 210, 160), "pink")
    t.region("underside", ellipse(500, 480, 180, 50), "peach")
    for i, x in enumerate((360, 430, 500, 570, 640)):
        t.region(f"tentacle_{i + 1}", band([(x, 500), (x + (i - 2) * 15, 850)], 28), "pink", label=f"Tentacle {i + 1}")
    t.eyes(500, 380, 80, 14)
    t.smile(500, 430, 55, 16)
    return t


def shark():
    t = Template("shark", "Shark", CAT)
    t.region("body", ellipse(480, 520, 280, 110), "grey")
    t.region("belly", ellipse(480, 560, 200, 50), "white")
    t.region("fin", poly([(480, 420), (520, 280), (560, 420)], 14), "grey")
    t.region("tail", poly([(200, 520), (80, 420), (100, 520), (80, 620)], 14), "grey")
    t.region("side_fin", ellipse(500, 600, 80, 35, 25), "grey")
    t.region("nose", ellipse(760, 520, 70, 50), "grey")
    t.eyes(700, 490, 40, 12)
    t.smile(760, 545, 40, 12)
    return t


def clam():
    t = Template("clam", "Clam", CAT)
    t.region("bottom", ellipse(500, 620, 280, 160), "peach")
    t.region("top", ellipse(500, 480, 280, 160), "pink")
    t.region("hinge", ellipse(500, 550, 80, 40), "purple")
    t.region("pearl", circle(500, 580, 55), "white")
    t.region("left_ridge", band([(300, 520), (280, 620), (320, 700)], 24), "pink")
    t.region("right_ridge", band([(700, 520), (720, 620), (680, 700)], 24), "pink")
    t.eyes(500, 450, 70, 14)
    t.smile(500, 500, 45, 14)
    return t


TEMPLATES = [fish, octopus, whale, crab, seahorse, starfish, dolphin, jellyfish, shark, clam]
