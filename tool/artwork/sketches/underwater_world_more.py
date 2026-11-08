"""Twenty more Underwater World sketches (11-30)."""

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

CAT = "underwater_world"


def _fish(t, x, y, rx, ry, colour, tail_colour, facing=1):
    """Simple fish body + tail facing right (facing=1) or left (-1)."""
    tx = x - facing * rx * 0.9
    tail = poly([(tx, y), (tx - facing * rx * 0.7, y - ry * 0.9), (tx - facing * rx * 0.7, y + ry * 0.9)], 18)
    t.region("tail", tail, tail_colour)
    body = ellipse(x, y, rx, ry)
    t.region("body", body, colour)
    return body


def sea_turtle():
    t = Template("sea_turtle", "Sea Turtle", CAT)
    t.region("back_flipper", lens((300, 600), 150, 200, 90), "lightgreen", label="Back flipper")
    t.region("front_flipper", lens((600, 600), 40, 260, 110), "lightgreen", label="Front flipper")
    t.region("top_flipper", lens((560, 420), -40, 240, 100), "lightgreen", label="Top flipper")
    t.region("head", circle(760, 470, 95), "lightgreen")
    shell = ellipse(470, 500, 260, 170)
    t.region("shell", shell, "green")
    for i, (x, y) in enumerate([(470, 500), (350, 470), (590, 470), (420, 600), (540, 600)]):
        t.region(f"shell_plate_{i + 1}", poly([(x - 55, y), (x - 28, y - 48), (x + 28, y - 48), (x + 55, y), (x + 28, y + 48),
                                               (x - 28, y + 48)], 10).intersection(shell.buffer(-15)), "yellow",
                 label=f"Shell pattern {i + 1}")
    t.region("bubble", circle(880, 300, 36), "white")
    t.eye(790, 450, 16)
    t.smile(800, 500, 40, 14)
    return t


def squid():
    t = Template("squid", "Squid", CAT)
    for i, x in enumerate((380, 440, 500, 560, 620)):
        t.region(f"tentacle_{i + 1}", band([(x, 600), (x + (x - 500) * 0.4, 760), (x - (x - 500) * 0.1, 900)], 40),
                 ["pink", "red"][i % 2], label=f"Tentacle {i + 1}")
    t.region("left_fin", poly([(400, 260), (260, 160), (330, 330)], 20), "red")
    t.region("right_fin", mirror(poly([(400, 260), (260, 160), (330, 330)], 20)), "red")
    t.region("body", union(ellipse(500, 420, 140, 230), poly([(400, 260), (500, 90), (600, 260)], 30)), "pink")
    t.region("left_cheek", circle(420, 520, 30), "red")
    t.region("right_cheek", circle(580, 520, 30), "red")
    t.eyes(500, 470, 110, 24)
    t.smile(500, 530, 60, 22)
    return t


def lobster():
    t = Template("lobster", "Lobster", CAT)
    claw = union(ellipse(230, 300, 110, 75, -30), band([(330, 420), (280, 340)], 40))
    t.region("left_claw", claw.difference(poly([(150, 260), (230, 300), (170, 340)])), "red")
    t.region("right_claw", mirror(claw.difference(poly([(150, 260), (230, 300), (170, 340)]))), "red")
    for side in (-1, 1):
        for k in range(3):
            t.line([(500 + side * 110, 520 + 60 * k), (500 + side * 220, 560 + 70 * k)], 14, smooth=False)
    t.region("tail", union(*[ellipse(500, 700 + 55 * k, 100 - 10 * k, 40) for k in range(3)]), "red")
    t.region("fan", poly([(420, 860), (500, 820), (580, 860), (560, 940), (440, 940)], 20), "orange")
    t.region("body", ellipse(500, 520, 140, 170), "red")
    t.region("belly", ellipse(500, 560, 80, 100), "orange")
    t.eyes(500, 430, 100, 22)
    t.smile(500, 480, 50, 18)
    t.line([(460, 360), (400, 200), (330, 140)], 9)
    t.line([(540, 360), (600, 200), (670, 140)], 9)
    return t


