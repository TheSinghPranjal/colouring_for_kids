"""Twenty more Toys & Imagination sketches (11-30)."""

import math

from lib import (
    Template,
    annulus,
    arc_pts,
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
    teardrop,
    union,
)

CAT = "toys_imagination"


def spinning_top():
    t = Template("spinning_top", "Spinning Top", CAT)
    t.region("handle", rect(470, 120, 60, 160, 20), "red")
    body = union(ellipse(500, 400, 300, 130), poly([(220, 420), (780, 420), (510, 860), (490, 860)], 30))
    t.region("body", body, "yellow")
    t.region("band_1", band([(180, 380), (820, 380)], 60, smooth=False).intersection(body), "red", label="Stripe 1")
    t.region("band_2", band([(260, 520), (740, 520)], 60, smooth=False).intersection(body), "blue", label="Stripe 2")
    t.region("band_3", band([(360, 650), (640, 650)], 50, smooth=False).intersection(body), "green", label="Stripe 3")
    t.region("tip", poly([(470, 820), (530, 820), (500, 900)], 10), "grey")
    t.line([(170, 760), (260, 800)], 9)
    t.line([(830, 760), (740, 800)], 9)
    return t


def rubber_duck():
    t = Template("rubber_duck", "Rubber Duck", CAT)
    t.region("water", ellipse(500, 860, 450, 80), "skyblue")
    t.region("body", union(ellipse(520, 640, 300, 190), poly([(800, 560), (900, 460), (860, 640)], 30)), "yellow")
    t.region("wing", ellipse(560, 650, 140, 80, -15), "orange")
    t.region("head", circle(360, 360, 160), "yellow")
    t.region("beak", union(ellipse(200, 400, 90, 40)), "orange")
    t.region("cheek", circle(400, 420, 34), "pink")
    t.region("bubble_1", circle(760, 300, 50), "white", label="Bubble 1")
    t.region("bubble_2", circle(860, 220, 34), "white", label="Bubble 2")
    t.eye(340, 330, 24)
    return t


def toy_train():
    t = Template("toy_train", "Toy Train", CAT)
    t.region("track", rect(40, 830, 920, 40, 16), "brown")
    t.region("chimney", rect(170, 300, 80, 140, 16), "red")
    t.region("smoke", union(circle(210, 230, 50), circle(280, 180, 40)), "white")
    t.region("engine", rect(100, 430, 300, 300, 30), "blue")
    t.region("cab_roof", rect(250, 300, 200, 50, 20), "red", label="Cab roof")
    t.region("cab", rect(270, 340, 160, 200, 16), "yellow")
    t.region("wagon", rect(500, 480, 400, 250, 30), "green")
    t.region("blocks", union(rect(540, 400, 100, 90, 10), rect(660, 380, 100, 110, 10), rect(780, 410, 90, 80, 10)), "orange",
             label="Toy blocks")
    for i, x in enumerate((180, 340, 600, 800)):
        t.region(f"wheel_{i + 1}", circle(x, 780, 60), "red", label=f"Wheel {i + 1}")
    t.region("hook", rect(400, 640, 100, 30, 10), "grey")
    return t


def rocking_horse():
    t = Template("rocking_horse", "Rocking Horse", CAT)
    rocker = band(arc_pts(500, 300, 600, 55, 125, n=30), 50, smooth=False)
    t.region("rocker", rocker, "red")
    for i, (a, b) in enumerate([((350, 620), (300, 780)), ((420, 620), (420, 800)), ((620, 620), (600, 800)), ((680, 620), (720, 780))]):
        t.region(f"leg_{i + 1}", band([a, b], 50, smooth=False), "white", label=f"Leg {i + 1}")
    t.region("tail", band([(270, 520), (180, 560), (170, 680)], 60), "brown")
    t.region("body", ellipse(500, 560, 240, 110), "white")
    t.region("saddle", ellipse(480, 470, 100, 40), "red")
    t.region("neck", poly([(620, 540), (690, 300), (800, 330), (730, 580)], 30), "white")
    t.region("mane", band([(700, 250), (650, 380), (610, 500)], 50), "brown")
    t.region("head", ellipse(800, 300, 130, 75, 30), "white")
    t.region("ear", lens((740, 240), -100, 90, 40), "white")
    t.eye(800, 285, 16)
    t.dot(890, 340, 8)
    return t


