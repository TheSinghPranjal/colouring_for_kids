"""Twenty more Flowers & Garden sketches (11-30)."""

import math

from lib import (
    Template,
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
    union,
)

CAT = "flowers_garden"


def _ring_flower(t, prefix, cx, cy, n, dist, length, width, colours, centre_r, centre="yellow", label="Petal"):
    for i in range(n):
        a = -90 + i * 360 / n
        base = (cx + dist * math.cos(math.radians(a)), cy + dist * math.sin(math.radians(a)))
        t.region(f"{prefix}petal_{i + 1}", petal(base, a, length, width), colours[i % len(colours)],
                 label=f"{label} {i + 1}")
    t.region(f"{prefix}center", circle(cx, cy, centre_r), centre, label="Middle")


def dandelion():
    t = Template("dandelion", "Dandelion", CAT)
    t.region("leaf", lens((500, 900), -140, 260, 90), "green")
    t.region("stem", band([(500, 520), (510, 700), (500, 930)], 30), "lightgreen")
    puff = union(*[circle(500 + 190 * math.cos(math.radians(a)), 330 + 190 * math.sin(math.radians(a)), 70)
                   for a in range(0, 360, 30)], circle(500, 330, 200))
    t.region("puff", puff, "white")
    t.region("center", circle(500, 330, 80), "yellow")
    for i, (x, y) in enumerate([(820, 160), (870, 290), (180, 150)]):
        t.region(f"seed_{i + 1}", circle(x, y, 34), "white", label=f"Floating seed {i + 1}")
        t.line([(x, y + 34), (x - 10, y + 80)], 8, smooth=False)
    t.eyes(500, 320, 60, 14)
    t.smile(500, 350, 40, 14)
    return t


def lotus():
    t = Template("lotus", "Lotus", CAT)
    t.region("water", ellipse(500, 800, 420, 120), "skyblue")
    t.region("pad", ellipse(500, 760, 300, 80).difference(poly([(500, 760), (700, 700), (720, 780)])), "green",
             label="Lily pad")
    for i, a in enumerate((-160, -125, -55, -20)):
        t.region(f"side_petal_{i + 1}", petal((500, 690), a, 270, 130), "pink", label=f"Side petal {i + 1}")
    t.region("middle_petal", petal((500, 700), -90, 340, 150), "pink", label="Middle petal")
    for i, a in enumerate((-110, -70)):
        t.region(f"front_petal_{i + 1}", petal((500, 720), a, 220, 110), "purple", label=f"Front petal {i + 1}")
    return t


def poppy():
    t = Template("poppy", "Poppy", CAT)
    t.region("stem", band([(500, 520), (480, 720), (505, 935)], 30), "green")
    t.region("bud_stem", band([(490, 760), (620, 690), (705, 650)], 22), "green", label="Bud stem")
    t.region("bud", ellipse(745, 610, 60, 85, 35), "lightgreen")
    t.region("leaf", lens((485, 840), -150, 220, 90), "green")
    for i, a in enumerate((-150, -30, 30, 150)):
        base = (500 + 40 * math.cos(math.radians(a)), 380 + 40 * math.sin(math.radians(a)))
        t.region(f"petal_{i + 1}", petal(base, a, 230, 230), "red", label=f"Petal {i + 1}")
    t.region("top_petal", petal((500, 360), -90, 200, 260), "orange", label="Top petal")
    t.region("center", circle(500, 390, 80), "black")
    for a in range(0, 360, 45):
        r = math.radians(a)
        t.dot(500 + 50 * math.cos(r), 390 + 50 * math.sin(r), 9, "#FFFFFF")
    return t


def bluebell():
    t = Template("bluebell", "Bluebell", CAT)
    t.region("leaf_1", lens((420, 940), -100, 520, 90), "green", label="Leaf 1")
    t.region("leaf_2", lens((440, 940), -70, 420, 80), "lightgreen", label="Leaf 2")
    t.region("stem", band([(380, 940), (420, 500), (520, 220), (700, 160)], 26), "green")
    bells = [(560, 300), (680, 330), (760, 430), (790, 560)]
    for i, (x, y) in enumerate(bells):
        t.line([(x - 40, y - 90), (x, y - 50)], 10)
        bell = union(ellipse(x, y, 60, 70), *[circle(x + dx, y + 62, 22) for dx in (-42, 0, 42)])
        t.region(f"bell_{i + 1}", bell, ["blue", "purple", "blue", "purple"][i], label=f"Bell {i + 1}")
    return t


