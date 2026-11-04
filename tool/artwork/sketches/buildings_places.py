import math

from lib import Template, band, circle, ellipse, poly, rect, union

CAT = "buildings_places"


def arch(x, y, w, h):
    """Door / window shape with a round top."""
    return union(rect(x, y, w, h, w / 2), rect(x, y + w / 2, w, h - w / 2))


def house():
    t = Template("house", "House", CAT)
    t.region("path", poly([(445, 820), (555, 820), (650, 960), (350, 960)], 10), "grey")
    t.region("chimney", rect(630, 200, 90, 200, 12), "red")
    t.region("walls", rect(215, 450, 570, 375), "yellow")
    t.region("roof", poly([(160, 480), (500, 175), (840, 480)], 26), "red")
    t.region("attic_window", circle(500, 360, 48), "skyblue", label="Round window")
    t.region("door", arch(440, 615, 120, 210), "blue")
    for i, x in enumerate((265, 615)):
        t.region(f"window_{i + 1}", rect(x, 520, 125, 115, 14), "skyblue", label=f"Window {i + 1}")
        t.line([(x + 62, 525), (x + 62, 630)], 9, smooth=False)
        t.line([(x + 5, 577), (x + 120, 577)], 9, smooth=False)
    t.dot(532, 730, 12)
    return t


def school():
    t = Template("school", "School", CAT)
    t.line([(500, 50), (500, 170)], 12, smooth=False)
    t.region("flag", poly([(508, 55), (630, 90), (508, 125)], 10), "red")
    t.region("tower", union(rect(430, 160, 140, 140, 10)), "orange", label="Bell tower")
    t.region("building", rect(150, 420, 700, 420), "orange")
    t.region("roof", poly([(115, 445), (500, 230), (885, 445)], 24), "red")
    t.region("clock", circle(500, 360, 56), "white")
    t.line([(500, 360), (500, 325)], 9, smooth=False)
    t.line([(500, 360), (528, 372)], 9, smooth=False)
    t.region("door", rect(425, 650, 150, 190, 22), "blue")
    t.line([(500, 655), (500, 835)], 9, smooth=False)
    for i, (x, y) in enumerate([(200, 480), (670, 480), (200, 660), (670, 660)]):
        t.region(f"window_{i + 1}", rect(x, y, 130, 115, 16), "skyblue", label=f"Window {i + 1}")
    t.region("steps", rect(390, 840, 220, 50, 14), "grey")
    return t


def castle():
    t = Template("castle", "Castle", CAT)
    t.region("flag", poly([(508, 40), (600, 68), (508, 98)], 10), "red")
    t.line([(500, 40), (500, 130)], 10, smooth=False)
    t.region("wall", union(rect(290, 500, 420, 330), *[rect(305 + i * 80, 465, 50, 50, 8) for i in range(5)]), "grey")
    t.region("left_tower", rect(150, 390, 160, 440), "grey")
    t.region("right_tower", rect(690, 390, 160, 440), "grey")
    t.region("main_tower", rect(375, 300, 250, 530), "grey")
    t.region("left_roof", poly([(125, 400), (230, 190), (335, 400)], 18), "purple")
    t.region("right_roof", poly([(665, 400), (770, 190), (875, 400)], 18), "purple")
    t.region("main_roof", poly([(355, 310), (500, 110), (645, 310)], 18), "blue")
    t.region("gate", arch(430, 640, 140, 190), "brown")
    t.region("main_window", arch(465, 410, 70, 110), "yellow", label="Tower window")
    t.region("left_window", arch(200, 520, 60, 95), "yellow")
    t.region("right_window", arch(740, 520, 60, 95), "yellow")
    t.line([(470, 700), (470, 830)], 8, smooth=False)
    t.line([(530, 700), (530, 830)], 8, smooth=False)
    return t


def shop():
    t = Template("shop", "Shop", CAT)
    t.region("sign", rect(255, 175, 490, 120, 34), "yellow", label="Sign")
    t.line([(330, 295), (330, 330)], 10, smooth=False)
    t.line([(670, 295), (670, 330)], 10, smooth=False)
    t.region("walls", rect(150, 330, 700, 520), "peach")
    awning = union(rect(120, 320, 760, 110, 16), *[circle(165 + i * 95, 430, 47.5) for i in range(8)])
    stripes_a = union(*[rect(118 + i * 190, 300, 95, 200) for i in range(4)]).intersection(awning)
    stripes_b = awning.difference(stripes_a)
    t.region("awning_stripes_1", stripes_a, "red", label="Awning stripes")
    t.region("awning_stripes_2", stripes_b, "white", label="Other awning stripes")
    t.region("display_window", rect(215, 530, 310, 220, 22), "skyblue", label="Shop window")
    t.region("flower_box", rect(200, 760, 340, 60, 22), "green")
    t.region("door", rect(600, 520, 170, 330, 22), "blue")
    t.region("door_window", rect(630, 555, 110, 110, 16), "skyblue", label="Door window")
    t.dot(750, 720, 12)
    return t


