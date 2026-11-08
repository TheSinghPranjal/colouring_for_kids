"""Twenty more Sky & Weather sketches (11-30)."""

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

CAT = "sky_weather"


def _cloud(cx, cy, s=1.0):
    return union(
        circle(cx - 150 * s, cy + 20 * s, 90 * s),
        circle(cx - 30 * s, cy - 50 * s, 130 * s),
        circle(cx + 120 * s, cy, 100 * s),
        rect(cx - 220 * s, cy + 10 * s, 420 * s, 100 * s, 50 * s),
    )


def snowflake():
    t = Template("snowflake", "Snowflake", CAT)
    for i in range(6):
        a = math.radians(-90 + i * 60)
        tip = (500 + 380 * math.cos(a), 500 + 380 * math.sin(a))
        arm = band([(500, 500), tip], 60, smooth=False)
        mid = (500 + 250 * math.cos(a), 500 + 250 * math.sin(a))
        for s in (-1, 1):
            b = a + s * math.radians(45)
            arm = union(arm, band([mid, (mid[0] + 110 * math.cos(b), mid[1] + 110 * math.sin(b))], 44, smooth=False))
        t.region(f"arm_{i + 1}", arm, ["skyblue", "white"][i % 2], label=f"Arm {i + 1}")
    t.region("center", circle(500, 500, 130), "skyblue")
    t.eyes(500, 480, 80, 16)
    t.smile(500, 520, 50, 18)
    return t


def tornado():
    t = Template("tornado", "Tornado", CAT)
    widths = [380, 320, 260, 200, 150, 100]
    for i, w in enumerate(widths):
        y = 180 + i * 105
        x = 500 + (30 if i % 2 else -30) * (i / 2)
        t.region(f"swirl_{i + 1}", ellipse(x, y, w, 72), ["grey", "skyblue"][i % 2], label=f"Swirl {i + 1}")
    t.region("tip", poly([(440, 760), (600, 760), (520, 930)], 20), "grey")
    t.region("cow", union(ellipse(160, 320, 70, 45), circle(220, 290, 35)), "white", label="Flying cow")
    t.region("leaf", lens((820, 420), -20, 120, 60), "green")
    t.eyes(500, 300, 100, 18)
    t.smile(500, 335, 50, 16)
    return t


def windsock():
    t = Template("windsock", "Windsock", CAT)
    t.region("pole", rect(160, 150, 40, 780, 14), "grey")
    t.region("ring", annulus(260, 300, 110, 80), "grey")
    colours = ["red", "white", "red", "white"]

    def edge(x):
        f = (x - 260) / 600
        return 300 - 100 * (1 - f) - 45 * f, 300 + 100 * (1 - f) + 45 * f

    for i in range(4):
        x0, x1 = 300 + i * 140, 300 + (i + 1) * 140
        (t0, b0), (t1, b1) = edge(x0), edge(x1)
        t.region(f"stripe_{i + 1}", poly([(x0, t0), (x1, t1), (x1, b1), (x0, b0)], 4), colours[i], label=f"Stripe {i + 1}")
    t.region("grass", ellipse(180, 930, 200, 40), "lightgreen")
    t.region("cloud", _cloud(720, 760, 0.6), "white")
    for y in (180, 520):
        t.line([(500, y), (650, y), (700, y - 30)], 9)
    return t


def planet():
    t = Template("planet", "Planet", CAT)
    ring = ellipse(500, 520, 430, 110, -15).difference(ellipse(500, 520, 330, 70, -15))
    t.region("ring_back", ring.intersection(halfplane_above(470)), "yellow", label="Back of ring")
    t.region("planet", circle(500, 500, 250), "orange")
    t.region("stripe_1", band([(260, 420), (740, 360)], 50, smooth=False).intersection(circle(500, 500, 250)), "red",
             label="Stripe 1")
    t.region("stripe_2", band([(260, 630), (740, 570)], 50, smooth=False).intersection(circle(500, 500, 250)), "red",
             label="Stripe 2")
    t.region("ring_front", ring.intersection(halfplane_below(470)), "yellow", label="Front of ring")
    t.region("star_1", star(140, 160, 60), "yellow", label="Star 1")
    t.region("star_2", star(860, 820, 50), "yellow", label="Star 2")
    t.eyes(500, 470, 110, 20)
    t.smile(500, 515, 60, 20)
    return t


def comet():
    t = Template("comet", "Comet", CAT)
    tail = poly([(640, 420), (120, 120), (200, 330), (60, 420), (230, 520), (130, 740), (660, 600)], 40)
    t.region("tail", tail, "orange")
    t.region("inner_tail", poly([(640, 460), (280, 280), (360, 450), (300, 560), (640, 560)], 30), "yellow", label="Inner tail")
    t.region("head", circle(680, 520, 170), "yellow")
    t.region("star", star(860, 200, 60), "yellow")
    t.region("left_cheek", circle(610, 580, 28), "pink")
    t.region("right_cheek", circle(760, 580, 28), "pink")
    t.eyes(690, 500, 100, 20)
    t.smile(690, 550, 60, 20)
    return t


