"""Twenty more Buildings & Places sketches (11-30)."""

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
    poly,
    rect,
    star,
    union,
)

CAT = "buildings_places"


def _windows(t, xs, ys, w=100, h=100, colour="skyblue", start=1):
    k = start
    for y in ys:
        for x in xs:
            t.region(f"window_{k}", rect(x, y, w, h, 14), colour, label=f"Window {k}")
            k += 1
    return k


def hospital():
    t = Template("hospital", "Hospital", CAT)
    t.region("building", rect(150, 250, 700, 640, 20), "white")
    t.region("sign", rect(390, 150, 220, 130, 20), "white", label="Sign")
    t.region("cross", union(rect(475, 165, 50, 100, 6), rect(450, 190, 100, 50, 6)), "red")
    _windows(t, (200, 380, 620, 740), (330, 500), 80, 100)
    t.region("door", rect(420, 700, 160, 190, 16), "skyblue")
    t.region("roof_stripe", rect(150, 250, 700, 40), "red", label="Roof stripe")
    t.region("ground", rect(60, 880, 880, 50, 20), "lightgreen", label="Grass")
    return t


def fire_station():
    t = Template("fire_station", "Fire Station", CAT)
    t.region("tower", rect(660, 150, 180, 300, 16), "red")
    t.region("bell", union(circle(750, 260, 50).intersection(halfplane_above(270)), rect(700, 260, 100, 20)), "yellow")
    t.region("building", rect(140, 380, 720, 500, 20), "red")
    t.region("roof", rect(110, 340, 780, 70, 24), "grey")
    t.region("door_1", rect(200, 560, 260, 320, 20), "white", label="Garage door 1")
    t.region("door_2", rect(540, 560, 260, 320, 20), "white", label="Garage door 2")
    t.region("sign", rect(300, 430, 400, 90, 20), "yellow")
    t.region("window", rect(700, 190, 100, 50, 10), "skyblue")
    for x in (200, 540):
        for y in (640, 720, 800):
            t.line([(x + 20, y), (x + 240, y)], 8, smooth=False)
    return t


def skyscraper():
    t = Template("skyscraper", "Skyscraper", CAT)
    t.region("antenna", rect(485, 40, 30, 120), "grey")
    t.region("top", rect(400, 140, 200, 120, 14), "blue")
    t.region("tower", rect(320, 240, 360, 680, 20), "skyblue")
    t.region("left_building", rect(100, 500, 200, 420, 16), "purple", label="Small building")
    t.region("right_building", rect(700, 420, 200, 500, 16), "orange", label="Side building")
    for i, y in enumerate((300, 440, 580, 720)):
        t.region(f"window_row_{i + 1}", rect(360, y, 280, 80, 12), "yellow", label=f"Window row {i + 1}")
    t.region("door", rect(450, 820, 100, 100, 14), "blue")
    t.region("moon", circle(150, 180, 80).difference(circle(190, 160, 70)), "yellow")
    for x in range(400, 640, 70):
        for y in (300, 440, 580, 720):
            t.line([(x + 30, y), (x + 30, y + 80)], 7, smooth=False)
    return t


def apartment():
    t = Template("apartment", "Apartment", CAT)
    t.region("building", rect(200, 160, 600, 740, 20), "peach")
    t.region("roof", rect(170, 120, 660, 70, 24), "brown")
    k = _windows(t, (260, 450, 640), (240, 420, 600), 100, 110)
    t.region("door", rect(420, 750, 160, 150, 16).union(circle(500, 750, 80).intersection(halfplane_above(760))), "red")
    t.region("plant", union(circle(280, 800, 50), circle(330, 780, 40)), "green")
    t.region("pot", rect(260, 830, 90, 70, 10), "orange")
    return t