def shrimp():
    t = Template("shrimp", "Shrimp", CAT)
    body = band([(300, 650), (330, 470), (480, 380), (650, 420), (720, 560)], 150)
    t.region("body", body, "orange")
    for i, (x, y) in enumerate([(420, 410), (560, 395), (670, 470)]):
        t.region(f"stripe_{i + 1}", band([(x - 20, y - 90), (x + 20, y + 90)], 34, smooth=False).intersection(body), "peach",
                 label=f"Stripe {i + 1}")
    t.region("tail", poly([(300, 700), (200, 820), (330, 800), (400, 820)], 20), "red")
    t.region("head", circle(730, 590, 110), "orange")
    for k in range(4):
        t.line([(460 + 70 * k, 490), (440 + 70 * k, 580)], 10, smooth=False)
    t.eye(760, 570, 20)
    t.smile(760, 630, 40, 14)
    t.line([(800, 520), (900, 380)], 8)
    t.line([(780, 510), (850, 360)], 8)
    return t


def stingray():
    t = Template("stingray", "Stingray", CAT)
    t.region("tail", band([(500, 640), (520, 800), (600, 920)], 26), "grey")
    body = poly([(500, 220), (900, 480), (680, 620), (500, 680), (320, 620), (100, 480)], 70)
    t.region("body", body, "blue")
    t.region("spots", union(*[circle(x, y, 30) for x, y in ((330, 470), (670, 470), (500, 380))]), "skyblue")
    t.region("belly", ellipse(500, 530, 120, 100), "skyblue")
    t.eyes(500, 470, 100, 20)
    t.smile(500, 540, 70, 24)
    return t


def pufferfish():
    t = Template("pufferfish", "Pufferfish", CAT)
    spikes = union(*[poly([(500 + 240 * math.cos(math.radians(a - 9)), 500 + 240 * math.sin(math.radians(a - 9))),
                           (500 + 320 * math.cos(math.radians(a)), 500 + 320 * math.sin(math.radians(a))),
                           (500 + 240 * math.cos(math.radians(a + 9)), 500 + 240 * math.sin(math.radians(a + 9)))], 6)
                      for a in range(0, 360, 30)])
    t.region("spikes", spikes, "orange")
    t.region("tail", poly([(240, 500), (120, 400), (120, 600)], 20), "orange")
    t.region("body", circle(500, 500, 250), "yellow")
    t.region("belly", ellipse(500, 620, 170, 100).intersection(circle(500, 500, 240)), "white")
    t.region("fin", lens((560, 520), 30, 130, 60), "orange")
    t.region("mouth", circle(500, 590, 36), "pink")
    t.eyes(500, 440, 160, 30)
    return t


def clownfish():
    t = Template("clownfish", "Clownfish", CAT)
    t.region("anemone", union(ellipse(500, 900, 360, 70), *[band([(x, 900), (x + 25 * math.sin(x), 740), (x - 15, 700)], 46) for x in range(190, 830, 80)]), "pink")
    body = _fish(t, 520, 450, 260, 160, "orange", "orange")
    for i, x in enumerate((400, 540, 680)):
        t.region(f"stripe_{i + 1}", band([(x - 15, 250), (x + 15, 650)], 60, smooth=False).intersection(body.buffer(-10)),
                 "white", label=f"Stripe {i + 1}")
    t.region("top_fin", poly([(420, 310), (520, 230), (600, 310)], 20), "orange")
    t.eye(690, 420, 26)
    t.smile(730, 490, 50, 18)
    return t


def angelfish():
    t = Template("angelfish", "Angelfish", CAT)
    t.region("top_fin", poly([(380, 400), (480, 100), (620, 380)], 30), "yellow")
    t.region("bottom_fin", poly([(380, 600), (480, 900), (620, 620)], 30), "yellow")
    t.region("tail", poly([(260, 500), (130, 380), (130, 620)], 20), "blue")
    body = poly([(260, 500), (480, 300), (760, 470), (760, 530), (480, 700)], 60)
    t.region("body", body, "skyblue")
    for i, x in enumerate((400, 540)):
        t.region(f"stripe_{i + 1}", band([(x, 280), (x + 20, 720)], 50, smooth=False).intersection(body.buffer(-10)), "blue",
                 label=f"Stripe {i + 1}")
    t.eye(660, 470, 22)
    t.smile(700, 520, 36, 12)
    return t