def earth():
    t = Template("earth", "Earth", CAT)
    globe = circle(500, 500, 330)
    t.region("ocean", globe, "blue")
    lands = [blob([(260, 300), (380, 240), (460, 320), (420, 440), (320, 470), (230, 400)]),
             blob([(560, 260), (700, 230), (780, 330), (720, 420), (600, 390)]),
             blob([(330, 560), (450, 560), (480, 680), (400, 780), (320, 700)]),
             blob([(600, 560), (760, 540), (790, 660), (680, 720), (590, 650)])]
    for i, land in enumerate(lands):
        t.region(f"land_{i + 1}", land.intersection(globe), "green", label=f"Land {i + 1}")
    t.region("cloud", _cloud(720, 800, 0.45), "white")
    t.region("moon", circle(150, 160, 70), "grey")
    t.eyes(500, 480, 110, 20)
    t.smile(500, 525, 60, 20)
    return t


def raindrop():
    t = Template("raindrop", "Raindrop", CAT)
    t.region("cloud", _cloud(500, 200, 0.8), "white")
    t.region("drop", teardrop(500, 620, 210, 2.0), "skyblue")
    t.region("shine", ellipse(420, 560, 30, 70, 20), "white")
    t.region("small_drop_1", teardrop(200, 760, 60, 2.0), "blue", label="Small drop 1")
    t.region("small_drop_2", teardrop(800, 760, 60, 2.0), "blue", label="Small drop 2")
    t.region("puddle", ellipse(500, 920, 360, 50), "blue")
    t.region("left_cheek", circle(400, 690, 30), "pink")
    t.region("right_cheek", circle(600, 690, 30), "pink")
    t.eyes(500, 640, 110, 22)
    t.smile(500, 690, 60, 22)
    return t


def rain_boots():
    t = Template("rain_boots", "Rain Boots", CAT)
    boot = union(rect(180, 240, 200, 520, 30), rect(180, 640, 330, 160, 70))
    t.region("left_boot", boot, "yellow")
    t.region("left_top", rect(160, 220, 240, 70, 24), "orange", label="Left boot top")
    t.region("left_sole", rect(170, 780, 350, 50, 20), "black", label="Left sole")
    right = union(rect(560, 300, 200, 470, 30), rect(560, 650, 330, 160, 70))
    t.region("right_boot", right, "red")
    t.region("right_top", rect(540, 280, 240, 70, 24), "orange", label="Right boot top")
    t.region("right_sole", rect(550, 790, 350, 50, 20), "black", label="Right sole")
    t.region("puddle", ellipse(500, 900, 450, 60), "skyblue")
    t.region("left_dot", circle(280, 450, 40), "white", label="Left boot spot")
    t.region("right_dot", circle(660, 500, 40), "white", label="Right boot spot")
    return t


def raincoat():
    t = Template("raincoat", "Raincoat", CAT)
    t.region("hood", union(circle(500, 260, 170).intersection(halfplane_above(330)), rect(330, 250, 340, 90)), "yellow")
    t.region("face", ellipse(500, 300, 110, 100), "peach")
    t.region("left_sleeve", poly([(330, 380), (170, 640), (240, 690), (360, 500)], 30), "yellow")
    t.region("right_sleeve", mirror(poly([(330, 380), (170, 640), (240, 690), (360, 500)], 30)), "yellow")
    t.region("coat", poly([(330, 360), (670, 360), (740, 860), (260, 860)], 40), "yellow")
    t.region("pocket_left", rect(330, 650, 100, 90, 14), "orange", label="Left pocket")
    t.region("pocket_right", rect(570, 650, 100, 90, 14), "orange", label="Right pocket")
    for i, y in enumerate((450, 540, 630)):
        t.region(f"button_{i + 1}", circle(500, y, 26), "red", label=f"Button {i + 1}")
    t.region("left_boot", ellipse(400, 900, 80, 40), "red")
    t.region("right_boot", ellipse(600, 900, 80, 40), "red")
    t.eyes(500, 290, 70, 14)
    t.smile(500, 330, 40, 14)
    return t


def thermometer():
    t = Template("thermometer", "Thermometer", CAT)
    t.region("tube", union(rect(420, 120, 160, 620, 80)), "white")
    t.region("bulb", circle(500, 780, 130), "red")
    t.region("mercury", rect(470, 400, 60, 400, 20), "red")
    t.region("sun", circle(800, 220, 100), "yellow")
    t.region("snowflake", star(200, 260, 80, 40, n=6), "skyblue")
    for y in range(200, 680, 70):
        t.line([(580, y), (530, y)], 8, smooth=False)
    t.eyes(500, 770, 70, 14)
    t.smile(500, 805, 40, 14)
    return t