def cottage():
    t = Template("cottage", "Cottage", CAT)
    t.region("chimney", rect(620, 170, 80, 160, 10), "red")
    t.region("smoke", union(circle(680, 120, 40), circle(730, 80, 34)), "white")
    t.region("roof", poly([(140, 470), (300, 200), (700, 200), (860, 470)], 40), "orange", label="Thatched roof")
    t.region("walls", rect(200, 440, 600, 420, 16), "yellow")
    t.region("door", rect(430, 620, 140, 240, 70).intersection(halfplane_above(860)), "brown")
    t.region("left_window", circle(300, 600, 70), "skyblue", label="Left window")
    t.region("right_window", circle(700, 600, 70), "skyblue", label="Right window")
    t.region("left_flowers", union(*[circle(250 + 40 * k, 820, 30) for k in range(4)]), "pink", label="Flowers")
    t.region("right_flowers", union(*[circle(630 + 40 * k, 820, 30) for k in range(4)]), "red", label="More flowers")
    t.dot(545, 740, 12)
    return t


def treehouse():
    t = Template("treehouse", "Treehouse", CAT)
    t.region("trunk", union(rect(440, 450, 120, 480, 20), poly([(380, 930), (440, 860), (560, 860), (620, 930)], 10)), "brown")
    t.region("leaves", union(circle(300, 250, 170), circle(500, 180, 190), circle(700, 250, 170), circle(500, 330, 160)), "green")
    t.region("house", rect(300, 380, 400, 230, 16), "orange")
    t.region("roof", poly([(260, 400), (500, 250), (740, 400)], 24), "red")
    t.region("window", rect(360, 440, 110, 100, 14), "skyblue")
    t.region("door", rect(540, 450, 100, 160, 14), "brown")
    t.region("platform", rect(260, 600, 480, 40, 14), "brown")
    t.region("ladder", union(rect(640, 640, 20, 300), rect(740, 640, 20, 300), *[rect(640, 680 + 60 * k, 120, 18) for k in range(4)]),
             "yellow")
    return t


def pyramid():
    t = Template("pyramid", "Pyramid", CAT)
    t.region("sun", circle(820, 180, 90), "yellow")
    t.region("sand", rect(0, 780, 1000, 220), "yellow")
    t.region("big_pyramid", poly([(150, 820), (480, 280), (810, 820)], 10), "orange", label="Big pyramid")
    t.region("shadow_side", poly([(480, 280), (810, 820), (600, 820)], 10), "brown", label="Shady side")
    t.region("small_pyramid", poly([(620, 840), (800, 560), (980, 840)], 10), "orange", label="Small pyramid")
    t.region("door", rect(440, 700, 80, 120, 30).intersection(halfplane_above(820)), "black")
    t.region("camel", union(ellipse(200, 880, 80, 40), circle(200, 830, 40), band([(270, 870), (300, 800)], 24),
                            ellipse(310, 790, 30, 20)), "peach", label="Camel")
    for y in (450, 600, 720):
        t.line([(480 - (y - 280) * 0.61, y), (480 + (y - 280) * 0.22, y)], 8, smooth=False)
    return t


def library():
    t = Template("library", "Library", CAT)
    t.region("roof", poly([(120, 330), (500, 140), (880, 330)], 20), "red")
    t.region("building", rect(160, 320, 680, 500, 10), "white")
    for i, x in enumerate((210, 330, 610, 730)):
        t.region(f"column_{i + 1}", rect(x, 360, 60, 420, 10), "grey", label=f"Column {i + 1}")
    t.region("door", rect(420, 560, 160, 260, 80).intersection(halfplane_above(820)), "brown")
    t.region("steps", rect(120, 820, 760, 80, 10), "grey")
    t.region("book", poly([(400, 400), (500, 430), (600, 400), (600, 500), (500, 530), (400, 500)], 8), "blue", label="Book sign")
    t.line([(500, 430), (500, 530)], 8, smooth=False)
    return t


def bakery():
    t = Template("bakery", "Bakery", CAT)
    t.region("building", rect(150, 300, 700, 600, 20), "peach")
    t.region("awning", union(*[rect(150 + 100 * k, 300, 100, 120) for k in range(0, 7, 2)]), "pink")
    t.region("awning_2", union(*[rect(250 + 100 * k, 300, 100, 120) for k in range(0, 6, 2)]), "white", label="Awning stripes")
    t.region("scallops", union(*[circle(200 + 100 * k, 420, 50) for k in range(7)]).intersection(halfplane_below(420)), "pink")
    t.region("sign", rect(330, 180, 340, 100, 30), "brown")
    t.region("window", rect(200, 520, 350, 260, 20), "skyblue")
    t.region("cake", union(rect(260, 650, 120, 90, 10), rect(280, 600, 80, 60, 10)), "pink")
    t.region("bread", ellipse(470, 700, 60, 40), "orange")
    t.region("door", rect(620, 520, 170, 380, 20), "brown")
    t.dot(650, 720, 12)
    return t


