"""Twenty more Pets & Farm sketches (11-30)."""

import math

from lib import (
    Template,
    band,
    blob,
    circle,
    ellipse,
    halfplane_above,
    halfplane_below,
    lens,
    mirror,
    petal,
    poly,
    rect,
    star,
    union,
)

CAT = "pets_farm"


def _side_animal(t, colour, *, body=(195, 440, 485, 240, 115), legs=None, leg_w=66, leg_h=240, neck=True,
                 head=(800, 322, 128, 74, 40), muzzle=(872, 388, 66, 56, 40), muzzle_colour="peach"):
    """Four-legged animal seen from the side facing right (horse-like)."""
    legs = legs or [(232, 640), (330, 650), (520, 650), (606, 640)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, leg_w, leg_h, leg_w * 0.45), colour, label=f"Leg {i + 1}")
    t.region("body", rect(*body), colour)
    if neck:
        t.region("neck", poly([(565, 530), (660, 245), (775, 270), (700, 565)], 40), colour)
    return legs


def hamster():
    t = Template("hamster", "Hamster", CAT)
    t.region("left_ear", circle(340, 300, 75), "orange")
    t.region("right_ear", circle(660, 300, 75), "orange")
    t.region("left_inner", circle(340, 300, 40), "pink", label="Left inner ear")
    t.region("right_inner", circle(660, 300, 40), "pink", label="Right inner ear")
    t.region("body", ellipse(500, 560, 290, 300), "orange")
    t.region("tummy", ellipse(500, 650, 180, 200), "white")
    t.region("seed", ellipse(500, 690, 70, 100), "yellow", label="Sunflower seed")
    t.region("left_paw", ellipse(420, 650, 50, 38, -30), "peach")
    t.region("right_paw", ellipse(580, 650, 50, 38, 30), "peach")
    t.region("left_cheek", circle(350, 500, 50), "pink")
    t.region("right_cheek", circle(650, 500, 50), "pink")
    t.region("left_foot", ellipse(400, 860, 70, 36), "peach")
    t.region("right_foot", ellipse(600, 860, 70, 36), "peach")
    t.eyes(500, 430, 170, 22)
    t.shape_detail(ellipse(500, 480, 20, 14))
    t.smile(500, 505, 50, 18)
    return t


def guinea_pig():
    t = Template("guinea_pig", "Guinea Pig", CAT)
    t.region("body", ellipse(470, 580, 330, 210), "brown")
    t.region("patch", ellipse(330, 520, 150, 130).intersection(ellipse(470, 580, 330, 210).buffer(-15)), "white")
    t.region("head_patch", ellipse(700, 500, 130, 130), "orange", label="Face")
    t.region("ear", ellipse(640, 380, 60, 38, -25), "pink")
    t.region("nose_patch", ellipse(800, 560, 80, 60), "white", label="Nose")
    for i, x in enumerate((300, 420, 560, 680)):
        t.region(f"foot_{i + 1}", ellipse(x, 785, 50, 30), "peach", label=f"Foot {i + 1}")
    t.eye(720, 480, 20)
    t.dot(850, 545, 14)
    t.smile(830, 590, 40, 14)
    return t


def fish_bowl():
    t = Template("fish_bowl", "Fish Bowl", CAT)
    bowl = circle(500, 540, 340).intersection(halfplane_above(860)).intersection(halfplane_below(220))
    t.region("table", rect(120, 840, 760, 90, 30), "brown")
    t.region("bowl", bowl, "skyblue")
    t.region("rim", rect(260, 190, 480, 60, 30), "white")
    t.region("gravel", ellipse(500, 820, 260, 60).intersection(bowl), "yellow")
    t.region("weed", union(band([(330, 820), (300, 700), (340, 600)], 34), band([(380, 820), (410, 680)], 30)), "green")
    t.region("fish_tail", poly([(560, 520), (680, 440), (680, 600)], 18), "orange", label="Tail")
    t.region("fish", ellipse(480, 520, 120, 85), "orange")
    t.region("fin", lens((480, 470), -100, 90, 50), "red")
    t.region("bubble_1", circle(420, 360, 30), "white", label="Bubble 1")
    t.region("bubble_2", circle(470, 300, 24), "white", label="Bubble 2")
    t.eye(420, 505, 16)
    t.smile(420, 545, 30, 12)
    return t


