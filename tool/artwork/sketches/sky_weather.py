import math

from lib import Template, annulus, band, circle, ellipse, halfplane_above, mirror, poly, rect, star, teardrop, union

CAT = "sky_weather"


def sun():
    t = Template("sun", "Sun", CAT)
    c = (500, 500)
    for i in range(8):
        a = math.radians(-90 + i * 45)
        perp = a + math.pi / 2
        base_r, tip_r, half = 200, 430, 70
        pts = [
            (c[0] + base_r * math.cos(a) + half * math.cos(perp), c[1] + base_r * math.sin(a) + half * math.sin(perp)),
            (c[0] + tip_r * math.cos(a), c[1] + tip_r * math.sin(a)),
            (c[0] + base_r * math.cos(a) - half * math.cos(perp), c[1] + base_r * math.sin(a) - half * math.sin(perp)),
        ]
        t.region(f"ray_{i + 1}", poly(pts, 18), ["orange", "yellow"][i % 2], label=f"Ray {i + 1}")
    t.region("center", circle(*c, 240), "yellow", label="Sun face")
    t.region("left_cheek", circle(390, 565, 42), "pink")
    t.region("right_cheek", circle(610, 565, 42), "pink")
    t.eyes(500, 470, 150, 26)
    t.smile(500, 560, 130, 52)
    return t


def cloud():
    t = Template("cloud", "Cloud", CAT)
    for i, x in enumerate((340, 500, 660)):
        t.region(f"raindrop_{i + 1}", teardrop(x, 860 - (i % 2) * 40, 42), "skyblue", label=f"Raindrop {i + 1}")
    body = union(
        circle(310, 520, 150),
        circle(470, 420, 200),
        circle(680, 480, 165),
        circle(780, 590, 110),
        circle(220, 610, 100),
        rect(220, 560, 560, 150, 75),
    )
    t.region("cloud", body, "white")
    t.region("left_cheek", circle(380, 590, 36), "pink")
    t.region("right_cheek", circle(620, 590, 36), "pink")
    t.eyes(500, 520, 160, 24)
    t.smile(500, 590, 90, 34)
    return t


def rainbow():
    t = Template("rainbow", "Rainbow", CAT)
    colours = ["red", "orange", "yellow", "green", "blue", "purple"]
    for i in range(6):
        r_out = 450 - i * 52
        arc = annulus(500, 720, r_out, r_out - 52).intersection(halfplane_above(720))
        t.region(f"band_{i + 1}", arc, colours[i], label=f"Rainbow band {i + 1}")
    left = union(circle(140, 700, 80), circle(230, 650, 95), circle(320, 710, 75), rect(70, 690, 320, 100, 50))
    t.region("left_cloud", left, "white")
    t.region("right_cloud", mirror(left), "white")
    return t


def moon():
    t = Template("moon", "Moon", CAT)
    crescent = circle(430, 470, 300).difference(circle(590, 380, 255))
    t.region("moon", crescent, "yellow")
    t.region("star_1", star(810, 520, 88), "yellow", label="Big star")
    t.region("star_2", star(790, 200, 70, rot=-80), "yellow", label="Star")
    t.region("star_3", star(860, 800, 62, rot=-100), "yellow", label="Little star")
    t.region("cloud", union(circle(260, 830, 70), circle(350, 790, 85), circle(440, 840, 62), rect(200, 810, 300, 85, 42)), "white")
    t.sleepy_eye(230, 470, 60)
    t.smile(270, 570, 50, 18)
    t.region("cheek", circle(195, 545, 30), "pink")
    return t


def snowman():
    t = Template("snowman", "Snowman", CAT)
    t.region("snow", ellipse(500, 925, 430, 55), "white", label="Snowy ground")
    arm = union(band([(370, 470), (250, 380)], 22, smooth=False), band([(290, 410), (260, 340)], 18, smooth=False))
    t.region("left_arm", arm, "brown")
    t.region("right_arm", mirror(arm), "brown")
    t.region("bottom", circle(500, 735, 195), "white", label="Big snowball")
    t.region("middle", circle(500, 475, 140), "white", label="Middle snowball")
    t.region("head", circle(500, 270, 112), "white")
    t.region("hat", union(rect(375, 165, 250, 40, 18), rect(420, 45, 160, 150, 14)), "black")
    t.region("hat_band", rect(420, 130, 160, 40), "red", label="Hat band")
    scarf = union(band([(395, 375), (500, 395), (605, 375)], 52), band([(560, 395), (590, 520)], 56))
    t.region("scarf", scarf, "red")
    t.region("nose", poly([(505, 268), (625, 300), (505, 328)], 12), "orange", label="Carrot nose")
    for i, y in enumerate((470, 545, 700)):
        t.region(f"button_{i + 1}", circle(500, y, 28), "black", label=f"Button {i + 1}")
    t.eyes(500, 245, 90, 18)
    for k in range(5):
        a = math.radians(30 + k * 30)
        t.dot(500 + 60 * math.cos(a) - 10, 300 + 32 * math.sin(a), 7)
    return t


TEMPLATES = [sun, cloud, rainbow, moon, snowman]
