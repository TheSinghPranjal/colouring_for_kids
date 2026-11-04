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


def star_sky():
    t = Template("star_sky", "Star", CAT)
    t.region("body", star(500, 480, 280, 120, 5), "yellow")
    t.region("center", circle(500, 480, 80), "orange")
    t.region("shine_1", circle(320, 280, 35), "white")
    t.region("shine_2", circle(700, 300, 28), "white")
    t.region("shine_3", circle(280, 650, 30), "white")
    t.eyes(500, 460, 60, 14)
    t.smile(500, 510, 45, 16)
    return t


def lightning():
    t = Template("lightning", "Lightning", CAT)
    bolt = poly(
        [(420, 120), (580, 120), (500, 380), (620, 380), (380, 880), (480, 500), (360, 500)],
        18,
    )
    t.region("bolt", bolt, "yellow")
    t.region("cloud_l", circle(300, 200, 120), "grey")
    t.region("cloud_r", circle(700, 200, 120), "grey")
    t.region("cloud_m", circle(500, 160, 140), "grey")
    t.region("spark_1", star(700, 500, 50, 22, 4), "orange")
    t.region("spark_2", star(280, 600, 45, 20, 4), "orange")
    t.eyes(500, 300, 50, 12)
    t.smile(500, 350, 35, 12)
    return t


def umbrella():
    t = Template("umbrella", "Umbrella", CAT)
    t.region("canopy", ellipse(500, 400, 320, 180), "red")
    t.region("panel_l", ellipse(360, 400, 100, 120), "yellow")
    t.region("panel_r", ellipse(640, 400, 100, 120), "blue")
    t.region("pole", band([(500, 400), (500, 820)], 28), "grey")
    t.region("handle", band([(500, 820), (560, 880), (620, 860)], 32), "brown")
    t.region("tip", circle(500, 260, 35), "yellow")
    t.eyes(500, 380, 70, 14)
    t.smile(500, 430, 50, 16)
    return t


def hot_air_balloon():
    t = Template("hot_air_balloon", "Balloon", CAT)
    t.region("balloon", ellipse(500, 380, 220, 260), "red")
    t.region("stripe", rect(400, 300, 200, 80).intersection(ellipse(500, 380, 220, 260)), "yellow")
    t.region("basket", rect(440, 720, 120, 100, 16), "brown")
    t.region("rope_l", band([(420, 580), (460, 720)], 16), "brown")
    t.region("rope_r", band([(580, 580), (540, 720)], 16), "brown")
    t.region("flame", teardrop(500, 640, 35, 1.8, 180), "orange")
    t.eyes(500, 360, 80, 16)
    t.smile(500, 430, 55, 18)
    return t


def raincloud():
    t = Template("raincloud", "Rain Cloud", CAT)
    body = union(circle(340, 400, 130), circle(500, 340, 170), circle(660, 400, 130), rect(300, 420, 400, 120, 60))
    t.region("cloud", body, "grey")
    for i, x in enumerate((360, 460, 560, 660)):
        t.region(f"drop_{i + 1}", teardrop(x, 700 + (i % 2) * 40, 35), "skyblue", label=f"Drop {i + 1}")
    t.region("left_cheek", circle(400, 450, 30), "pink")
    t.region("right_cheek", circle(600, 450, 30), "pink")
    t.eyes(500, 400, 120, 20)
    t.smile(500, 470, 70, 24)
    return t


TEMPLATES = [sun, cloud, rainbow, moon, snowman, star_sky, lightning, umbrella, hot_air_balloon, raincloud]