def donkey():
    t = Template("donkey", "Donkey", CAT)
    t.region("tail", union(band([(215, 500), (165, 570), (160, 660)], 26), ellipse(160, 695, 30, 46)), "black")
    _side_animal(t, "grey")
    t.region("left_ear", lens((700, 255), -110, 190, 64), "grey", label="Back ear")
    t.region("right_ear", lens((735, 262), -75, 190, 64), "grey", label="Front ear")
    t.region("mane", band([(700, 215), (662, 250), (612, 400), (575, 515)], 46), "black")
    t.region("head", ellipse(800, 322, 128, 74, 40), "grey")
    t.region("muzzle", ellipse(872, 388, 66, 56, 40), "white", label="Nose")
    t.region("belly", ellipse(440, 640, 180, 50).intersection(rect(195, 440, 485, 240, 115).buffer(-12)), "white")
    t.eye(752, 318, 17)
    t.dot(893, 392, 9)
    t.line([(842, 432), (868, 444), (892, 432)], 9)
    return t


def llama():
    t = Template("llama", "Llama", CAT)
    legs = [(300, 640), (380, 650), (560, 650), (640, 640)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 60, 250, 26), "white", label=f"Leg {i + 1}")
    body = union(ellipse(480, 580, 230, 120), *[circle(280 + 60 * k, 470, 45) for k in range(8)])
    t.region("body", body, "white")
    t.region("blanket", rect(380, 470, 200, 200, 20).intersection(ellipse(480, 580, 230, 120)), "red")
    t.region("neck", rect(610, 230, 110, 400, 50), "white")
    t.region("left_ear", lens((640, 160), -100, 110, 46), "white", label="Back ear")
    t.region("right_ear", lens((700, 160), -70, 110, 46), "white", label="Front ear")
    t.region("head", ellipse(700, 210, 110, 75), "white")
    t.region("muzzle", ellipse(775, 240, 55, 45), "peach", label="Nose")
    t.region("tassel", union(circle(470, 690, 26), circle(530, 690, 26)), "yellow")
    t.eye(700, 190, 16)
    t.smile(785, 268, 30, 10)
    return t


def rooster():
    t = Template("rooster", "Rooster", CAT)
    for i, x in enumerate((440, 560)):
        foot = union(band([(x, 730), (x - 4, 860)], 24, smooth=False), band([(x - 4, 860), (x - 50, 890)], 20, smooth=False),
                     band([(x - 4, 860), (x + 40, 890)], 20, smooth=False))
        t.region(["left_foot", "right_foot"][i], foot, "orange")
    feathers = [("tail_1", -80, "green"), ("tail_2", -50, "blue"), ("tail_3", -20, "red"), ("tail_4", 10, "orange")]
    for rid, a, c in feathers:
        t.region(rid, petal((640, 560), a, 280, 100), c, label=f"Tail feather {rid[-1]}")
    t.region("body", ellipse(500, 600, 200, 160), "orange")
    t.region("wing", union(ellipse(530, 610, 110, 70, 10), *[circle(460 + i * 50, 670, 30) for i in range(4)]), "brown")
    t.region("comb", union(circle(320, 230, 40), circle(370, 210, 46), circle(420, 230, 40)), "red")
    t.region("head", circle(370, 340, 110), "orange")
    t.region("beak", poly([(270, 330), (190, 360), (270, 390)], 10), "yellow")
    t.region("wattle", ellipse(285, 425, 28, 46), "red")
    t.eye(365, 320, 18)
    return t