def cherry_blossom():
    t = Template("cherry_blossom", "Cherry Blossom", CAT)
    t.region("branch", band([(60, 820), (300, 700), (520, 560), (760, 470), (950, 440)], 46), "brown")
    t.region("twig", band([(520, 560), (580, 400), (620, 300)], 30), "brown")
    flowers = [(250, 620, 95), (610, 260, 90), (760, 600, 95)]
    for k, (x, y, r) in enumerate(flowers):
        petals = union(*[petal((x, y), -90 + i * 72, r * 1.4, r) for i in range(5)])
        t.region(f"flower_{k + 1}", petals, "pink", label=f"Flower {k + 1}")
        t.region(f"flower_{k + 1}_middle", circle(x, y, 34), "red", label=f"Flower {k + 1} middle")
    t.region("bud", ellipse(880, 380, 40, 55, 30), "pink")
    return t


def bouquet():
    t = Template("bouquet", "Bouquet", CAT)
    t.region("stems", poly([(400, 560), (600, 560), (540, 930), (460, 930)], 20), "green")
    t.region("leaf_left", lens((450, 560), -150, 230, 100), "lightgreen", label="Left leaf")
    t.region("leaf_right", lens((550, 560), -30, 230, 100), "lightgreen", label="Right leaf")
    heads = [(340, 400, "red"), (500, 330, "yellow"), (660, 400, "purple"), (420, 520, "pink"), (580, 520, "orange")]
    for i, (x, y, c) in enumerate(heads):
        head = union(*[circle(x + 62 * math.cos(math.radians(a)), y + 62 * math.sin(math.radians(a)), 46)
                       for a in range(0, 360, 60)])
        t.region(f"flower_{i + 1}", head, c, label=f"Flower {i + 1}")
    t.region("wrap", poly([(330, 600), (670, 600), (560, 900), (440, 900)], 24), "pink", label="Wrapping")
    bow = union(ellipse(440, 680, 70, 40, 20), ellipse(560, 680, 70, 40, -20))
    t.region("bow", bow, "red")
    t.region("knot", circle(500, 680, 32), "red")
    for x, y, _ in heads:
        t.dot(x, y, 22, "#FFFFFF")
    return t


def watering_can():
    t = Template("watering_can", "Watering Can", CAT)
    t.region("handle", band([(320, 380), (420, 230), (600, 230), (700, 380)], 50), "blue")
    t.region("spout", poly([(700, 560), (880, 330), (920, 360), (760, 640)], 18), "blue")
    t.region("rose", ellipse(905, 330, 50, 70, 40), "grey", label="Sprinkler")
    t.region("can", rect(260, 380, 470, 460, 60), "skyblue")
    t.region("band", rect(260, 560, 470, 90).intersection(rect(260, 380, 470, 460, 60)), "blue", label="Stripe")
    t.region("flower", union(*[circle(400 + 40 * math.cos(math.radians(a)), 730 + 40 * math.sin(math.radians(a)), 30)
                                for a in range(0, 360, 72)]), "pink")
    for i, (x, y) in enumerate([(930, 470), (890, 560), (950, 600)]):
        t.region(f"drop_{i + 1}", ellipse(x, y, 22, 32), "skyblue", label=f"Water drop {i + 1}")
    t.eyes(560, 470, 90, 16)
    t.smile(560, 505, 50, 18)
    return t


def wheelbarrow():
    t = Template("wheelbarrow", "Wheelbarrow", CAT)
    t.region("handle", band([(560, 560), (930, 470)], 34, smooth=False), "brown")
    t.region("legs", union(band([(600, 600), (640, 820)], 30, smooth=False),
                           band([(640, 820), (690, 820)], 30, smooth=False)), "grey")
    t.region("plant_1", union(lens((300, 420), -110, 170, 70), lens((300, 420), -60, 170, 70)), "green",
             label="Plant 1")
    t.region("plant_2", union(lens((470, 420), -120, 160, 70), lens((470, 420), -70, 160, 70)), "lightgreen",
             label="Plant 2")
    t.region("soil", ellipse(390, 430, 250, 50), "brown")
    t.region("tray", poly([(120, 420), (680, 420), (590, 660), (220, 660)], 36), "red")
    t.region("wheel", circle(320, 760, 110), "black")
    t.region("hub", circle(320, 760, 45), "grey")
    t.region("flower", union(*[circle(560 + 32 * math.cos(math.radians(a)), 300 + 32 * math.sin(math.radians(a)), 28)
                                for a in range(0, 360, 60)]), "yellow")
    t.line([(560, 330), (540, 410)], 12)
    return t


