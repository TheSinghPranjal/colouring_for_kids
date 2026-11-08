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
    tail = union(lens((185, 560), 215, 150, 66), lens((185, 560), 145, 150, 66))
    t.region("tail", tail, "blue")
    t.region("fin", poly([(450, 420), (515, 265), (590, 400)], 22), "blue")
    body = blob([(170, 560), (260, 480), (420, 405), (600, 385), (740, 412), (815, 455), (900, 478), (905, 508),
                 (820, 522), (740, 562), (600, 602), (420, 605), (260, 592)])
    t.region("body", body, "skyblue")
    t.region("belly", ellipse(590, 590, 250, 48, -6).intersection(body.buffer(-10)), "white")
    t.region("flipper", lens((560, 575), 125, 150, 62), "blue")
    t.region("bubble_1", circle(860, 330, 36), "white", label="Bubble 1")
    t.region("bubble_2", circle(920, 240, 28), "white", label="Bubble 2")
    t.eye(760, 455, 17)
    t.line([(812, 505), (850, 512), (890, 498)], 9)
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
    tail = union(poly([(225, 500), (105, 300), (215, 335), (305, 470)], 22),
                 poly([(225, 545), (125, 715), (220, 685), (305, 570)], 22))
    t.region("tail", tail, "grey")
    t.region("fin", poly([(440, 420), (520, 235), (610, 410)], 22), "grey")
    body = blob([(200, 520), (320, 445), (520, 400), (720, 420), (850, 468), (920, 522), (850, 572), (720, 612),
                 (520, 632), (320, 600)])
    t.region("body", body, "grey")
    t.region("belly", ellipse(620, 585, 280, 62).intersection(body.buffer(-10)), "white")
    t.region("side_fin", poly([(520, 600), (450, 735), (640, 615)], 24), "grey")
    t.region("bubble", circle(905, 330, 36), "skyblue")
    t.eye(790, 478, 17)
    t.line([(760, 548), (815, 568), (875, 545)], 10)
    for x in (680, 712, 744):
        t.line([(x, 470), (x - 10, 530)], 9)
    return t


def clam():
    from lib import arc_pts, halfplane_below
    t = Template("clam", "Clam", CAT)
    fan = poly([(500, 620)] + arc_pts(500, 620, 320, 180, 360), 0)
    scallops = [circle(500 + 315 * math.cos(math.radians(a)), 620 + 315 * math.sin(math.radians(a)), 42)
                for a in range(190, 360, 20)]
    t.region("top_shell", union(fan, *scallops).difference(halfplane_below(640)), "pink")
    t.region("inside", ellipse(500, 565, 255, 72), "peach")
    t.region("pearl", circle(500, 520, 72), "white")
    bowl = ellipse(500, 600, 315, 185).intersection(halfplane_below(600))
    t.region("bottom_shell", bowl, "pink")
    t.region("left_cheek", circle(355, 708, 32), "pink")
    t.region("right_cheek", circle(645, 708, 32), "pink")
    t.eyes(500, 668, 150, 21)
    t.smile(500, 705, 60, 22)
    for a in (215, 250, 290, 325):
        r = math.radians(a)
        t.line([(500 + 235 * math.cos(r), 620 + 235 * math.sin(r)), (500 + 300 * math.cos(r), 620 + 300 * math.sin(r))],
               9, smooth=False)
    t.dot(478, 498, 14, "#FFFFFF")
    return t


TEMPLATES = [fish, octopus, whale, crab, seahorse, starfish, dolphin, jellyfish, shark, clam]
