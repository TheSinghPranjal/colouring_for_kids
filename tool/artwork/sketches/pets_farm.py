import math

from lib import Template, band, circle, ellipse, lens, mirror, petal, poly, rect, union

CAT = "pets_farm"


def cat():
    t = Template("cat", "Cat", CAT)
    t.region("tail", band([(640, 840), (770, 830), (850, 740), (830, 630), (770, 590)], 56), "orange")
    t.region("body", ellipse(500, 710, 175, 200), "orange")
    t.region("belly", ellipse(500, 720, 80, 120), "peach")
    t.region("left_leg", rect(392, 760, 92, 165, 44), "orange")
    t.region("right_leg", rect(516, 760, 92, 165, 44), "orange")
    t.region("left_ear", poly([(335, 350), (355, 160), (475, 270)], 18), "orange")
    t.region("right_ear", mirror(poly([(335, 350), (355, 160), (475, 270)], 18)), "orange")
    t.region("head", ellipse(500, 400, 190, 160), "orange")
    t.region("muzzle", ellipse(500, 465, 82, 56), "peach", label="Face")
    t.eyes(500, 385, 130, 22)
    t.shape_detail(poly([(478, 440), (522, 440), (500, 465)], 6))
    t.line([(500, 462), (500, 478)], 9, smooth=False)
    t.line([(462, 480), (480, 495), (500, 478), (520, 495), (538, 480)], 9)
    for dy in (-12, 12):
        t.line([(400, 455 + dy), (300, 445 + dy * 2.2)], 8, smooth=False)
        t.line([(600, 455 + dy), (700, 445 + dy * 2.2)], 8, smooth=False)
    for x in (420, 450, 550, 580):
        t.line([(x, 900), (x, 922)], 8, smooth=False)
    return t


def dog():
    t = Template("dog", "Dog", CAT)
    t.region("tail", band([(640, 820), (760, 780), (830, 670)], 50), "brown")
    t.region("body", ellipse(500, 715, 180, 190), "brown")
    t.region("left_leg", rect(390, 770, 96, 155, 44), "brown")
    t.region("right_leg", rect(514, 770, 96, 155, 44), "brown")
    t.region("collar", band([(380, 560), (500, 590), (620, 560)], 44), "red")
    t.region("head", circle(500, 390, 170), "peach")
    t.region("left_ear", ellipse(335, 420, 64, 128, 18), "brown")
    t.region("right_ear", ellipse(665, 420, 64, 128, -18), "brown")
    t.region("muzzle", ellipse(500, 465, 96, 68), "white")
    t.region("tag", circle(500, 625, 30), "yellow")
    t.eyes(500, 370, 110, 21)
    t.shape_detail(ellipse(500, 432, 32, 22))
    t.line([(500, 452), (500, 480)], 9, smooth=False)
    t.line([(455, 485), (478, 500), (500, 482), (522, 500), (545, 485)], 9)
    for x in (418, 450, 550, 582):
        t.line([(x, 902), (x, 922)], 8, smooth=False)
    return t


def cow():
    t = Template("cow", "Cow", CAT)
    tail = union(band([(740, 470), (800, 560), (810, 680)], 24), ellipse(812, 715, 30, 42))
    t.region("tail", tail, "white")
    legs = [(290, 640), (390, 650), (580, 650), (680, 640)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 78, 230, 34), "white", label=f"Leg {i + 1}")
    body = rect(240, 400, 520, 300, 120)
    t.region("body", body, "white")
    t.region(
        "patch_1",
        ellipse(420, 480, 90, 62, -15).union(circle(470, 520, 50)).intersection(body.buffer(-20)),
        "black",
        label="Patch 1",
    )
    t.region(
        "patch_2",
        ellipse(640, 600, 80, 58, 20).union(circle(600, 640, 45)).intersection(body.buffer(-20)),
        "black",
        label="Patch 2",
    )
    t.region("patch_3", circle(690, 450, 48).intersection(body.buffer(-20)), "black", label="Patch 3")
    t.region("left_ear", ellipse(115, 315, 66, 30, -20), "white")
    t.region("right_ear", ellipse(345, 315, 66, 30, 20), "white")
    t.region("horns", union(band([(180, 270), (165, 210)], 30), band([(280, 270), (295, 210)], 30)), "yellow")
    t.region("head", ellipse(230, 390, 125, 140), "white")
    t.region("muzzle", ellipse(230, 490, 100, 62), "pink")
    t.eyes(230, 370, 90, 19)
    t.dot(195, 490, 11)
    t.dot(265, 490, 11)
    t.smile(230, 520, 40, 12, 9)
    for x, y in legs:
        t.line([(x + 8, y + 195), (x + 70, y + 195)], 9, smooth=False)
    return t