def birdhouse():
    t = Template("birdhouse", "Birdhouse", CAT)
    t.region("pole", rect(460, 720, 80, 230, 20), "brown")
    t.region("house", poly([(300, 420), (500, 270), (700, 420), (700, 740), (300, 740)], 20), "yellow")
    t.region("roof", union(band([(230, 470), (500, 240)], 70, smooth=False),
                           band([(500, 240), (770, 470)], 70, smooth=False)), "red")
    t.region("hole", circle(500, 520, 70), "black", label="Door hole")
    t.region("perch", rect(460, 620, 80, 30, 14), "brown")
    t.region("bird_body", ellipse(760, 640, 95, 70), "skyblue", label="Bird")
    t.region("bird_head", circle(830, 570, 55), "skyblue", label="Bird head")
    t.region("beak", poly([(868, 548), (955, 575), (868, 608)], 10), "orange")
    t.region("wing", ellipse(745, 650, 55, 35, -15), "blue")
    t.eye(840, 560, 12)
    return t


def garden_gnome():
    t = Template("garden_gnome", "Garden Gnome", CAT)
    t.region("hat", poly([(330, 400), (510, 80), (680, 400)], 30), "red")
    t.region("body", poly([(330, 620), (670, 620), (720, 880), (280, 880)], 40), "blue")
    t.region("belt", rect(300, 700, 400, 50).intersection(poly([(330, 620), (670, 620), (720, 880), (280, 880)], 40)),
             "black")
    t.region("buckle", rect(465, 695, 70, 60, 10), "yellow")
    t.region("left_boot", ellipse(380, 900, 90, 45), "brown")
    t.region("right_boot", ellipse(620, 900, 90, 45), "brown")
    t.region("face", ellipse(500, 440, 150, 110), "peach")
    t.region("beard", union(poly([(340, 470), (660, 470), (500, 760)], 40), circle(400, 520, 70), circle(600, 520, 70)),
             "white")
    t.region("nose", circle(500, 470, 45), "pink")
    t.eyes(500, 420, 110, 15)
    t.line([(400, 385), (440, 380)], 9, smooth=False)
    t.line([(560, 380), (600, 385)], 9, smooth=False)
    return t


def pine_tree():
    t = Template("pine_tree", "Pine Tree", CAT)
    t.region("trunk", rect(445, 760, 110, 170, 16), "brown")
    t.region("bottom", poly([(180, 800), (500, 450), (820, 800)], 30), "green", label="Bottom branches")
    t.region("middle", poly([(250, 590), (500, 290), (750, 590)], 30), "lightgreen", label="Middle branches")
    t.region("top", poly([(320, 400), (500, 140), (680, 400)], 30), "green", label="Top branches")
    t.region("star", star(500, 130, 80), "yellow")
    for i, (x, y, c) in enumerate([(380, 700, "red"), (620, 690, "blue"), (430, 520, "purple"), (590, 480, "orange")]):
        t.region(f"bauble_{i + 1}", circle(x, y, 34), c, label=f"Bauble {i + 1}")
    return t


def palm_tree():
    t = Template("palm_tree", "Palm Tree", CAT)
    t.region("sand", ellipse(500, 900, 380, 90), "yellow")
    trunk = band([(470, 880), (500, 650), (560, 420), (600, 330)], 70)
    t.region("trunk", trunk, "brown")
    for i, a in enumerate((-170, -130, -60, -20, 20, 160)):
        t.region(f"leaf_{i + 1}", lens((600, 320), a, 330, 110), ["green", "lightgreen"][i % 2], label=f"Leaf {i + 1}")
    for i, (x, y) in enumerate([(565, 360), (640, 365)]):
        t.region(f"coconut_{i + 1}", circle(x, y, 40), "brown", label=f"Coconut {i + 1}")
    for y in (560, 660, 760):
        t.line([(470, y), (530, y - 15)], 9, smooth=False)
    return t


