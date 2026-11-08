"""Twenty more Birds & Insects sketches (11-30)."""

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

CAT = "birds_insects"


def _bird_feet(t, xs, top, bottom, colour="orange"):
    for i, x in enumerate(xs):
        foot = union(
            band([(x, top), (x, bottom)], 20, smooth=False),
            band([(x, bottom), (x - 40, bottom + 22)], 16, smooth=False),
            band([(x, bottom), (x + 40, bottom + 22)], 16, smooth=False),
        )
        t.region(f"foot_{i + 1}", foot, colour, label=f"Foot {i + 1}")


def flamingo():
    t = Template("flamingo", "Flamingo", CAT)
    t.region("water", ellipse(500, 900, 380, 60), "skyblue")
    t.region("leg", union(band([(480, 620), (480, 900)], 22, smooth=False),
                          band([(480, 720), (560, 690), (520, 640)], 20)), "pink")
    t.region("body", ellipse(450, 560, 200, 120, -10), "pink")
    t.region("wing", union(ellipse(430, 550, 130, 70, -10), circle(330, 590, 50)), "red")
    t.region("neck", band([(600, 520), (650, 380), (560, 280), (560, 200)], 60), "pink")
    t.region("head", circle(600, 180, 70), "pink")
    t.region("beak", union(poly([(650, 170), (760, 220), (700, 260), (650, 210)], 14)), "white")
    t.region("beak_tip", poly([(720, 205), (775, 230), (735, 265), (705, 245)], 10), "black", label="Beak tip")
    t.eye(600, 165, 15)
    return t


def peacock():
    t = Template("peacock", "Peacock", CAT)
    for i in range(7):
        a = -165 + i * 25
        t.region(f"feather_{i + 1}", petal((500, 640), a, 420, 160), ["green", "teal"][i % 2], label=f"Tail feather {i + 1}")
    for i in range(7):
        a = math.radians(-165 + i * 25)
        x, y = 500 + 330 * math.cos(a), 640 + 330 * math.sin(a)
        t.dot(x, y, 34, "#1E88E5")
        t.dot(x, y, 16, "#FDD835")
    _bird_feet(t, (465, 535), 780, 880)
    t.region("body", ellipse(500, 640, 110, 160), "blue")
    t.region("head", circle(500, 400, 80), "blue")
    t.region("crest", union(*[circle(470 + 30 * k, 290 - (12 if k == 1 else 0), 18) for k in range(3)]), "blue")
    t.region("beak", poly([(468, 410), (532, 410), (500, 485)], 8), "orange")
    t.eyes(500, 390, 70, 14)
    for k in range(3):
        t.line([(470 + 30 * k, 308), (490 + 5 * k, 330)], 7)
    return t


def swan():
    t = Template("swan", "Swan", CAT)
    t.region("water", ellipse(500, 820, 430, 90), "skyblue")
    t.region("body", union(ellipse(500, 680, 280, 140).intersection(halfplane_above(780)), poly([(220, 640), (160, 520), (330, 600)], 30)),
             "white")
    t.region("wing", union(ellipse(470, 660, 170, 85, -10), *[circle(340 + 60 * k, 700 - 10 * k, 40) for k in range(4)]), "white")
    t.region("neck", band([(690, 640), (740, 480), (660, 330), (640, 240)], 70), "white")
    t.region("head", circle(670, 220, 70), "white")
    t.region("beak", poly([(720, 210), (830, 250), (730, 270)], 12), "orange")
    t.region("crown", poly([(620, 160), (640, 110), (670, 150), (700, 110), (720, 160)], 6), "yellow")
    t.eye(680, 205, 14)
    for x in (200, 400, 780):
        t.arc(x, 850, 40, 200, 340, 8)
    return t


def eagle():
    t = Template("eagle", "Eagle", CAT)
    wing = poly([(400, 450), (80, 300), (120, 400), (60, 460), (140, 520), (100, 580), (420, 580)], 30)
    t.region("left_wing", wing, "brown")
    t.region("right_wing", mirror(wing), "brown")
    t.region("tail", poly([(420, 720), (500, 900), (580, 720)], 20), "white")
    t.region("body", ellipse(500, 590, 140, 190), "brown")
    _bird_feet(t, (450, 550), 740, 810, "yellow")
    t.region("head", circle(500, 360, 115), "white")
    t.region("beak", union(poly([(470, 380), (560, 380), (560, 440), (520, 470)], 14)), "yellow")
    t.eyes(500, 340, 90, 16)
    t.line([(440, 310), (480, 325)], 9, smooth=False)
    t.line([(560, 310), (520, 325)], 9, smooth=False)
    return t