def chick():
    t = Template("chick", "Chick", CAT)
    t.region("shell_bottom", poly([(240, 640), (300, 590), (360, 650), (430, 590), (500, 650), (570, 590),
                                   (640, 650), (700, 590), (760, 640), (720, 860), (280, 860)], 20), "white",
             label="Egg shell")
    t.region("body", circle(500, 520, 230), "yellow")
    t.region("shell_top", poly([(330, 290), (380, 240), (430, 290), (500, 230), (570, 290), (620, 240), (670, 290),
                                (640, 200), (500, 150), (360, 200)], 16), "white", label="Shell hat")
    t.region("shell_bottom_front", poly([(220, 700), (290, 650), (360, 710), (430, 650), (500, 710), (570, 650),
                                         (640, 710), (710, 650), (780, 700), (730, 880), (270, 880)], 20), "white",
             label="Egg shell front")
    t.region("left_wing", ellipse(285, 560, 50, 90, 20), "yellow")
    t.region("right_wing", ellipse(715, 560, 50, 90, -20), "yellow")
    t.region("beak", poly([(460, 500), (540, 500), (500, 560)], 10), "orange")
    t.region("left_cheek", circle(380, 520, 32), "pink")
    t.region("right_cheek", circle(620, 520, 32), "pink")
    t.eyes(500, 440, 140, 22)
    return t


def turkey():
    t = Template("turkey", "Turkey", CAT)
    colours = ["red", "orange", "yellow", "green", "blue", "purple", "red"]
    for i in range(7):
        a = -170 + i * 160 / 6
        t.region(f"feather_{i + 1}", petal((500, 520), a, 360, 140), colours[i], label=f"Tail feather {i + 1}")
    t.region("body", ellipse(500, 580, 200, 210), "brown")
    t.region("left_foot", union(band([(440, 760), (430, 900)], 24), band([(430, 900), (390, 920)], 20)), "orange")
    t.region("right_foot", union(band([(560, 760), (570, 900)], 24), band([(570, 900), (610, 920)], 20)), "orange")
    t.region("head", circle(500, 400, 110), "brown")
    t.region("beak", poly([(462, 410), (538, 410), (500, 478)], 10), "yellow")
    t.region("wattle", ellipse(530, 480, 24, 42), "red")
    t.region("belly", ellipse(500, 640, 120, 120), "peach")
    t.eyes(500, 380, 80, 17)
    return t


def goose():
    t = Template("goose", "Goose", CAT)
    t.region("left_foot", poly([(400, 800), (350, 880), (450, 880)], 10), "orange")
    t.region("right_foot", poly([(520, 800), (470, 880), (570, 880)], 10), "orange")
    t.region("body", union(ellipse(470, 650, 260, 150), poly([(220, 600), (130, 500), (260, 560)], 20)), "white")
    t.region("wing", union(ellipse(450, 640, 150, 80, -5), *[circle(340 + i * 60, 700, 36) for i in range(4)]), "grey")
    t.region("neck", band([(640, 600), (680, 450), (650, 320)], 90), "white")
    t.region("head", ellipse(680, 280, 100, 80), "white")
    t.region("beak", poly([(760, 260), (880, 290), (760, 320)], 14), "orange")
    t.region("bow", union(ellipse(600, 430, 50, 30, 20), ellipse(700, 440, 50, 30, -20)), "pink")
    t.region("knot", circle(650, 440, 24), "red")
    t.eye(700, 265, 16)
    return t


def lamb():
    t = Template("lamb", "Lamb", CAT)
    for i, x in enumerate((390, 540)):
        t.region(f"leg_{i + 1}", rect(x, 720, 70, 180, 30), "black", label=f"Leg {i + 1}")
    wool = union(*[circle(500 + 230 * math.cos(math.radians(a)), 600 + 150 * math.sin(math.radians(a)), 80)
                   for a in range(0, 360, 36)], ellipse(500, 600, 230, 150))
    t.region("wool", wool, "white")
    t.region("left_ear", ellipse(340, 330, 80, 34, -25), "black")
    t.region("right_ear", ellipse(660, 330, 80, 34, 25), "black")
    t.region("face", ellipse(500, 370, 130, 150), "peach")
    t.region("tuft", union(circle(440, 230, 50), circle(500, 210, 56), circle(560, 230, 50)), "white")
    t.region("bell", circle(500, 560, 46), "yellow")
    t.eyes(500, 360, 100, 20)
    t.shape_detail(ellipse(500, 425, 22, 14))
    t.smile(500, 450, 50, 18)
    return t