def cafe():
    t = Template("cafe", "Cafe", CAT)
    t.region("umbrella", union(ellipse(500, 300, 340, 140).intersection(halfplane_above(320))), "red")
    t.region("umbrella_stripe", band([(500, 160), (500, 330)], 80, smooth=False).intersection(
        ellipse(500, 300, 340, 140).intersection(halfplane_above(320))), "white", label="Umbrella stripe")
    t.region("pole", rect(485, 320, 30, 380), "grey")
    t.region("table", rect(300, 640, 400, 50, 20), "brown")
    t.region("table_leg", rect(470, 690, 60, 200), "brown", label="Table leg")
    t.region("left_chair", union(rect(130, 500, 40, 380, 10), rect(130, 700, 180, 40, 10)), "orange")
    t.region("right_chair", union(rect(830, 500, 40, 380, 10), rect(690, 700, 180, 40, 10)), "orange")
    t.region("cup", union(rect(350, 560, 80, 80, 14), annulus(440, 600, 30, 14).intersection(rect(430, 560, 50, 80))), "white")
    t.region("cake", union(poly([(560, 640), (660, 640), (660, 580)], 6)), "pink")
    t.line([(370, 540), (380, 500), (370, 470)], 8)
    t.line([(410, 540), (420, 500), (410, 470)], 8)
    return t


def wishing_well():
    t = Template("wishing_well", "Wishing Well", CAT)
    t.region("roof", poly([(220, 330), (500, 140), (780, 330)], 24), "red")
    t.region("left_post", rect(250, 320, 50, 380), "brown", label="Left post")
    t.region("right_post", rect(700, 320, 50, 380), "brown", label="Right post")
    t.region("rope", rect(490, 330, 20, 200), "brown")
    t.region("bucket", poly([(430, 520), (570, 520), (550, 640), (450, 640)], 14), "grey")
    t.region("water", ellipse(500, 640, 260, 50), "blue")
    t.region("well", union(rect(220, 640, 560, 260, 20)), "grey")
    for i, (x, y) in enumerate([(220, 700), (400, 700), (580, 700), (310, 790), (490, 790)]):
        t.region(f"stone_{i + 1}", rect(x + 10, y, 160, 70, 18).intersection(rect(220, 640, 560, 260, 20)), "white",
                 label=f"Stone {i + 1}")
    return t


def fountain():
    t = Template("fountain", "Fountain", CAT)
    t.region("spray", union(*[band([(500, 450), (500 + 160 * s, 200), (500 + 260 * s, 380)], 40) for s in (-1, 1)],
                            band([(500, 450), (500, 140)], 50)), "skyblue")
    t.region("top_bowl", ellipse(500, 460, 160, 50), "white")
    t.region("stem", rect(460, 460, 80, 230, 10), "grey")
    t.region("water", ellipse(500, 700, 380, 80), "blue")
    t.region("base", union(rect(120, 700, 760, 160, 30)), "grey")
    t.region("base_band", rect(120, 760, 760, 50).intersection(rect(120, 700, 760, 160, 30)), "white", label="Base stripe")
    for i, x in enumerate((230, 770)):
        t.region(f"drop_{i + 1}", ellipse(x, 500, 30, 44), "skyblue", label=f"Drop {i + 1}")
    t.region("bird", union(ellipse(780, 650, 50, 34), circle(820, 620, 26)), "yellow")
    t.dot(828, 615, 6)
    return t