def toucan():
    t = Template("toucan", "Toucan", CAT)
    t.region("branch", band([(80, 800), (500, 780), (920, 810)], 50), "brown")
    t.region("tail", rect(380, 680, 90, 200, 30), "black")
    t.region("body", ellipse(450, 560, 140, 220), "black")
    t.region("chest", ellipse(480, 470, 90, 110), "white")
    t.region("head", circle(470, 340, 110), "black")
    t.region("face", circle(500, 340, 60), "white")
    beak = union(ellipse(680, 360, 180, 70, 10))
    t.region("beak", beak.intersection(halfplane_above(360)), "orange")
    t.region("beak_bottom", beak.intersection(halfplane_below(360)), "yellow", label="Beak bottom")
    t.region("beak_tip", circle(840, 400, 40).intersection(beak), "red", label="Beak tip")
    t.region("wing", ellipse(420, 600, 80, 150, 10), "black")
    t.eye(505, 335, 18)
    t.line([(420, 790), (420, 810)], 9)
    t.line([(470, 790), (470, 810)], 9)
    return t


def hummingbird():
    t = Template("hummingbird", "Hummingbird", CAT)
    t.region("flower", union(*[petal((780, 640), a, 180, 110) for a in (-60, 0, 60, 120)]), "pink")
    t.region("flower_middle", circle(780, 640, 45), "yellow", label="Flower middle")
    t.region("stem", band([(780, 690), (800, 940)], 24), "green")
    t.region("tail", poly([(240, 560), (100, 640), (140, 700), (280, 610)], 16), "green")
    t.region("back_wing", lens((360, 470), -110, 260, 100), "skyblue", label="Back wing")
    t.region("body", ellipse(380, 520, 160, 90, -20), "green")
    t.region("belly", ellipse(390, 560, 100, 45, -20), "white")
    t.region("front_wing", lens((380, 470), -60, 280, 110), "skyblue", label="Front wing")
    t.region("head", circle(520, 420, 75), "green")
    t.region("throat", ellipse(540, 480, 45, 28, -20), "red")
    t.region("beak", band([(590, 420), (720, 560)], 16, smooth=False), "black")
    t.eye(530, 405, 14)
    return t


def woodpecker():
    t = Template("woodpecker", "Woodpecker", CAT)
    t.region("trunk", rect(620, 0, 260, 1000), "brown", label="Tree trunk")
    t.region("hole", ellipse(750, 300, 50, 70), "black")
    t.region("tail", poly([(430, 760), (400, 920), (520, 880), (520, 760)], 14), "black")
    t.region("body", ellipse(480, 600, 120, 200, 10), "black")
    t.region("chest", ellipse(420, 610, 60, 150, 10), "white")
    t.region("head", circle(470, 360, 100), "black")
    t.region("face", ellipse(440, 380, 60, 55), "white")
    t.region("crest", union(circle(440, 270, 60), circle(500, 260, 50)).difference(circle(470, 360, 100)), "red")
    t.region("beak", poly([(540, 350), (630, 370), (540, 400)], 10), "yellow")
    _bird_feet(t, (560,), 620, 640, "grey")
    t.eye(470, 345, 16)
    for y in (500, 650, 820):
        t.line([(700, y), (800, y + 20)], 9)
    return t


def pigeon():
    t = Template("pigeon", "Pigeon", CAT)
    _bird_feet(t, (440, 540), 760, 860, "pink")
    t.region("tail", poly([(250, 600), (90, 560), (100, 660), (260, 680)], 18), "grey")
    t.region("body", ellipse(460, 620, 240, 160), "grey")
    t.region("wing", union(ellipse(400, 620, 140, 80, -5), *[circle(290 + 55 * k, 680, 30) for k in range(4)]), "darkblue")
    t.region("neck", ellipse(620, 500, 100, 110), "teal")
    t.region("head", circle(650, 380, 95), "grey")
    t.region("beak", poly([(725, 368), (825, 398), (725, 428)], 10), "black")
    t.region("crumb", circle(830, 860, 34), "yellow", label="Bread crumb")
    t.eye(670, 365, 16)
    return t