def piglet():
    t = Template("piglet", "Piglet", CAT)
    t.region("body", ellipse(500, 720, 210, 170), "pink")
    t.region("left_foot", ellipse(400, 870, 70, 40), "pink")
    t.region("right_foot", ellipse(600, 870, 70, 40), "pink")
    t.region("left_ear", poly([(300, 360), (290, 180), (430, 280)], 24), "pink")
    t.region("right_ear", mirror(poly([(300, 360), (290, 180), (430, 280)], 24)), "pink")
    t.region("head", circle(500, 430, 210), "pink")
    t.region("snout", ellipse(500, 500, 100, 70), "peach")
    t.region("left_cheek", circle(360, 490, 34), "red")
    t.region("right_cheek", circle(640, 490, 34), "red")
    t.region("mud", ellipse(620, 760, 70, 50), "brown", label="Mud spot")
    t.eyes(500, 400, 150, 22)
    t.dot(470, 500, 16)
    t.dot(530, 500, 16)
    t.smile(500, 580, 70, 24)
    return t


def puppy():
    t = Template("puppy", "Puppy", CAT)
    t.region("body", ellipse(500, 740, 180, 160), "white")
    t.region("spot", circle(600, 700, 60), "brown")
    t.region("left_paw", ellipse(410, 890, 70, 40), "white")
    t.region("right_paw", ellipse(590, 890, 70, 40), "white")
    t.region("head", ellipse(500, 420, 210, 190), "white")
    t.region("eye_patch", circle(420, 400, 70), "brown")
    t.region("left_ear", ellipse(285, 450, 70, 150, 15), "brown")
    t.region("right_ear", ellipse(715, 450, 70, 150, -15), "brown")
    t.region("nose", ellipse(500, 490, 50, 34), "black")
    t.region("tongue", ellipse(500, 590, 36, 46).intersection(halfplane_below(560)), "pink")
    t.region("collar", band([(360, 600), (500, 630), (640, 600)], 40), "red")
    t.region("tag", circle(500, 665, 34), "yellow")
    t.eyes(500, 395, 150, 22)
    t.line([(440, 555), (470, 570), (500, 555), (530, 570), (560, 555)], 9)
    return t


def kitten():
    t = Template("kitten", "Kitten", CAT)
    t.region("yarn", circle(210, 800, 110), "red", label="Ball of yarn")
    t.region("tail", band([(600, 850), (720, 860), (780, 740), (740, 640)], 46), "grey")
    t.region("body", ellipse(480, 740, 160, 170), "grey")
    t.region("left_paw", ellipse(410, 890, 60, 36), "white")
    t.region("right_paw", ellipse(550, 890, 60, 36), "white")
    t.region("left_ear", poly([(310, 380), (330, 190), (440, 300)], 18), "grey")
    t.region("right_ear", poly([(520, 300), (630, 190), (650, 380)], 18), "grey")
    t.region("head", ellipse(480, 430, 190, 160), "grey")
    t.region("muzzle", ellipse(480, 495, 85, 55), "white")
    t.region("collar", band([(360, 580), (480, 605), (600, 580)], 36), "pink")
    t.eyes(480, 415, 130, 24)
    t.shape_detail(poly([(458, 470), (502, 470), (480, 492)], 6))
    t.line([(445, 505), (462, 520), (480, 505), (498, 520), (515, 505)], 9)
    for a in range(0, 360, 60):
        r = math.radians(a)
        t.line([(210 + 35 * math.cos(r), 800 + 35 * math.sin(r)), (210 + 92 * math.cos(r + 0.6), 800 + 92 * math.sin(r + 0.6))],
               8)
    return t