def swordfish():
    t = Template("swordfish", "Swordfish", CAT)
    t.region("sword", poly([(780, 480), (980, 500), (780, 520)], 6), "grey")
    t.region("top_fin", poly([(400, 420), (480, 230), (560, 420)], 20), "darkblue")
    body = _fish(t, 520, 500, 280, 110, "blue", "darkblue")
    t.region("belly", ellipse(560, 560, 220, 45).intersection(body.buffer(-8)), "white")
    t.region("side_fin", lens((560, 560), 120, 120, 50), "darkblue")
    t.eye(700, 480, 20)
    t.smile(740, 530, 30, 10)
    return t


def seal():
    t = Template("seal", "Seal", CAT)
    t.region("ball", circle(560, 170, 110), "red")
    t.region("ball_stripe", band([(450, 170), (670, 170)], 50, smooth=False).intersection(circle(560, 170, 110)), "yellow",
             label="Ball stripe")
    t.region("tail", union(lens((320, 840), 160, 140, 60), lens((320, 840), 200, 140, 60)), "grey")
    t.region("body", union(ellipse(470, 700, 200, 170), ellipse(560, 480, 130, 180, 20)), "grey")
    t.region("flipper", lens((600, 680), 50, 160, 70), "grey")
    t.region("head", circle(600, 380, 110), "grey")
    t.region("muzzle", ellipse(640, 420, 60, 40), "white")
    t.eyes(600, 350, 80, 16)
    t.dot(645, 405, 12)
    t.smile(640, 440, 40, 12)
    return t


def walrus():
    t = Template("walrus", "Walrus", CAT)
    t.region("body", ellipse(500, 650, 300, 230), "brown")
    t.region("left_flipper", ellipse(280, 850, 100, 40, -10), "brown")
    t.region("right_flipper", ellipse(720, 850, 100, 40, 10), "brown")
    t.region("left_tusk", poly([(440, 520), (420, 760), (470, 530)], 8), "white", label="Left tusk")
    t.region("right_tusk", poly([(560, 520), (580, 760), (530, 530)], 8), "white", label="Right tusk")
    t.region("head", circle(500, 400, 160), "brown")
    t.region("muzzle", union(circle(450, 470, 70), circle(550, 470, 70)), "peach")
    t.eyes(500, 360, 110, 20)
    t.dot(500, 420, 18)
    for x, y in [(430, 460), (420, 490), (570, 460), (580, 490)]:
        t.dot(x, y, 6)
    return t


def narwhal():
    t = Template("narwhal", "Narwhal", CAT)
    t.region("horn", poly([(700, 380), (900, 170), (740, 420)], 6), "yellow")
    t.region("tail", union(lens((240, 560), 220, 150, 70), lens((240, 560), 140, 150, 70)), "skyblue")
    body = ellipse(520, 520, 300, 170)
    t.region("body", body, "skyblue")
    t.region("belly", ellipse(560, 620, 220, 70).intersection(body.buffer(-8)), "white")
    t.region("flipper", lens((520, 590), 120, 140, 60), "blue")
    t.region("spots", union(*[circle(x, y, 22) for x, y in ((400, 430), (470, 400), (360, 500))]), "blue")
    t.region("left_cheek", circle(650, 560, 30), "pink")
    t.eye(680, 500, 20)
    t.smile(730, 560, 40, 14)
    for k in range(4):
        x = 720 + 45 * k
        t.line([(x, 390 - 47 * k), (x + 25, 395 - 47 * k)], 7, smooth=False)
    return t