def acorn():
    t = Template("acorn", "Acorn", CAT)
    t.region("stalk", band([(500, 230), (520, 160), (560, 130)], 34), "brown")
    t.region("leaf", lens((540, 200), -20, 240, 110), "green")
    t.region("nut", union(ellipse(500, 560, 210, 260).intersection(halfplane_below(400)), circle(500, 790, 40)), "orange")
    t.region("cap", union(ellipse(500, 360, 270, 140), rect(240, 360, 520, 70, 30)), "brown")
    t.eyes(500, 560, 120, 22)
    t.smile(500, 630, 70, 26)
    t.dot(400, 620, 26, "#F48FB1")
    t.dot(600, 620, 26, "#F48FB1")
    for x in range(300, 720, 70):
        t.line([(x, 290), (x + 30, 410)], 8, smooth=False)
    return t


def clover():
    t = Template("clover", "Clover", CAT)
    t.region("stem", band([(500, 520), (540, 750), (500, 940)], 34), "green")
    for i, a in enumerate((-90, 0, 90, 180)):
        r = math.radians(a)
        cx, cy = 500 + 150 * math.cos(r), 420 + 150 * math.sin(r)
        heart = union(circle(cx + 70 * math.cos(r + 0.9), cy + 70 * math.sin(r + 0.9), 105),
                      circle(cx + 70 * math.cos(r - 0.9), cy + 70 * math.sin(r - 0.9), 105))
        t.region(f"leaf_{i + 1}", heart, ["green", "lightgreen"][i % 2], label=f"Leaf {i + 1}")
    t.region("middle", circle(500, 420, 60), "yellow")
    t.eyes(500, 410, 46, 10)
    return t


def seedling():
    t = Template("seedling", "Seedling", CAT)
    t.region("pot", poly([(310, 600), (690, 600), (640, 920), (360, 920)], 28), "orange")
    t.region("rim", rect(280, 560, 440, 80, 28), "red")
    t.region("soil", ellipse(500, 560, 190, 30).intersection(halfplane_above(575)), "brown")
    t.region("stem", band([(500, 560), (490, 420), (500, 320)], 30), "green")
    t.region("left_leaf", lens((495, 330), -160, 240, 130), "lightgreen", label="Left leaf")
    t.region("right_leaf", lens((505, 330), -20, 240, 130), "green", label="Right leaf")
    t.eyes(500, 740, 110, 20)
    t.smile(500, 790, 70, 26)
    t.region("ladybug", circle(700, 250, 45), "red")
    t.dot(700, 215, 18)
    return t


def shovel():
    t = Template("shovel", "Shovel", CAT)
    t.region("grip", union(band([(380, 100), (620, 100)], 50, smooth=False), rect(470, 100, 60, 60)), "red")
    t.region("handle", rect(470, 130, 60, 470, 20), "brown")
    t.region("collar", rect(440, 570, 120, 70, 16), "grey")
    t.region("blade", union(rect(360, 620, 280, 180, 20), poly([(360, 780), (640, 780), (500, 930)], 30)), "grey")
    t.region("worm", band([(720, 880), (780, 820), (840, 880), (900, 820)], 40), "pink")
    t.region("dirt", ellipse(240, 880, 150, 60), "brown")
    t.dot(905, 810, 8)
    return t


def garden_bench():
    t = Template("garden_bench", "Garden Bench", CAT)
    for i, x in enumerate((180, 760)):
        t.region(f"leg_{i + 1}", rect(x, 560, 60, 330, 20), "black", label=f"Leg {i + 1}")
    for i, y in enumerate((300, 400)):
        t.region(f"back_{i + 1}", rect(140, y, 720, 70, 24), "brown", label=f"Back slat {i + 1}")
    t.region("seat", rect(110, 550, 780, 80, 26), "orange")
    t.region("seat_front", rect(130, 630, 740, 50, 20), "brown", label="Seat front")
    t.region("flower_pot", poly([(860, 740), (980, 740), (960, 900), (880, 900)], 14), "red")
    t.region("flower", union(*[circle(920 + 34 * math.cos(math.radians(a)), 680 + 34 * math.sin(math.radians(a)), 28)
                                for a in range(0, 360, 60)]), "yellow")
    t.region("cat", union(ellipse(420, 500, 110, 60), circle(540, 470, 55), poly([(505, 440), (510, 385), (545, 425)], 6),
                          poly([(560, 425), (590, 385), (590, 440)], 6)), "grey", label="Sleeping cat")
    t.sleepy_eye(525, 470, 22, 7)
    t.sleepy_eye(560, 470, 22, 7)
    return t