def windmill():
    t = Template("windmill", "Windmill", CAT)
    t.region("hill", ellipse(500, 990, 520, 130).intersection(rect(0, 0, 1000, 960)), "lightgreen")
    t.region("tower", poly([(375, 890), (420, 420), (580, 420), (625, 890)], 20), "white")
    t.region("roof", poly([(370, 450), (500, 290), (630, 450)], 24), "red")
    t.region("door", arch(458, 760, 84, 130), "brown")
    t.region("top_window", circle(500, 545, 36), "skyblue")
    t.region("bottom_window", arch(475, 615, 50, 75), "skyblue")
    hub = (500, 340)
    for i, a in enumerate((-135, -45, 45, 135)):
        r = math.radians(a)
        from shapely import affinity

        blade = rect(85, -46, 265, 92, 18)
        blade = affinity.rotate(blade, a, origin=(0, 0))
        blade = affinity.translate(blade, *hub)
        t.region(f"blade_{i + 1}", blade, "yellow", label=f"Blade {i + 1}")
        for k in (0.45, 0.75):
            cx, cy = hub[0] + 340 * k * math.cos(r), hub[1] + 340 * k * math.sin(r)
            nx, ny = -math.sin(r) * 42, math.cos(r) * 42
            t.line([(cx - nx, cy - ny), (cx + nx, cy + ny)], 8, smooth=False)
    t.region("hub", circle(*hub, 48), "orange")
    return t


def barn():
    t = Template("barn", "Barn", CAT)
    t.region("wall", rect(200, 420, 600, 420, 20), "red")
    t.region("roof", poly([(160, 420), (500, 200), (840, 420)], 16), "brown")
    t.region("door", rect(400, 560, 200, 280, 16), "brown")
    t.region("window_l", rect(250, 500, 100, 80, 12), "skyblue")
    t.region("window_r", rect(650, 500, 100, 80, 12), "skyblue")
    t.region("hay", ellipse(500, 700, 60, 40), "yellow")
    t.region("ground", ellipse(500, 900, 400, 50), "lightgreen")
    return t


def lighthouse():
    t = Template("lighthouse", "Lighthouse", CAT)
    t.region("tower", poly([(380, 860), (420, 280), (580, 280), (620, 860)], 16), "white")
    t.region("stripe", poly([(395, 520), (410, 400), (590, 400), (605, 520)], 10), "red")
    t.region("lantern", rect(400, 180, 200, 120, 16), "yellow")
    t.region("roof", poly([(370, 180), (500, 80), (630, 180)], 12), "red")
    t.region("door", rect(450, 700, 100, 160, 12), "brown")
    t.region("rock", ellipse(500, 900, 320, 60), "grey")
    t.region("beam", poly([(600, 220), (900, 160), (900, 280), (600, 260)], 10), "yellow")
    return t


def igloo():
    t = Template("igloo", "Igloo", CAT)
    t.region("dome", ellipse(500, 560, 300, 260), "white")
    t.region("entrance", ellipse(500, 720, 100, 80), "skyblue")
    t.region("block_1", rect(280, 500, 120, 60, 10), "skyblue")
    t.region("block_2", rect(450, 420, 120, 60, 10), "skyblue")
    t.region("block_3", rect(600, 500, 120, 60, 10), "skyblue")
    t.region("snow", ellipse(500, 880, 400, 50), "white")
    t.region("flag_pole", band([(500, 300), (500, 160)], 28), "grey")
    t.region("flag_cloth", poly([(500, 160), (620, 200), (500, 260)], 14), "red")
    return t


def tent():
    t = Template("tent", "Tent", CAT)
    t.region("left", poly([(200, 820), (500, 220), (500, 820)], 16), "red")
    t.region("right", poly([(500, 220), (800, 820), (500, 820)], 16), "yellow")
    t.region("door", poly([(430, 820), (500, 520), (570, 820)], 12), "brown")
    t.region("pole", band([(500, 220), (500, 120)], 36), "grey")
    t.region("flag", poly([(500, 120), (600, 160), (500, 220)], 12), "blue")
    t.region("ground", ellipse(500, 880, 380, 45), "lightgreen")
    return t


def bridge():
    t = Template("bridge", "Bridge", CAT)
    t.region("deck", rect(100, 520, 800, 80, 16), "brown")
    t.region("arch", ellipse(500, 600, 280, 160).intersection(rect(220, 520, 560, 200)), "grey")
    t.region("left_tower", rect(140, 300, 80, 300, 12), "grey")
    t.region("right_tower", rect(780, 300, 80, 300, 12), "grey")
    t.region("cable_l", band([(180, 320), (400, 520)], 18), "black")
    t.region("cable_r", band([(820, 320), (600, 520)], 18), "black")
    t.region("water", rect(100, 780, 800, 120, 30), "skyblue")
    return t


TEMPLATES = [house, school, castle, shop, windmill, barn, lighthouse, igloo, tent, bridge]