def pig():
    t = Template("pig", "Pig", CAT)
    spiral = [
        (820, 530 + 0),
        (870, 500),
        (900, 540),
        (880, 585),
        (840, 570),
        (850, 535),
    ]
    t.region("tail", band(spiral, 24), "pink")
    legs = [(330, 680), (430, 700), (600, 700), (700, 680)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 80, 170, 34), "pink", label=f"Leg {i + 1}")
    t.region("body", ellipse(560, 560, 290, 210), "pink")
    t.region("head", circle(290, 470, 160), "pink")
    t.region("left_ear", poly([(170, 380), (175, 255), (285, 330)], 16), "pink")
    t.region("right_ear", poly([(310, 325), (400, 250), (410, 370)], 16), "pink")
    t.region("snout", ellipse(200, 515, 72, 56), "peach")
    t.eye(250, 430, 20)
    t.eye(345, 430, 20)
    t.dot(178, 515, 13)
    t.dot(222, 515, 13)
    t.smile(300, 545, 60, 22)
    for x, y in legs:
        t.line([(x + 40, y + 140), (x + 40, y + 170)], 9, smooth=False)
    return t


def chicken():
    t = Template("chicken", "Chicken", CAT)
    for i, x in enumerate((450, 570)):
        foot = union(
            band([(x, 740), (x - 6, 870)], 24, smooth=False),
            band([(x - 6, 870), (x - 60, 895)], 20, smooth=False),
            band([(x - 6, 870), (x - 2, 915)], 20, smooth=False),
            band([(x - 6, 870), (x + 46, 893)], 20, smooth=False),
        )
        t.region(["left_foot", "right_foot"][i], foot, "orange")
    tail = union(*[petal((690, 560), a, 200, 92) for a in (-65, -35, -5)])
    t.region("tail", tail, "red")
    t.region("body", ellipse(520, 600, 230, 175), "white")
    wing = union(ellipse(570, 600, 125, 82, 12), *[circle(500 + i * 55, 668 - i * 6, 34) for i in range(4)])
    t.region("wing", wing, "yellow")
    t.region("comb", union(circle(282, 285, 44), circle(338, 268, 48), circle(392, 288, 42)), "red")
    t.region("head", circle(330, 405, 120), "white")
    t.region("beak", poly([(218, 385), (140, 418), (218, 450)], 10), "orange")
    t.region("wattle", ellipse(240, 488, 30, 46), "red")
    t.eye(320, 385, 20)
    return t


def horse():
    t = Template("horse", "Horse", CAT)
    t.region("tail", band([(215, 500), (140, 560), (125, 680), (165, 770)], 64), "black")
    legs = [(232, 640), (330, 650), (520, 650), (606, 640)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 66, 240, 30), "brown", label=f"Leg {i + 1}")
        t.region(f"hoof_{i + 1}", rect(x - 4, 838, 74, 52, 16), "grey", label=f"Hoof {i + 1}")
    t.region("body", rect(195, 440, 485, 240, 115), "brown")
    mane = union(*[circle(662 - 92 * k / 5, 228 + 290 * k / 5, 44) for k in range(6)])
    t.region("mane", mane, "black")
    t.region("neck", poly([(565, 530), (660, 245), (775, 270), (700, 565)], 40), "brown")
    t.region("ear", poly([(700, 252), (692, 150), (772, 228)], 14), "brown")
    t.region("head", ellipse(800, 322, 128, 74, 40), "brown")
    t.region("muzzle", ellipse(872, 388, 66, 56, 40), "peach", label="Nose")
    t.region("blaze", ellipse(770, 290, 22, 52, 40), "white", label="Face stripe")
    t.eye(752, 318, 17)
    t.dot(893, 392, 9)
    t.line([(842, 432), (868, 444), (892, 432)], 9)
    return t