def mountain():
    t = Template("mountain", "Mountain", CAT)
    t.region("sun", circle(800, 200, 90), "yellow")
    t.region("back_mountain", poly([(400, 900), (720, 300), (1000, 820), (1000, 900)], 20), "blue", label="Back mountain")
    t.region("back_snow", poly([(640, 450), (720, 300), (800, 450), (760, 420), (720, 460), (680, 420)], 10), "white",
             label="Back snow")
    t.region("mountain", poly([(0, 900), (0, 800), (380, 180), (760, 900)], 20), "purple")
    t.region("snow", poly([(270, 360), (380, 180), (490, 360), (440, 330), (380, 390), (320, 330)], 10), "white")
    t.region("grass", rect(0, 860, 1000, 140), "green")
    t.region("tree", poly([(820, 880), (880, 720), (940, 880)], 10), "lightgreen")
    return t


def volcano():
    t = Template("volcano", "Volcano", CAT)
    t.region("smoke", union(circle(500, 170, 80), circle(420, 120, 60), circle(590, 110, 60)), "grey")
    t.region("lava_top", union(*[circle(400 + 50 * k, 300, 50) for k in range(5)]), "orange", label="Lava top")
    t.region("volcano", poly([(80, 900), (390, 320), (610, 320), (920, 900)], 30), "brown")
    lava = union(band([(430, 320), (400, 450), (330, 560)], 70), band([(560, 320), (600, 480), (680, 600)], 60))
    t.region("lava", lava, "red")
    t.region("ground", rect(0, 870, 1000, 130), "green")
    t.region("rock_1", ellipse(150, 880, 70, 40), "grey", label="Rock 1")
    t.region("rock_2", ellipse(860, 890, 70, 40), "grey", label="Rock 2")
    return t


def sunset():
    t = Template("sunset", "Sunset", CAT)
    t.region("sky", rect(0, 0, 1000, 600), "orange")
    t.region("sun", circle(500, 600, 220).intersection(halfplane_above(600)), "yellow")
    t.region("sea", rect(0, 600, 1000, 400), "blue")
    for i, y in enumerate((670, 760, 850)):
        t.region(f"wave_{i + 1}", band([(140 + 80 * i, y), (380, y - 20), (620, y), (860 - 80 * i, y - 20)], 30), "skyblue",
                 label=f"Wave {i + 1}")
    t.region("bird", union(band([(180, 200), (230, 170), (270, 200)], 20), band([(270, 200), (310, 170), (360, 200)], 20)), "black")
    t.region("cloud", _cloud(780, 200, 0.5), "pink")
    return t


def parachute():
    t = Template("parachute", "Parachute", CAT)
    canopy = circle(500, 450, 380).intersection(halfplane_above(450))
    colours = ["red", "yellow", "blue", "green"]
    for i in range(4):
        a0, a1 = 180 + i * 45, 180 + (i + 1) * 45
        wedge = poly([(500, 450)] + [(500 + 400 * math.cos(math.radians(a)), 450 + 400 * math.sin(math.radians(a)))
                                     for a in range(a0, a1 + 1, 5)])
        t.region(f"panel_{i + 1}", wedge.intersection(canopy), colours[i], label=f"Panel {i + 1}")
    t.region("basket", rect(400, 720, 200, 150, 24), "brown")
    t.region("teddy", union(circle(500, 680, 60), circle(455, 630, 22), circle(545, 630, 22)), "orange", label="Teddy")
    for x in (130, 330, 670, 870):
        t.line([(x, 455), (500 + (x - 500) * 0.25, 720)], 8, smooth=False)
    t.dot(480, 675, 8)
    t.dot(520, 675, 8)
    return t


def weather_vane():
    t = Template("weather_vane", "Weather Vane", CAT)
    t.region("pole", rect(480, 200, 40, 640, 14), "grey")
    t.region("arrow", union(poly([(160, 360), (260, 300), (260, 420)], 10), rect(250, 345, 520, 30)), "black")
    t.region("tail", poly([(760, 300), (860, 300), (840, 360), (860, 420), (760, 420)], 10), "red")
    t.region("rooster", union(ellipse(500, 250, 100, 60), circle(420, 200, 40), poly([(560, 240), (640, 170), (620, 270)], 10)),
             "orange")
    t.region("ball", circle(500, 360, 40), "yellow")
    t.region("roof", poly([(200, 960), (500, 820), (800, 960)], 20), "red")
    t.region("cloud", _cloud(800, 650, 0.5), "white")
    t.dot(410, 195, 7)
    return t