def eel():
    t = Template("eel", "Eel", CAT)
    t.region("rock", union(ellipse(250, 860, 220, 120), ellipse(420, 900, 160, 90)), "grey")
    t.region("hole", ellipse(300, 820, 90, 60), "black")
    path = [(300, 820), (330, 650), (480, 560), (560, 420), (700, 360)]
    t.region("body", band(path, 110), "green")
    t.region("head", ellipse(740, 340, 120, 85, -15), "green")
    t.region("spots", union(*[circle(x, y, 20) for x, y in ((340, 700), (440, 580), (540, 470))]), "yellow")
    t.eye(760, 310, 18)
    t.smile(800, 370, 40, 12)
    return t


def coral():
    t = Template("coral", "Coral", CAT)
    t.region("sand", ellipse(500, 920, 450, 80), "yellow")
    t.region("pink_coral", union(band([(300, 880), (300, 600), (220, 450)], 60), band([(300, 650), (400, 480), (390, 360)], 50),
                                 band([(300, 720), (180, 640)], 46)), "pink", label="Pink coral")
    t.region("orange_coral", union(band([(650, 880), (640, 600), (700, 420)], 60), band([(645, 650), (540, 500)], 50),
                                   band([(650, 720), (790, 600), (820, 480)], 46)), "orange", label="Orange coral")
    t.region("purple_coral", union(*[circle(480 + 50 * math.cos(math.radians(a)), 780 + 40 * math.sin(math.radians(a)), 50)
                                     for a in range(180, 361, 45)], rect(430, 780, 100, 100, 20)), "purple",
             label="Purple coral")
    t.region("shell", union(*[petal((850, 880), a, 80, 40) for a in range(-160, -19, 35)]), "peach")
    _fish(t, 470, 220, 90, 60, "yellow", "orange")
    t.eye(520, 210, 12)
    return t


def sea_urchin():
    t = Template("sea_urchin", "Sea Urchin", CAT)
    t.region("rock", ellipse(500, 860, 380, 90), "grey")
    spikes = union(*[poly([(500 + 200 * math.cos(math.radians(a - 7)), 620 + 200 * math.sin(math.radians(a - 7))),
                           (500 + 330 * math.cos(math.radians(a)), 620 + 330 * math.sin(math.radians(a))),
                           (500 + 200 * math.cos(math.radians(a + 7)), 620 + 200 * math.sin(math.radians(a + 7)))], 6)
                      for a in range(180, 361, 18)])
    t.region("spikes", spikes, "purple")
    t.region("body", circle(500, 640, 220).intersection(halfplane_above(840)), "pink")
    t.region("left_cheek", circle(400, 690, 32), "red")
    t.region("right_cheek", circle(600, 690, 32), "red")
    t.region("bubble_1", circle(800, 220, 40), "white", label="Bubble 1")
    t.region("bubble_2", circle(860, 130, 28), "white", label="Bubble 2")
    t.eyes(500, 620, 130, 24)
    t.smile(500, 690, 70, 26)
    return t


def conch():
    t = Template("conch", "Seashell", CAT)
    t.region("sand", ellipse(500, 900, 420, 70), "yellow")
    tiers = [(420, 640, 240, 180), (590, 440, 160, 120), (690, 310, 100, 72), (750, 225, 58, 42)]
    for i, (x, y, rx, ry) in enumerate(reversed(tiers)):
        t.region(f"tier_{4 - i}", ellipse(x, y, rx, ry, -35), ["peach", "orange"][(3 - i) % 2], label=f"Shell part {4 - i}")
    t.region("opening", ellipse(350, 700, 120, 150, -35), "pink")
    t.region("starfish", star(830, 820, 80), "orange")
    t.region("bubble", circle(220, 300, 40), "white")
    t.line([(480, 560), (600, 650)], 9)
    t.line([(530, 520), (640, 590)], 9)
    return t