def ostrich():
    t = Template("ostrich", "Ostrich", CAT)
    t.region("left_leg", band([(450, 600), (430, 880), (390, 910)], 32), "pink")
    t.region("right_leg", band([(530, 600), (560, 880), (610, 910)], 32), "pink")
    t.region("body", union(*[circle(500 + 170 * math.cos(math.radians(a)), 520 + 110 * math.sin(math.radians(a)), 70)
                             for a in range(0, 360, 40)], ellipse(500, 520, 180, 120)), "black")
    t.region("tail", union(circle(310, 450, 60), circle(290, 520, 50)), "white")
    t.region("neck", band([(620, 450), (650, 300), (630, 180)], 50), "pink")
    t.region("head", ellipse(650, 150, 70, 55), "pink")
    t.region("beak", poly([(695, 135), (800, 165), (695, 198)], 10), "orange")
    t.eye(660, 135, 15)
    t.line([(640, 100), (620, 70)], 7)
    t.line([(660, 98), (665, 65)], 7)
    return t


def stork():
    t = Template("stork", "Stork", CAT)
    t.region("baby_bundle", union(ellipse(720, 700, 120, 90), poly([(640, 640), (720, 560), (800, 640)], 10)), "pink",
             label="Bundle")
    t.region("baby_face", circle(720, 690, 45), "peach", label="Baby face")
    t.region("left_leg", band([(380, 650), (380, 920)], 22, smooth=False), "red")
    t.region("right_leg", band([(450, 650), (460, 920)], 22, smooth=False), "red")
    t.region("body", ellipse(400, 540, 180, 120, -15), "white")
    t.region("wing", ellipse(360, 550, 140, 70, -15).intersection(halfplane_below(520)), "black")
    t.region("neck", band([(520, 470), (560, 340), (540, 260)], 50), "white")
    t.region("head", circle(560, 230, 65), "white")
    t.region("beak", union(poly([(610, 220), (770, 300), (760, 330), (610, 260)], 10),
                           band([(720, 300), (720, 560)], 14, smooth=False)), "red")
    t.eye(570, 215, 14)
    t.sleepy_eye(705, 690, 20, 6)
    t.sleepy_eye(740, 690, 20, 6)
    return t


def puffin():
    t = Template("puffin", "Puffin", CAT)
    t.region("rock", ellipse(500, 900, 330, 70), "grey")
    _bird_feet(t, (440, 560), 760, 830)
    t.region("body", ellipse(500, 590, 190, 230), "black")
    t.region("belly", ellipse(500, 650, 120, 170), "white")
    t.region("head", circle(500, 330, 140), "black")
    t.region("face", ellipse(500, 340, 110, 100), "white")
    t.region("beak", union(poly([(450, 360), (560, 360), (500, 470)], 18)), "orange")
    t.region("beak_stripe", poly([(462, 385), (538, 385), (500, 448)], 10), "red", label="Beak stripe")
    t.eyes(500, 315, 100, 16)
    return t


def crow():
    t = Template("crow", "Crow", CAT)
    t.region("fence", rect(80, 780, 840, 80, 20), "brown")
    _bird_feet(t, (460, 540), 720, 780, "grey")
    t.region("tail", poly([(300, 600), (120, 680), (160, 720), (320, 690)], 16), "black")
    t.region("body", ellipse(480, 590, 210, 150), "black")
    t.region("wing", union(ellipse(430, 590, 140, 80, -10), *[circle(320 + 55 * k, 650, 30) for k in range(4)]), "darkblue")
    t.region("head", circle(640, 400, 110), "black")
    t.region("beak", poly([(730, 390), (850, 420), (730, 450)], 12), "yellow")
    t.region("shiny", circle(860, 600, 40), "yellow", label="Shiny button")
    t.eye(660, 380, 20)
    return t