def xylophone():
    t = Template("xylophone", "Xylophone", CAT)
    t.region("frame_top", band([(120, 400), (880, 330)], 40, smooth=False), "brown", label="Top rail")
    t.region("frame_bottom", band([(120, 720), (880, 800)], 40, smooth=False), "brown", label="Bottom rail")
    colours = ["red", "orange", "yellow", "green", "blue", "purple"]
    for i in range(6):
        x = 170 + i * 120
        top = 380 - i * 10
        bot = 730 + i * 12
        t.region(f"bar_{i + 1}", rect(x, top, 90, bot - top, 20), colours[i], label=f"Bar {i + 1}")
    t.region("stick_1", union(band([(300, 150), (520, 300)], 20, smooth=False), circle(520, 300, 40)), "pink", label="Mallet 1")
    t.region("stick_2", union(band([(780, 120), (650, 280)], 20, smooth=False), circle(650, 280, 40)), "pink", label="Mallet 2")
    for i in range(6):
        x = 215 + i * 120
        t.dot(x, 420 - i * 10, 10)
        t.dot(x, 700 + i * 12, 10)
    return t


def balloons():
    t = Template("balloons", "Balloons", CAT)
    specs = [(330, 330, "red"), (520, 260, "yellow"), (690, 360, "blue"), (430, 500, "green"), (620, 540, "purple")]
    for i, (x, y, c) in enumerate(specs):
        t.line([(x, y + 150), (x + (500 - x) * 0.6, 760), (500, 900)], 7)
    for i, (x, y, c) in enumerate(specs):
        t.region(f"balloon_{i + 1}", union(ellipse(x, y, 110, 140), poly([(x - 20, y + 150), (x + 20, y + 150), (x, y + 125)], 4)), c,
                 label=f"Balloon {i + 1}")
        t.dot(x - 45, y - 55, 16, "#FFFFFF")
    t.region("bow", union(ellipse(470, 900, 40, 22, 25), ellipse(530, 900, 40, 22, -25)), "pink")
    return t


def jack_in_the_box():
    t = Template("jack_in_the_box", "Jack in the Box", CAT)
    t.region("spring", union(*[ellipse(500, 470 + 40 * k, 70, 20) for k in range(5)]), "grey")
    t.region("lid", poly([(240, 640), (260, 560), (520, 500), (510, 580)], 10), "blue")
    t.region("box", rect(260, 620, 480, 300, 20), "red")
    t.region("star", star(500, 770, 90), "yellow")
    t.region("crank", union(band([(740, 760), (840, 760)], 24, smooth=False), band([(840, 760), (840, 680)], 24, smooth=False),
                            circle(840, 670, 26)), "grey")
    t.region("hat", union(poly([(380, 220), (300, 100), (500, 190)], 10), poly([(620, 220), (700, 100), (500, 190)], 10)), "purple",
             label="Jester hat")
    t.region("bobble_1", circle(300, 100, 34), "yellow", label="Bobble 1")
    t.region("bobble_2", circle(700, 100, 34), "yellow", label="Bobble 2")
    t.region("face", circle(500, 330, 130), "white")
    t.region("nose", circle(500, 340, 32), "red")
    t.eyes(500, 300, 90, 18)
    t.smile(500, 380, 80, 30)
    return t


def sandcastle():
    t = Template("sandcastle", "Sandcastle", CAT)
    t.region("sand", ellipse(500, 900, 470, 80), "yellow")
    t.region("flag", poly([(500, 140), (600, 170), (500, 200)], 6), "red")
    t.region("pole", rect(490, 140, 20, 140), "brown")
    t.region("left_tower", union(rect(180, 420, 160, 420, 10), *[rect(180 + 50 * k, 380, 40, 50) for k in range(4)]), "peach",
             label="Left tower")
    t.region("right_tower", union(rect(660, 420, 160, 420, 10), *[rect(660 + 50 * k, 380, 40, 50) for k in range(4)]), "peach",
             label="Right tower")
    t.region("middle", union(rect(330, 300, 340, 540, 10), *[rect(330 + 60 * k, 260, 40, 50) for k in range(6)]), "orange",
             label="Middle tower")
    t.region("door", rect(440, 660, 120, 180, 60).intersection(halfplane_above(840)), "brown")
    t.region("bucket", poly([(830, 720), (950, 720), (930, 860), (850, 860)], 12), "blue")
    t.region("shell", union(*[petal((150, 900), a, 70, 34) for a in range(-160, -19, 35)]), "pink")
    return t