def pony():
    t = Template("pony", "Pony", CAT)
    t.region("tail", band([(215, 500), (130, 540), (110, 650), (160, 730)], 80), "purple")
    _side_animal(t, "white", legs=[(240, 640), (335, 650), (515, 650), (600, 640)], leg_h=220)
    mane = union(*[circle(665 - 92 * k / 5, 232 + 290 * k / 5, 52) for k in range(6)], circle(735, 225, 50))
    t.region("mane", mane, "purple")
    t.region("ear", poly([(705, 245), (700, 150), (770, 225)], 14), "white")
    t.region("head", ellipse(800, 322, 128, 74, 40), "white")
    t.region("muzzle", ellipse(872, 388, 66, 56, 40), "pink", label="Nose")
    t.region("star", star(400, 540, 60), "yellow", label="Star mark")
    t.eye(752, 318, 17)
    t.dot(893, 392, 9)
    t.line([(842, 432), (868, 444), (892, 432)], 9)
    return t


def calf():
    t = Template("calf", "Calf", CAT)
    legs = [(300, 640), (390, 650), (560, 650), (650, 640)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 72, 220, 32), "white", label=f"Leg {i + 1}")
    body = rect(260, 440, 480, 260, 120)
    t.region("body", body, "white")
    t.region("patch_1", ellipse(400, 520, 90, 60, -15).intersection(body.buffer(-20)), "brown", label="Patch 1")
    t.region("patch_2", ellipse(640, 620, 80, 55, 20).intersection(body.buffer(-20)), "brown", label="Patch 2")
    t.region("left_ear", ellipse(130, 340, 70, 32, -20), "white")
    t.region("right_ear", ellipse(370, 340, 70, 32, 20), "white")
    t.region("head", circle(250, 420, 140), "white")
    t.region("muzzle", ellipse(250, 510, 100, 62), "pink")
    t.region("head_spot", circle(300, 350, 45), "brown")
    t.eyes(250, 410, 100, 20)
    t.dot(215, 510, 11)
    t.dot(285, 510, 11)
    return t


def tractor():
    t = Template("tractor", "Tractor", CAT)
    t.region("exhaust", rect(620, 230, 40, 160, 16), "grey")
    t.region("smoke", union(circle(650, 180, 40), circle(700, 140, 34)), "white")
    t.region("cab", rect(240, 220, 280, 330, 30), "red")
    t.region("window", rect(285, 260, 190, 160, 20), "skyblue")
    t.region("hood", rect(500, 380, 330, 200, 40), "red")
    t.region("grill", rect(790, 410, 60, 150, 16), "grey")
    t.region("light", circle(820, 360, 30), "yellow")
    t.region("big_wheel", circle(340, 680, 190), "black", label="Big wheel")
    t.region("big_hub", circle(340, 680, 85), "yellow", label="Big wheel middle")
    t.region("small_wheel", circle(740, 730, 120), "black", label="Small wheel")
    t.region("small_hub", circle(740, 730, 52), "yellow", label="Small wheel middle")
    return t


def scarecrow():
    t = Template("scarecrow", "Scarecrow", CAT)
    t.region("pole", rect(470, 500, 60, 440, 16), "brown")
    t.region("arms", rect(120, 450, 760, 80, 30), "blue", label="Sleeves")
    t.region("left_straw", poly([(120, 450), (60, 420), (80, 490), (60, 560), (120, 530)], 10), "yellow", label="Left straw")
    t.region("right_straw", mirror(poly([(120, 450), (60, 420), (80, 490), (60, 560), (120, 530)], 10)), "yellow",
             label="Right straw")
    t.region("shirt", poly([(350, 430), (650, 430), (620, 760), (380, 760)], 30), "red")
    t.region("patch", rect(540, 560, 60, 60, 8), "yellow")
    t.region("head", circle(500, 330, 120), "peach")
    t.region("hat_brim", ellipse(500, 225, 200, 40), "brown", label="Hat brim")
    t.region("hat", rect(390, 100, 220, 140, 30).difference(halfplane_below(225)), "brown")
    t.region("hat_band", rect(390, 180, 220, 40), "orange", label="Hat band")
    t.region("crow", union(ellipse(800, 380, 70, 45), circle(860, 340, 36)), "black")
    t.region("crow_beak", poly([(880, 318), (965, 345), (880, 372)], 8), "yellow", label="Crow beak")
    t.eyes(500, 320, 80, 16)
    t.smile(500, 370, 70, 24)
    return t