def ant():
    t = Template("ant", "Ant", CAT)
    for pts in ([(440, 580), (360, 690), (320, 770)], [(470, 590), (470, 700), (450, 780)],
                [(500, 580), (580, 690), (620, 770)]):
        t.line(pts, 14)
    t.region("abdomen", ellipse(250, 560, 150, 120), "red")
    t.region("thorax", ellipse(470, 540, 90, 70), "red")
    t.region("head", circle(660, 470, 110), "red")
    t.region("leaf", lens((600, 330), -30, 300, 140), "green")
    t.eyes(680, 450, 70, 18)
    t.smile(690, 510, 50, 18)
    t.line([(630, 370), (590, 280), (540, 260)], 10)
    t.line([(700, 370), (740, 280), (790, 260)], 10)
    return t


def caterpillar():
    t = Template("caterpillar", "Caterpillar", CAT)
    t.region("leaf", lens((80, 820), -10, 860, 230), "lightgreen")
    colours = ["green", "lightgreen", "green", "lightgreen", "green"]
    for i in range(5):
        x = 200 + i * 120
        y = 650 - 60 * math.sin(i * 0.9)
        t.region(f"segment_{i + 1}", circle(x, y, 85), colours[i], label=f"Body part {i + 1}")
    t.region("head", circle(820, 470, 120), "yellow")
    t.region("left_antenna", circle(760, 300, 28), "red", label="Left antenna")
    t.region("right_antenna", circle(880, 300, 28), "red", label="Right antenna")
    t.region("left_cheek", circle(760, 510, 26), "pink")
    t.region("right_cheek", circle(880, 510, 26), "pink")
    t.line([(790, 360), (770, 320)], 10)
    t.line([(850, 360), (870, 320)], 10)
    t.eyes(820, 450, 80, 18)
    t.smile(820, 510, 50, 18)
    return t


def grasshopper():
    t = Template("grasshopper", "Grasshopper", CAT)
    t.region("back_leg", union(band([(450, 600), (300, 420), (220, 700)], 50), band([(220, 700), (190, 780)], 30)),
             "green", label="Big leg")
    t.region("body", ellipse(450, 600, 260, 90, -10), "lightgreen")
    t.region("wing", lens((300, 580), -10, 340, 90), "green")
    t.region("head", ellipse(720, 520, 100, 110), "lightgreen")
    t.region("front_leg", band([(600, 640), (640, 780), (600, 830)], 26), "green")
    t.region("middle_leg", band([(500, 660), (520, 800), (480, 840)], 26), "green")
    t.eye(745, 490, 22)
    t.smile(760, 560, 40, 14)
    t.line([(720, 420), (700, 280), (640, 220)], 9)
    t.line([(760, 420), (800, 280), (860, 230)], 9)
    return t


def spider():
    t = Template("spider", "Spider", CAT)
    t.line([(500, 0), (500, 330)], 9, smooth=False)
    for side in (-1, 1):
        for k in range(4):
            y = 520 + k * 60
            t.line([(500 + side * 120, y), (500 + side * 260, y - 110 + k * 30), (500 + side * 340, y + 60 + k * 30)], 16)
    t.region("body", ellipse(500, 580, 170, 160), "purple")
    t.region("head", circle(500, 410, 110), "purple")
    t.region("left_eye", circle(455, 400, 40), "white", label="Left eye")
    t.region("right_eye", circle(545, 400, 40), "white", label="Right eye")
    t.region("spot", star(500, 600, 70), "yellow")
    t.region("left_cheek", circle(420, 460, 24).union(circle(420, 460, 26)), "pink")
    t.region("right_cheek", circle(580, 460, 26), "pink")
    t.dot(460, 405, 18)
    t.dot(550, 405, 18)
    t.smile(500, 460, 50, 18)
    return t