def magic_wand():
    t = Template("magic_wand", "Magic Wand", CAT)
    t.region("stick", band([(250, 850), (560, 440)], 40, smooth=False), "purple")
    t.region("grip", band([(250, 850), (330, 745)], 52, smooth=False), "pink")
    t.region("star", star(620, 360, 200), "yellow")
    t.region("ribbon", union(band([(560, 470), (470, 520), (430, 620)], 26), band([(560, 470), (500, 560), (520, 660)], 26)), "pink")
    for i, (x, y, r) in enumerate([(220, 200, 70), (860, 160, 64), (870, 620, 66)]):
        t.region(f"sparkle_{i + 1}", star(x, y, r, r * 0.45, n=4), "yellow", label=f"Sparkle {i + 1}")
    t.eyes(620, 360, 80, 16)
    t.smile(620, 400, 50, 18)
    return t


def unicorn():
    t = Template("unicorn", "Unicorn", CAT)
    t.region("tail", band([(215, 500), (130, 540), (110, 650), (160, 740)], 80), "pink")
    legs = [(240, 640), (335, 650), (515, 650), (600, 640)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 66, 230, 30), "white", label=f"Leg {i + 1}")
    t.region("body", rect(195, 440, 485, 240, 115), "white")
    mane = union(*[circle(665 - 92 * k / 5, 232 + 290 * k / 5, 50) for k in range(6)], circle(730, 220, 48))
    t.region("mane", mane, "purple")
    t.region("neck", poly([(565, 530), (660, 245), (775, 270), (700, 565)], 40), "white")
    t.region("horn", poly([(760, 200), (830, 50), (810, 225)], 10), "yellow")
    t.region("head", ellipse(800, 322, 128, 74, 40), "white")
    t.region("muzzle", ellipse(872, 388, 66, 56, 40), "pink", label="Nose")
    t.region("star", star(400, 540, 60), "yellow", label="Star mark")
    t.eye(752, 318, 17)
    t.dot(893, 392, 9)
    return t


def dragon():
    t = Template("dragon", "Dragon", CAT)
    t.region("tail", union(band([(330, 760), (180, 800), (100, 700)], 70), poly([(100, 720), (40, 600), (150, 640)], 10)), "green")
    wing = poly([(450, 450), (300, 200), (380, 260), (420, 180), (480, 280), (560, 220), (560, 450)], 20)
    t.region("wing", wing, "teal")
    t.region("body", ellipse(480, 640, 200, 200), "green")
    t.region("belly", ellipse(520, 680, 110, 150), "yellow")
    t.region("left_foot", ellipse(400, 840, 80, 40), "green")
    t.region("right_foot", ellipse(590, 840, 80, 40), "green")
    t.region("spikes", union(*[poly([(560 + 60 * k, 320 - 15 * k), (590 + 60 * k, 220 - 15 * k), (630 + 60 * k, 315 - 15 * k)], 8)
                               for k in range(3)]), "orange")
    t.region("head", ellipse(680, 400, 140, 110), "green")
    t.region("snout", ellipse(790, 440, 80, 60), "lightgreen")
    t.region("fire", union(teardrop(920, 450, 50, 2.0, rot=90)), "orange")
    t.eye(670, 370, 22)
    t.dot(800, 420, 8)
    t.smile(780, 470, 40, 14)
    return t


def dinosaur():
    t = Template("dinosaur", "Dinosaur", CAT)
    t.region("tail", poly([(260, 600), (40, 760), (300, 720)], 30), "green")
    for i, x in enumerate((340, 560)):
        t.region(f"leg_{i + 1}", rect(x, 680, 100, 200, 40), "green", label=f"Leg {i + 1}")
    t.region("body", ellipse(460, 600, 250, 170), "green")
    t.region("belly", ellipse(500, 650, 160, 90), "yellow")
    for i in range(4):
        a = math.radians(205 + i * 30)
        x, y = 460 + 245 * math.cos(a), 600 + 165 * math.sin(a)
        t.region(f"plate_{i + 1}", poly([(x - 40, y + 20), (x, y - 60), (x + 40, y + 20)], 12), "orange", label=f"Back plate {i + 1}")
    t.region("neck", band([(620, 520), (720, 380)], 120), "green")
    t.region("head", ellipse(780, 320, 140, 100), "green")
    t.eye(790, 290, 20)
    t.smile(840, 350, 60, 20)
    t.dot(890, 300, 8)
    return t