def sun_cloud():
    t = Template("sun_cloud", "Sun and Cloud", CAT)
    for i, deg in enumerate((-180, -150, -120, -90, -60, -30, 150)):
        a = math.radians(deg)
        base = (380 + 200 * math.cos(a), 380 + 200 * math.sin(a))
        tip = (380 + 330 * math.cos(a), 380 + 330 * math.sin(a))
        t.region(f"ray_{i + 1}", band([base, tip], 50, smooth=False), ["orange", "yellow"][i % 2], label=f"Ray {i + 1}")
    t.region("sun", circle(380, 380, 190), "yellow")
    t.region("cloud", _cloud(600, 620, 1.1), "white")
    t.region("left_cheek", circle(520, 700, 34), "pink")
    t.region("right_cheek", circle(720, 700, 34), "pink")
    t.eyes(620, 640, 130, 22)
    t.smile(620, 690, 70, 24)
    t.eyes(330, 330, 80, 14)
    return t


def snow_cloud():
    t = Template("snow_cloud", "Snow Cloud", CAT)
    t.region("cloud", _cloud(500, 380, 1.15), "grey")
    for i, (x, y) in enumerate([(250, 680), (430, 760), (610, 680), (790, 760), (340, 880), (700, 880)]):
        t.region(f"snowflake_{i + 1}", star(x, y, 66, 30, n=6), ["white", "skyblue"][i % 2], label=f"Snowflake {i + 1}")
    t.region("left_cheek", circle(380, 460, 34), "pink")
    t.region("right_cheek", circle(620, 460, 34), "pink")
    t.eyes(500, 400, 160, 22)
    t.smile(500, 460, 60, 22)
    return t


def sunglasses():
    t = Template("sunglasses", "Sunglasses", CAT)
    t.region("sun", circle(500, 520, 300), "yellow")
    t.region("glasses", union(ellipse(380, 450, 120, 85), ellipse(620, 450, 120, 85),
                              band([(440, 430), (560, 430)], 30, smooth=False)), "black", label="Sunglasses")
    t.region("left_cheek", circle(320, 620, 40), "pink")
    t.region("right_cheek", circle(680, 620, 40), "pink")
    t.region("ice_cream", union(poly([(820, 800), (900, 800), (860, 960)], 10)), "orange", label="Ice cream cone")
    t.region("scoop", circle(860, 770, 55), "pink")
    t.smile(500, 610, 160, 60)
    t.dot(330, 420, 18, "#FFFFFF")
    t.dot(570, 420, 18, "#FFFFFF")
    return t


def mittens():
    t = Template("mittens", "Mittens", CAT)
    mitt = union(ellipse(300, 430, 160, 220), ellipse(170, 450, 55, 100, -30))
    t.region("left_mitten", mitt, "red")
    t.region("left_cuff", rect(150, 600, 300, 110, 30), "white", label="Left cuff")
    t.region("left_heart", union(circle(275, 400, 35), circle(325, 400, 35), poly([(242, 410), (358, 410), (300, 480)], 4)), "pink",
             label="Left heart")
    right = mirror(mitt)
    t.region("right_mitten", right, "blue")
    t.region("right_cuff", rect(550, 600, 300, 110, 30), "white", label="Right cuff")
    t.region("right_star", star(700, 420, 70), "yellow", label="Right star")
    t.region("string", band([(300, 710), (380, 850), (620, 850), (700, 710)], 20), "grey")
    for i, x in enumerate((180, 820)):
        t.region(f"snowflake_{i + 1}", star(x, 150, 50, 22, n=6), "skyblue", label=f"Snowflake {i + 1}")
    return t


def satellite():
    t = Template("satellite", "Satellite", CAT)
    t.region("left_panel", rect(60, 400, 280, 160, 14), "blue", label="Left solar panel")
    t.region("right_panel", rect(660, 400, 280, 160, 14), "blue", label="Right solar panel")
    t.region("arms", rect(330, 460, 340, 40), "grey")
    t.region("body", rect(390, 360, 220, 240, 30), "yellow")
    t.region("dish", circle(500, 280, 90).intersection(halfplane_above(300)), "white")
    t.region("antenna", circle(500, 170, 26), "red")
    t.region("planet", circle(820, 830, 130), "orange")
    t.region("star", star(160, 180, 60), "yellow")
    t.line([(500, 200), (500, 260)], 9, smooth=False)
    for x in (150, 250, 750, 850):
        t.line([(x, 410), (x, 550)], 8, smooth=False)
    t.eyes(500, 460, 80, 18)
    t.smile(500, 510, 50, 18)
    return t


TEMPLATES = [
    snowflake,
    tornado,
    windsock,
    planet,
    comet,
    earth,
    raindrop,
    rain_boots,
    raincoat,
    thermometer,
    mountain,
    volcano,
    sunset,
    parachute,
    weather_vane,
    sun_cloud,
    snow_cloud,
    sunglasses,
    mittens,
    satellite,
]