def gazebo():
    t = Template("gazebo", "Gazebo", CAT)
    t.region("finial", circle(500, 140, 34), "yellow")
    t.region("roof", union(poly([(160, 400), (500, 160), (840, 400)], 30)), "red")
    t.region("roof_edge", union(*[circle(200 + 75 * k, 410, 38) for k in range(9)]).intersection(halfplane_below(400)), "white")
    for i, x in enumerate((210, 380, 580, 750)):
        t.region(f"post_{i + 1}", rect(x, 420, 40, 380), "white", label=f"Post {i + 1}")
    t.region("rail", rect(200, 640, 600, 30, 10), "white")
    t.region("floor", rect(140, 790, 720, 70, 20), "brown")
    t.region("steps", rect(380, 860, 240, 60, 14), "grey")
    t.region("bush_left", union(circle(120, 840, 70), circle(60, 870, 50)), "green", label="Left bush")
    t.region("bush_right", union(circle(880, 840, 70), circle(940, 870, 50)), "green", label="Right bush")
    return t


def log_cabin():
    t = Template("log_cabin", "Log Cabin", CAT)
    t.region("chimney", rect(660, 160, 90, 180, 10), "grey")
    t.region("roof", poly([(100, 450), (500, 180), (900, 450)], 30), "green")
    for i in range(5):
        t.region(f"log_{i + 1}", rect(160, 450 + 85 * i, 680, 85, 42), ["brown", "orange"][i % 2], label=f"Log {i + 1}")
    t.region("door", rect(430, 610, 140, 260, 14), "red")
    t.region("window", rect(220, 540, 140, 120, 14), "yellow")
    t.region("snow", union(*[circle(150 + 100 * k, 860, 60) for k in range(8)]).intersection(halfplane_above(930)), "white")
    t.dot(545, 740, 12)
    return t


def clock_tower():
    t = Template("clock_tower", "Clock Tower", CAT)
    t.region("spire", poly([(370, 260), (500, 60), (630, 260)], 16), "blue")
    t.region("tower", rect(340, 240, 320, 680, 16), "peach")
    t.region("clock", circle(500, 400, 120), "white")
    t.region("bell_arch", rect(420, 580, 160, 180, 80).intersection(halfplane_above(760)), "skyblue", label="Bell window")
    t.region("bell", union(circle(500, 680, 50).intersection(halfplane_above(700)), rect(450, 690, 100, 20, 8)), "yellow")
    t.region("door", rect(440, 820, 120, 100, 50).intersection(halfplane_above(920)), "brown")
    t.region("ledge", rect(310, 540, 380, 40, 14), "grey")
    t.line([(500, 400), (500, 320)], 12, smooth=False)
    t.line([(500, 400), (570, 430)], 12, smooth=False)
    for k in range(12):
        a = math.radians(k * 30)
        t.dot(500 + 95 * math.cos(a), 400 + 95 * math.sin(a), 8)
    return t


def hut():
    t = Template("hut", "Hut", CAT)
    t.region("sun", circle(160, 160, 80), "yellow")
    t.region("palm_leaf", union(lens((820, 300), 200, 220, 70), lens((820, 300), 160, 200, 70), lens((820, 300), -30, 160, 60)),
             "green")
    t.region("palm_trunk", band([(860, 880), (840, 600), (820, 310)], 40), "brown")
    t.region("roof", poly([(140, 520), (450, 220), (760, 520)], 30), "yellow", label="Straw roof")
    t.region("walls", rect(200, 500, 500, 340, 16), "orange")
    t.region("door", rect(390, 620, 120, 220, 16), "brown")
    t.region("window", circle(290, 620, 50), "skyblue")
    t.region("sand", ellipse(500, 900, 470, 70), "peach")
    for x in range(200, 720, 60):
        t.line([(x, 520), (x - 30, 480)], 7, smooth=False)
    return t


def playground_slide():
    t = Template("playground_slide", "Slide", CAT)
    t.region("ladder", union(rect(220, 260, 30, 640), rect(340, 260, 30, 640), *[rect(220, 340 + 110 * k, 150, 24) for k in range(5)]),
             "blue")
    t.region("platform", rect(200, 240, 300, 50, 16), "yellow")
    t.region("roof", poly([(180, 160), (350, 60), (520, 160)], 16), "red")
    t.region("roof_pole", rect(470, 160, 24, 90), "grey", label="Roof pole")
    t.region("slide", poly([(440, 260), (520, 260), (920, 800), (920, 880), (840, 880)], 30), "orange")
    t.region("sand", ellipse(780, 920, 220, 50), "yellow")
    t.region("ball", circle(130, 860, 60), "red")
    return t