def wizard_hat():
    t = Template("wizard_hat", "Wizard Hat", CAT)
    t.region("hat", poly([(240, 760), (520, 100), (620, 160), (760, 760)], 30), "purple")
    t.region("band", band([(250, 690), (760, 690)], 80, smooth=False).intersection(poly([(240, 760), (520, 100), (620, 160), (760, 760)], 30)),
             "yellow")
    t.region("brim", ellipse(500, 780, 380, 90), "purple")
    t.region("star_1", star(480, 420, 70), "yellow", label="Star 1")
    t.region("moon", circle(580, 560, 60).difference(circle(610, 540, 50)), "yellow")
    t.region("star_2", star(420, 600, 46), "yellow", label="Star 2")
    t.region("tip", star(620, 140, 60), "yellow")
    return t


def crown():
    t = Template("crown", "Crown", CAT)
    body = poly([(160, 720), (160, 360), (330, 520), (500, 300), (670, 520), (840, 360), (840, 720)], 24)
    t.region("crown", body, "yellow")
    t.region("band", rect(160, 640, 680, 100, 20), "orange")
    for i, (x, y) in enumerate([(160, 340), (500, 280), (840, 340)]):
        t.region(f"ball_{i + 1}", circle(x, y, 45), "yellow", label=f"Crown ball {i + 1}")
    for i, (x, c) in enumerate([(300, "red"), (500, "blue"), (700, "green")]):
        t.region(f"jewel_{i + 1}", ellipse(x, 690, 45, 36), c, label=f"Jewel {i + 1}")
    t.region("heart", union(circle(470, 520, 40), circle(530, 520, 40), poly([(432, 532), (568, 532), (500, 610)], 6)), "pink")
    return t


def pirate_ship():
    t = Template("pirate_ship", "Pirate Ship", CAT)
    t.region("water", ellipse(500, 880, 470, 90), "blue")
    t.region("mast", rect(485, 120, 30, 560), "brown")
    t.region("flag", rect(515, 120, 140, 90, 6), "black")
    t.region("sail_top", poly([(320, 220), (680, 220), (650, 360), (350, 360)], 20), "white", label="Top sail")
    t.region("sail_bottom", poly([(270, 390), (730, 390), (700, 580), (300, 580)], 20), "white", label="Bottom sail")
    t.region("hull", poly([(100, 620), (900, 620), (780, 830), (220, 830)], 30), "brown")
    t.region("stripe", rect(120, 670, 760, 40).intersection(poly([(100, 620), (900, 620), (780, 830), (220, 830)], 30)), "yellow")
    for i, x in enumerate((330, 500, 670)):
        t.region(f"porthole_{i + 1}", circle(x, 760, 30), "black", label=f"Porthole {i + 1}")
    t.dot(585, 160, 22, "#FFFFFF")
    t.line([(470, 470), (530, 510)], 10, smooth=False)
    t.line([(530, 470), (470, 510)], 10, smooth=False)
    return t


def ufo():
    t = Template("ufo", "UFO", CAT)
    t.region("beam", poly([(400, 560), (600, 560), (780, 940), (220, 940)], 10), "yellow", label="Light beam")
    t.region("cow", union(ellipse(500, 800, 90, 55), circle(580, 760, 40)), "white", label="Cow")
    t.region("dome", circle(500, 380, 150).intersection(halfplane_above(420)), "skyblue")
    t.region("alien", circle(500, 360, 70), "green")
    t.region("saucer", ellipse(500, 460, 330, 100), "grey")
    for i, x in enumerate((300, 420, 580, 700)):
        t.region(f"light_{i + 1}", circle(x, 480, 30), ["red", "yellow"][i % 2], label=f"Light {i + 1}")
    t.region("star", star(160, 160, 60), "yellow")
    t.eyes(500, 350, 50, 12)
    t.smile(500, 385, 30, 10)
    return t