def anchor():
    t = Template("anchor", "Anchor", CAT)
    t.region("ring", circle(500, 170, 80).difference(circle(500, 170, 38)), "grey")
    t.region("shank", rect(465, 240, 70, 560, 20), "grey", label="Anchor pole")
    t.region("bar", rect(330, 300, 340, 60, 30), "grey", label="Cross bar")
    arm = band(arc_pts(500, 600, 270, 20, 160, n=24), 60, smooth=False)
    t.region("arms", arm, "grey")
    t.region("left_point", poly([(180, 585), (205, 720), (310, 668)], 10), "grey", label="Left point")
    t.region("right_point", mirror(poly([(180, 585), (205, 720), (310, 668)], 10)), "grey", label="Right point")
    t.region("rope", band([(560, 170), (700, 240), (680, 400), (760, 520)], 30), "brown")
    t.region("crab", union(ellipse(780, 880, 90, 55), circle(700, 840, 30), circle(860, 840, 30)), "red")
    t.dot(760, 860, 9)
    t.dot(800, 860, 9)
    return t


def treasure_chest():
    t = Template("treasure_chest", "Treasure Chest", CAT)
    t.region("lid", union(rect(220, 260, 560, 200, 30), ellipse(500, 300, 280, 100).intersection(halfplane_above(330))), "brown")
    t.region("gold", union(*[circle(x, 470, 50) for x in range(290, 721, 70)]), "yellow")
    t.region("chest", rect(220, 470, 560, 330, 30), "brown")
    t.region("left_band", rect(300, 470, 50, 330), "orange", label="Left band")
    t.region("right_band", rect(650, 470, 50, 330), "orange", label="Right band")
    t.region("lock", rect(450, 530, 100, 120, 20), "yellow")
    t.region("gem_1", star(400, 420, 45, r=4), "red", label="Gem 1")
    t.region("gem_2", star(600, 420, 45, r=4), "blue", label="Gem 2")
    t.region("sand", ellipse(500, 870, 420, 80), "yellow")
    t.dot(500, 590, 18)
    return t


def sea_otter():
    t = Template("sea_otter", "Sea Otter", CAT)
    t.region("water", rect(0, 590, 1000, 410), "skyblue")
    t.region("tail", ellipse(180, 620, 120, 40, -15), "brown")
    t.region("body", ellipse(450, 600, 260, 130, -10), "brown")
    t.region("belly", ellipse(470, 580, 170, 80, -10), "peach")
    t.region("shell", union(*[petal((470, 500), a, 90, 46) for a in range(-160, -19, 35)]), "pink")
    t.region("left_paw", circle(400, 500, 40), "brown")
    t.region("right_paw", circle(540, 500, 40), "brown")
    t.region("left_foot", ellipse(240, 520, 50, 30, -40), "brown")
    t.region("head", circle(730, 470, 120), "brown")
    t.region("face", ellipse(750, 500, 80, 60), "peach")
    t.eyes(740, 450, 80, 16)
    t.dot(760, 495, 14)
    t.smile(760, 520, 40, 12)
    return t


def seaweed():
    t = Template("seaweed", "Seaweed", CAT)
    t.region("sand", ellipse(500, 920, 450, 80), "yellow")
    for i, (x, h, c) in enumerate([(260, 520, "green"), (420, 680, "lightgreen"), (580, 600, "green"), (740, 480, "teal")]):
        pts = [(x, 900)] + [(x + (40 if k % 2 else -40), 900 - h * k / 4) for k in range(1, 5)]
        t.region(f"seaweed_{i + 1}", band(pts, 60), c, label=f"Seaweed {i + 1}")
    _fish(t, 760, 240, 100, 65, "orange", "red", facing=-1)
    t.region("snail", union(circle(300, 840, 50), ellipse(330, 880, 80, 25)), "pink")
    t.eye(720, 230, 12)
    return t


TEMPLATES = [
    sea_turtle,
    squid,
    lobster,
    shrimp,
    stingray,
    pufferfish,
    clownfish,
    angelfish,
    swordfish,
    seal,
    walrus,
    narwhal,
    eel,
    coral,
    sea_urchin,
    conch,
    anchor,
    treasure_chest,
    sea_otter,
    seaweed,
]