def beehive():
    t = Template("beehive", "Beehive", CAT)
    t.region("branch", band([(60, 160), (500, 150), (940, 170)], 50), "brown")
    t.region("rope", rect(485, 160, 30, 90), "brown")
    tiers = [(500, 300, 150), (500, 410, 210), (500, 530, 240), (500, 650, 220), (500, 760, 160)]
    for i, (x, y, rx) in enumerate(tiers):
        t.region(f"tier_{i + 1}", ellipse(x, y, rx, 72), ["yellow", "orange"][i % 2], label=f"Hive ring {i + 1}")
    t.region("door", ellipse(500, 620, 60, 50), "black")
    for i, (x, y) in enumerate([(220, 520), (790, 400)]):
        t.region(f"bee_{i + 1}", ellipse(x, y, 60, 42), "yellow", label=f"Bee {i + 1}")
        t.region(f"bee_{i + 1}_wing", ellipse(x - 5, y - 55, 32, 40), "white", label=f"Bee {i + 1} wing")
        t.line([(x - 15, y - 40), (x - 15, y + 40)], 12, smooth=False)
        t.line([(x + 18, y - 38), (x + 18, y + 38)], 12, smooth=False)
        t.dot(x + 40, y - 8, 8)
    return t


def lily_pad():
    t = Template("lily_pad", "Lily Pad", CAT)
    t.region("pond", ellipse(500, 640, 470, 300), "skyblue")
    pad = circle(470, 690, 250).difference(poly([(470, 690), (760, 600), (760, 760)]))
    t.region("pad", pad, "green", label="Lily pad")
    t.region("frog_body", ellipse(450, 590, 140, 110), "lightgreen", label="Frog")
    t.region("left_eye_bump", circle(380, 470, 60), "lightgreen", label="Left eye")
    t.region("right_eye_bump", circle(520, 470, 60), "lightgreen", label="Right eye")
    t.region("belly", ellipse(450, 630, 80, 60), "yellow")
    t.region("flower", union(*[petal((780, 420), a, 110, 60) for a in range(-180, 1, 36)]), "pink")
    t.eye(380, 470, 22)
    t.eye(520, 470, 22)
    t.smile(450, 545, 90, 30)
    return t


def lavender():
    t = Template("lavender", "Lavender", CAT)
    spikes = [(330, 260, -20), (500, 200, 0), (670, 260, 20)]
    for i, (x, y, a) in enumerate(spikes):
        bottom = (x + 4 * 28 * math.sin(math.radians(a)), y + 250)
        t.region(f"stem_{i + 1}", band([bottom, (500 + (bottom[0] - 500) * 0.3, 760), (500 + (x - 500) * 0.1, 930)], 26),
                 "green", label=f"Stem {i + 1}")
    for i, (x, y, a) in enumerate(spikes):
        spike = union(*[ellipse(x + k * 28 * math.sin(math.radians(a)), y + k * 58, 48 - k * 3, 38) for k in range(5)])
        t.region(f"spike_{i + 1}", spike, "purple", label=f"Flowers {i + 1}")
    t.region("ribbon", union(ellipse(425, 770, 75, 38, 25), ellipse(575, 770, 75, 38, -25)), "pink")
    t.region("knot", circle(500, 770, 34), "red")
    return t


TEMPLATES = [
    dandelion,
    lotus,
    poppy,
    bluebell,
    cherry_blossom,
    bouquet,
    watering_can,
    wheelbarrow,
    birdhouse,
    garden_gnome,
    pine_tree,
    palm_tree,
    acorn,
    clover,
    seedling,
    shovel,
    garden_bench,
    beehive,
    lily_pad,
    lavender,
]