def dog_house():
    t = Template("dog_house", "Dog House", CAT)
    t.region("house", poly([(220, 470), (500, 260), (780, 470), (780, 860), (220, 860)], 20), "orange")
    t.region("roof", union(band([(150, 520), (500, 240)], 90, smooth=False), band([(500, 240), (850, 520)], 90, smooth=False)),
             "red")
    door = union(rect(370, 600, 260, 260), circle(500, 600, 130)).intersection(halfplane_above(860))
    t.region("door", door, "black")
    t.region("sign", rect(410, 400, 180, 70, 20), "white", label="Name sign")
    t.region("dog_head", circle(500, 690, 100), "brown", label="Dog")
    t.region("dog_ear_left", ellipse(410, 700, 36, 70, 15), "brown", label="Left ear")
    t.region("dog_ear_right", ellipse(590, 700, 36, 70, -15), "brown", label="Right ear")
    t.region("dog_muzzle", ellipse(500, 730, 55, 40), "peach", label="Dog nose")
    t.region("bowl", poly([(760, 820), (940, 820), (910, 890), (790, 890)], 10), "blue")
    t.eyes(500, 670, 70, 14)
    t.dot(500, 720, 14)
    return t


def hay_bale():
    t = Template("hay_bale", "Hay Bale", CAT)
    t.region("side", rect(230, 400, 560, 380, 60), "yellow", label="Hay bale")
    t.region("end", ellipse(230, 590, 120, 190), "orange", label="Bale end")
    t.region("band_1", rect(400, 400, 50, 380).intersection(rect(230, 400, 560, 380, 60)), "red", label="Strap 1")
    t.region("band_2", rect(600, 400, 50, 380).intersection(rect(230, 400, 560, 380, 60)), "red", label="Strap 2")
    t.region("mouse_body", ellipse(700, 360, 70, 45), "grey", label="Mouse")
    t.region("mouse_ear", circle(740, 310, 28), "pink", label="Mouse ear")
    t.region("sun", circle(160, 170, 80), "yellow")
    for r in (40, 80, 120, 160):
        t.arc(230, 590, r * 0.6, 0, 360, 8, ry=r)
    t.dot(760, 350, 7)
    t.line([(630, 370), (580, 400), (560, 380)], 8)
    return t


def hen_house():
    t = Template("hen_house", "Hen House", CAT)
    t.region("ramp", poly([(560, 760), (880, 900), (880, 940), (540, 800)], 8), "brown")
    t.region("house", rect(180, 420, 520, 380, 20), "red")
    t.region("roof", poly([(130, 440), (440, 180), (750, 440)], 24), "brown")
    t.region("door", rect(470, 600, 150, 200, 60).intersection(halfplane_above(800)), "black")
    t.region("window", circle(330, 560, 70), "yellow")
    t.region("hen", union(ellipse(330, 590, 50, 40), circle(330, 540, 34)), "white", label="Hen")
    t.region("comb", union(circle(318, 498, 24), circle(345, 494, 24)), "red")
    t.region("egg_1", ellipse(780, 860, 40, 52), "white", label="Egg 1")
    t.region("egg_2", ellipse(870, 830, 40, 52), "peach", label="Egg 2")
    t.region("ground", rect(60, 800, 600, 70, 30), "lightgreen", label="Grass")
    t.dot(345, 535, 7)
    return t


TEMPLATES = [
    hamster,
    guinea_pig,
    fish_bowl,
    donkey,
    llama,
    rooster,
    chick,
    turkey,
    goose,
    lamb,
    piglet,
    puppy,
    kitten,
    pony,
    calf,
    tractor,
    scarecrow,
    dog_house,
    hay_bale,
    hen_house,
]