def firefly():
    t = Template("firefly", "Firefly", CAT)
    t.region("moon", circle(820, 180, 100).difference(circle(860, 150, 90)), "yellow")
    t.region("glow", circle(450, 680, 190), "yellow", label="Glow")
    t.region("light", ellipse(450, 650, 120, 140), "orange", label="Tail light")
    t.region("left_wing", ellipse(380, 400, 70, 140, -30), "skyblue")
    t.region("right_wing", ellipse(560, 400, 70, 140, 30), "skyblue")
    t.region("body", ellipse(470, 500, 110, 150), "black")
    t.region("head", circle(470, 330, 90), "black")
    t.dot(440, 320, 22, "#FFFFFF")
    t.dot(500, 320, 22, "#FFFFFF")
    t.dot(444, 324, 10)
    t.dot(504, 324, 10)
    for i, (x, y) in enumerate([(160, 300), (220, 820), (760, 760)]):
        t.region(f"sparkle_{i + 1}", star(x, y, 50), "yellow", label=f"Sparkle {i + 1}")
    t.line([(440, 245), (400, 170)], 9)
    t.line([(500, 245), (540, 170)], 9)
    return t


def beetle():
    t = Template("beetle", "Beetle", CAT)
    for side in (-1, 1):
        for k in range(3):
            y = 470 + k * 140
            t.line([(500 + side * 180, y), (500 + side * 300, y - 20), (500 + side * 340, y + 40)], 16)
    shell = ellipse(500, 590, 210, 280)
    t.region("left_shell", shell.intersection(rect(0, 0, 500, 1000)), "green", label="Left shell")
    t.region("right_shell", shell.intersection(rect(500, 0, 500, 1000)), "teal", label="Right shell")
    t.region("head", ellipse(500, 300, 120, 80).intersection(halfplane_above(330)), "black")
    for i, (x, y) in enumerate([(420, 520), (420, 680), (580, 520), (580, 680)]):
        t.region(f"dot_{i + 1}", circle(x, y, 40), "yellow", label=f"Spot {i + 1}")
    t.line([(450, 240), (420, 160)], 10)
    t.line([(550, 240), (580, 160)], 10)
    t.dot(460, 290, 14, "#FFFFFF")
    t.dot(540, 290, 14, "#FFFFFF")
    return t


def moth():
    t = Template("moth", "Moth", CAT)
    wing = blob([(490, 470), (300, 280), (130, 330), (140, 520), (300, 560)])
    lower = blob([(490, 520), (330, 600), (240, 760), (380, 800), (490, 640)])
    t.region("left_wing", wing, "peach")
    t.region("right_wing", mirror(wing), "peach")
    t.region("left_lower_wing", lower, "brown", label="Left lower wing")
    t.region("right_lower_wing", mirror(lower), "brown", label="Right lower wing")
    t.region("left_spot", circle(270, 430, 55), "orange", label="Left spot")
    t.region("right_spot", circle(730, 430, 55), "orange", label="Right spot")
    t.region("body", ellipse(500, 560, 50, 200), "brown")
    t.region("head", circle(500, 360, 60), "brown")
    t.dot(480, 355, 10)
    t.dot(520, 355, 10)
    t.line([(480, 310), (420, 220), (360, 210)], 10)
    t.line([(520, 310), (580, 220), (640, 210)], 10)
    return t


def worm():
    t = Template("worm", "Worm", CAT)
    t.region("soil", rect(0, 700, 1000, 300), "brown")
    t.region("apple", union(circle(300, 450, 220), lens((300, 240), -70, 90, 50)), "red")
    t.region("leaf", lens((310, 240), -20, 140, 70), "green")
    t.region("hole", circle(420, 450, 80), "peach", label="Bite hole")
    t.region("worm", band([(420, 450), (520, 380), (640, 420), (700, 360)], 70), "pink")
    t.region("hat", union(rect(650, 240, 100, 70, 10), ellipse(700, 310, 80, 20)), "blue")
    t.region("stone_1", ellipse(150, 850, 70, 40), "grey", label="Stone 1")
    t.region("stone_2", ellipse(800, 880, 90, 45), "grey", label="Stone 2")
    t.eyes(705, 345, 40, 11)
    t.smile(720, 385, 30, 12)
    return t


TEMPLATES = [
    flamingo,
    peacock,
    swan,
    eagle,
    toucan,
    hummingbird,
    woodpecker,
    pigeon,
    ostrich,
    stork,
    puffin,
    crow,
    ant,
    caterpillar,
    grasshopper,
    spider,
    firefly,
    beetle,
    moth,
    worm,
]