def alien():
    t = Template("alien", "Alien", CAT)
    t.region("left_antenna", union(band([(420, 260), (360, 140)], 20, smooth=False), circle(355, 125, 36)), "green",
             label="Left antenna")
    t.region("right_antenna", union(band([(580, 260), (640, 140)], 20, smooth=False), circle(645, 125, 36)), "green",
             label="Right antenna")
    t.region("body", ellipse(500, 720, 170, 180), "green")
    t.region("suit", ellipse(500, 760, 120, 120), "purple")
    t.region("left_arm", band([(350, 660), (250, 560), (220, 480)], 50), "green")
    t.region("right_arm", band([(650, 660), (750, 760)], 50), "green")
    t.region("left_foot", ellipse(420, 900, 80, 40), "green")
    t.region("right_foot", ellipse(580, 900, 80, 40), "green")
    t.region("head", ellipse(500, 400, 210, 170), "lightgreen")
    t.region("eye", circle(500, 380, 90), "white")
    t.region("pupil", circle(500, 390, 45), "blue")
    t.smile(500, 490, 90, 30)
    t.dot(520, 370, 14, "#FFFFFF")
    return t


def astronaut():
    t = Template("astronaut", "Astronaut", CAT)
    t.region("backpack", rect(300, 470, 400, 300, 40), "grey")
    t.region("left_arm", band([(330, 540), (220, 650), (240, 760)], 80), "white")
    t.region("right_arm", band([(670, 540), (780, 440), (800, 340)], 80), "white")
    t.region("left_glove", circle(240, 780, 50), "orange")
    t.region("right_glove", circle(800, 320, 50), "orange")
    t.region("body", rect(340, 480, 320, 320, 60), "white")
    t.region("panel", rect(420, 560, 160, 110, 20), "blue")
    t.region("left_leg", rect(360, 780, 120, 140, 40), "white")
    t.region("right_leg", rect(520, 780, 120, 140, 40), "white")
    t.region("helmet", circle(500, 330, 180), "white")
    t.region("visor", ellipse(500, 340, 130, 100), "skyblue")
    t.region("star", star(140, 160, 60), "yellow")
    t.eyes(500, 330, 80, 16)
    t.smile(500, 370, 50, 18)
    return t


def toy_piano():
    t = Template("toy_piano", "Toy Piano", CAT)
    t.region("body", rect(120, 300, 760, 360, 40), "pink")
    t.region("legs", union(rect(170, 640, 60, 220, 20), rect(770, 640, 60, 220, 20)), "pink")
    for i in range(7):
        t.region(f"key_{i + 1}", rect(160 + 97 * i, 480, 92, 160, 10), "white", label=f"Key {i + 1}")
    for i in (0, 1, 3, 4, 5):
        t.shape_detail(rect(225 + 97 * i, 480, 55, 95, 8))
    t.region("note_1", union(circle(300, 200, 40), rect(320, 80, 20, 120)), "purple", label="Music note 1")
    t.region("note_2", union(circle(700, 180, 40), rect(720, 60, 20, 120)), "blue", label="Music note 2")
    t.region("heart", union(circle(480, 380, 40), circle(540, 380, 40), poly([(442, 392), (578, 392), (510, 460)], 6)), "red")
    return t


def paper_plane():
    t = Template("paper_plane", "Paper Plane", CAT)
    t.region("top_wing", poly([(120, 520), (880, 200), (480, 580)], 14), "white", label="Top wing")
    t.region("bottom_wing", poly([(480, 580), (880, 200), (560, 760)], 14), "skyblue", label="Bottom wing")
    t.region("fold", poly([(480, 580), (560, 760), (430, 650)], 10), "blue")
    t.region("cloud_1", union(circle(160, 820, 70), circle(250, 790, 90), circle(340, 830, 60), rect(110, 820, 280, 70, 35)),
             "white", label="Cloud 1")
    t.region("cloud_2", union(circle(760, 760, 50), circle(830, 730, 70), circle(900, 770, 45), rect(720, 760, 220, 60, 30)),
             "white", label="Cloud 2")
    t.region("sun", circle(160, 170, 80), "yellow")
    for y in (300, 380):
        t.line([(80, y + 160), (230, y + 100)], 8)
    return t


TEMPLATES = [
    spinning_top,
    rubber_duck,
    toy_train,
    rocking_horse,
    xylophone,
    balloons,
    jack_in_the_box,
    sandcastle,
    magic_wand,
    unicorn,
    dragon,
    dinosaur,
    wizard_hat,
    crown,
    pirate_ship,
    ufo,
    alien,
    astronaut,
    toy_piano,
    paper_plane,
]