def swing_set():
    t = Template("swing_set", "Swing Set", CAT)
    t.region("top_bar", rect(120, 160, 760, 50, 24), "red")
    t.region("left_legs", union(band([(150, 190), (60, 900)], 40, smooth=False), band([(150, 190), (240, 900)], 40, smooth=False)),
             "blue")
    t.region("right_legs", union(band([(850, 190), (760, 900)], 40, smooth=False), band([(850, 190), (940, 900)], 40, smooth=False)),
             "blue")
    for i, x in enumerate((360, 620)):
        t.line([(x - 60, 210), (x - 60, 620)], 9, smooth=False)
        t.line([(x + 60, 210), (x + 60, 620)], 9, smooth=False)
        t.region(f"seat_{i + 1}", rect(x - 90, 620, 180, 40, 16), ["yellow", "green"][i], label=f"Seat {i + 1}")
    t.region("grass", rect(0, 880, 1000, 120), "lightgreen")
    t.region("teddy", union(circle(360, 560, 50), ellipse(360, 610, 50, 30), circle(320, 520, 20), circle(400, 520, 20)), "brown",
             label="Teddy")
    t.dot(345, 555, 7)
    t.dot(375, 555, 7)
    return t


def carousel():
    t = Template("carousel", "Carousel", CAT)
    t.region("flag", poly([(500, 60), (590, 90), (500, 120)], 6), "red")
    t.region("top", poly([(160, 320), (500, 120), (840, 320)], 30), "pink", label="Roof")
    t.region("trim", union(*[circle(200 + 75 * k, 330, 38) for k in range(9)]).intersection(halfplane_below(320)), "yellow")
    for i, x in enumerate((250, 750)):
        t.region(f"pole_{i + 1}", rect(x - 14, 360, 28, 420), "yellow", label=f"Pole {i + 1}")
    for i, x in enumerate((250, 750)):
        horse = union(ellipse(x, 560, 90, 50), circle(x + 70 * (1 if i else -1), 500, 40),
                      rect(x - 60, 590, 24, 80, 10), rect(x + 36, 590, 24, 80, 10))
        t.region(f"horse_{i + 1}", horse, "white", label=f"Horse {i + 1}")
    t.region("base", ellipse(500, 800, 380, 70), "purple")
    t.region("base_front", rect(120, 800, 760, 80, 30), "blue", label="Base")
    t.region("center", rect(440, 380, 120, 380, 20), "skyblue", label="Middle")
    return t


def ferris_wheel():
    t = Template("ferris_wheel", "Ferris Wheel", CAT)
    t.region("legs", union(band([(500, 450), (300, 900)], 40, smooth=False), band([(500, 450), (700, 900)], 40, smooth=False)),
             "grey")
    t.region("wheel", annulus(500, 450, 330, 290), "red")
    for k in range(8):
        a = math.radians(k * 45)
        t.line([(500, 450), (500 + 290 * math.cos(a), 450 + 290 * math.sin(a))], 9, smooth=False)
    t.region("hub", circle(500, 450, 50), "yellow")
    colours = ["blue", "yellow", "green", "purple", "orange", "pink"]
    for k in range(6):
        a = math.radians(-90 + k * 60)
        x, y = 500 + 310 * math.cos(a), 450 + 310 * math.sin(a)
        t.region(f"cabin_{k + 1}", rect(x - 50, y, 100, 80, 20), colours[k], label=f"Cabin {k + 1}")
    t.region("ground", rect(150, 890, 700, 50, 20), "lightgreen", label="Grass")
    return t


TEMPLATES = [
    hospital,
    fire_station,
    skyscraper,
    apartment,
    cottage,
    treehouse,
    pyramid,
    library,
    bakery,
    cafe,
    wishing_well,
    fountain,
    gazebo,
    log_cabin,
    clock_tower,
    hut,
    playground_slide,
    swing_set,
    carousel,
    ferris_wheel,
]