def sheep():
    t = Template("sheep", "Sheep", CAT)
    legs = [(300, 620), (390, 640), (540, 640), (625, 620)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 62, 250, 28), "black", label=f"Leg {i + 1}")
    puffs = [
        circle(460 + 255 * math.cos(math.radians(a)), 520 + 160 * math.sin(math.radians(a)), 72)
        for a in range(0, 360, 30)
    ]
    t.region("wool", union(ellipse(460, 520, 255, 160), *puffs), "white")
    t.region("left_ear", ellipse(650, 455, 66, 28, -25), "peach")
    t.region("right_ear", ellipse(860, 455, 66, 28, 25), "peach")
    t.region("head", ellipse(755, 500, 92, 116), "peach", label="Face")
    t.region("tuft", union(circle(715, 392, 46), circle(770, 378, 52), circle(745, 345, 44), circle(805, 405, 36)), "white")
    t.eyes(755, 490, 64, 15)
    t.dot(755, 552, 12)
    t.smile(755, 570, 46, 16)
    return t


def rabbit():
    t = Template("rabbit", "Rabbit", CAT)
    t.region("left_ear", ellipse(420, 220, 50, 160, -10), "white")
    t.region("right_ear", ellipse(580, 220, 50, 160, 10), "white")
    t.region("left_inner", ellipse(420, 220, 22, 100, -10), "pink")
    t.region("right_inner", ellipse(580, 220, 22, 100, 10), "pink")
    t.region("body", ellipse(500, 680, 160, 180), "white")
    t.region("head", ellipse(500, 420, 140, 130), "white")
    t.region("belly", ellipse(500, 700, 80, 100), "peach")
    t.region("tail", circle(340, 720, 45), "white")
    t.eyes(500, 400, 80, 16)
    t.smile(500, 450, 40, 14)
    return t


def goat():
    t = Template("goat", "Goat", CAT)
    t.region("tail", lens((232, 492), -125, 100, 52), "white")
    legs = [(250, 630), (330, 640), (515, 640), (590, 630)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 58, 235, 26), "white", label=f"Leg {i + 1}")
    t.region("body", rect(215, 450, 450, 220, 100), "white")
    t.region("spot", ellipse(400, 540, 90, 60, -10).intersection(rect(215, 450, 450, 220, 100).buffer(-22)), "brown")
    t.region("horns", band([(705, 268), (668, 190), (610, 160), (566, 186)], 36), "peach")
    t.region("neck", poly([(555, 520), (630, 325), (730, 340), (668, 560)], 36), "white")
    t.region("beard", poly([(758, 392), (824, 388), (792, 548)], 14), "white")
    t.region("ear", ellipse(650, 330, 62, 26, 25), "white")
    t.region("head", ellipse(748, 332, 108, 72, 32), "white")
    t.region("muzzle", ellipse(822, 380, 56, 46, 32), "pink", label="Nose")
    t.eye(735, 315, 16)
    t.dot(845, 382, 8)
    t.line([(800, 414), (820, 424), (842, 414)], 9)
    for x, y in legs:
        t.line([(x + 6, y + 205), (x + 52, y + 205)], 9, smooth=False)
    return t


def mouse():
    t = Template("mouse", "Mouse", CAT)
    t.region("tail", band([(280, 620), (160, 560), (120, 480), (180, 420)], 28), "pink")
    t.region("body", ellipse(480, 620, 180, 150), "grey")
    t.region("head", ellipse(660, 520, 120, 100), "grey")
    t.region("left_ear", circle(600, 420, 55), "grey")
    t.region("right_ear", circle(700, 400, 55), "grey")
    t.region("left_inner", circle(600, 420, 28), "pink")
    t.region("right_inner", circle(700, 400, 28), "pink")
    t.region("nose", circle(760, 530, 35), "pink")
    t.eyes(680, 500, 50, 12)
    t.smile(700, 545, 30, 12)
    return t


TEMPLATES = [cat, dog, cow, pig, chicken, horse, sheep, rabbit, goat, mouse]
