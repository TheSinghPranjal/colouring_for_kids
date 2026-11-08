"""Twenty more Vehicles sketches (11-30)."""

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
    poly,
    rect,
    star,
    union,
)

CAT = "vehicles"


def _wheel(t, name, x, y, r, label):
    t.region(name, circle(x, y, r), "black", label=label)
    t.region(f"{name}_hub", circle(x, y, r * 0.42), "grey", label=f"{label} middle")


def _wheels(t, xs, y=720, r=90):
    names = ["back_wheel", "front_wheel", "middle_wheel"]
    for i, x in enumerate(xs):
        label = names[i].replace("_", " ").capitalize()
        _wheel(t, names[i], x, y, r, label)


def fire_truck():
    t = Template("fire_truck", "Fire Truck", CAT)
    t.region("ladder", union(rect(120, 270, 520, 40, 14), *[rect(150 + 70 * k, 250, 24, 80, 8) for k in range(7)]), "grey")
    t.region("body", rect(60, 350, 620, 330, 30), "red")
    t.region("cab", union(rect(640, 300, 280, 380, 40)), "red")
    t.region("window", rect(700, 350, 170, 140, 20), "skyblue")
    t.region("light", union(rect(720, 250, 120, 60, 20)), "blue", label="Siren")
    t.region("stripe", rect(60, 540, 860, 50).intersection(union(rect(60, 350, 620, 330, 30), rect(640, 300, 280, 380, 40))),
             "white")
    t.region("hose", circle(300, 450, 70), "yellow", label="Hose reel")
    _wheels(t, (230, 760))
    return t


def police_car():
    t = Template("police_car", "Police Car", CAT)
    t.region("siren", union(rect(440, 220, 60, 60, 16)), "red")
    t.region("siren_2", rect(500, 220, 60, 60, 16), "blue", label="Blue siren")
    t.region("roof", poly([(270, 500), (370, 290), (640, 290), (750, 500)], 34), "white")
    body = rect(110, 470, 790, 210, 70)
    t.region("body", body, "white")
    t.region("bottom", rect(110, 590, 790, 90).intersection(body), "darkblue", label="Bottom stripe")
    t.region("back_window", poly([(320, 470), (395, 330), (490, 330), (490, 470)], 16), "skyblue")
    t.region("front_window", poly([(525, 470), (525, 330), (615, 330), (700, 470)], 16), "skyblue")
    t.region("badge", star(500, 540, 45, r=4), "yellow")
    t.region("headlight", ellipse(860, 530, 32, 30).intersection(body.buffer(-8)), "yellow")
    _wheels(t, (300, 710), 700, 95)
    return t


def ambulance():
    t = Template("ambulance", "Ambulance", CAT)
    t.region("light", rect(340, 200, 100, 60, 20), "red", label="Siren")
    t.region("body", rect(80, 250, 620, 450, 40), "white")
    t.region("cab", poly([(680, 350), (820, 350), (930, 500), (930, 700), (680, 700)], 30), "white")
    t.region("window", poly([(720, 390), (800, 390), (880, 500), (720, 500)], 14), "skyblue")
    t.region("stripe", rect(80, 560, 850, 50).intersection(
        union(rect(80, 250, 620, 450, 40), poly([(680, 350), (820, 350), (930, 500), (930, 700), (680, 700)], 30))), "red")
    t.region("cross", union(rect(330, 330, 60, 180, 8), rect(270, 390, 180, 60, 8)), "red")
    _wheels(t, (240, 780))
    return t


def taxi():
    t = Template("taxi", "Taxi", CAT)
    t.region("sign", rect(430, 220, 140, 70, 20), "white", label="Taxi sign")
    t.region("roof", poly([(270, 500), (370, 290), (640, 290), (750, 500)], 34), "yellow")
    body = rect(110, 470, 790, 210, 70)
    t.region("body", body, "yellow")
    t.region("back_window", poly([(320, 470), (395, 330), (490, 330), (490, 470)], 16), "skyblue")
    t.region("front_window", poly([(525, 470), (525, 330), (615, 330), (700, 470)], 16), "skyblue")
    checks = union(*[rect(130 + 80 * k, 520, 40, 40) for k in range(0, 10, 2)], *[rect(170 + 80 * k, 560, 40, 40)
                                                                               for k in range(0, 9, 2)])
    t.region("checks", checks.intersection(body), "black")
    t.region("headlight", ellipse(860, 530, 32, 30).intersection(body.buffer(-8)), "white")
    _wheels(t, (300, 710), 700, 95)
    return t


def digger():
    t = Template("digger", "Digger", CAT)
    t.region("tracks", rect(100, 650, 520, 170, 85), "black")
    for i, x in enumerate((190, 360, 530)):
        t.region(f"wheel_{i + 1}", circle(x, 735, 55), "grey", label=f"Track wheel {i + 1}")
    t.region("base", rect(150, 520, 440, 140, 20), "yellow")
    t.region("cab", rect(170, 280, 240, 260, 24), "yellow")
    t.region("window", rect(210, 320, 160, 130, 16), "skyblue")
    t.region("arm", union(band([(520, 560), (700, 280)], 70, smooth=False), band([(700, 280), (860, 450)], 60, smooth=False)),
             "orange")
    t.region("bucket", poly([(800, 450), (940, 430), (930, 600), (830, 620)], 20), "grey")
    t.region("dirt", ellipse(870, 870, 110, 60), "brown")
    return t


def cement_mixer():
    t = Template("cement_mixer", "Cement Mixer", CAT)
    t.region("frame", rect(60, 560, 620, 80, 20), "grey")
    t.region("drum", ellipse(360, 430, 280, 150, -12), "orange")
    t.region("stripe_1", band([(260, 280), (320, 580)], 40, smooth=False).intersection(ellipse(360, 430, 280, 150, -12)),
             "white", label="Drum stripe 1")
    t.region("stripe_2", band([(420, 270), (480, 570)], 40, smooth=False).intersection(ellipse(360, 430, 280, 150, -12)),
             "white", label="Drum stripe 2")
    t.region("cab", rect(660, 340, 260, 340, 40), "blue")
    t.region("window", rect(720, 390, 150, 140, 20), "skyblue")
    t.region("chute", poly([(60, 560), (20, 700), (80, 700), (120, 560)], 10), "grey")
    _wheels(t, (230, 780), 710, 90)
    return t


def race_car():
    t = Template("race_car", "Race Car", CAT)
    t.region("wing", union(rect(80, 380, 160, 40, 14), rect(140, 400, 30, 120)), "black", label="Back wing")
    body = poly([(120, 640), (120, 520), (380, 470), (480, 390), (600, 390), (700, 480), (930, 560), (930, 640)], 40)
    t.region("body", body, "red")
    t.region("helmet", circle(540, 400, 70).intersection(halfplane_above(460)), "yellow")
    t.region("number_circle", circle(330, 560, 60), "white", label="Number circle")
    t.region("stripe", band([(600, 560), (920, 600)], 40, smooth=False).intersection(body), "white")
    _wheels(t, (270, 790), 670, 100)
    t.line([(315, 520), (330, 510), (330, 600)], 12, smooth=False)
    t.line([(510, 400), (570, 400)], 10, smooth=False)
    return t


def van():
    t = Template("van", "Van", CAT)
    t.region("body", union(rect(80, 300, 650, 380, 50), poly([(700, 300), (800, 300), (920, 460), (920, 680), (700, 680)], 30)),
             "teal")
    for i, x in enumerate((140, 330, 520)):
        t.region(f"window_{i + 1}", rect(x, 350, 150, 130, 20), "skyblue", label=f"Window {i + 1}")
    t.region("front_window", poly([(720, 350), (790, 350), (880, 480), (720, 480)], 14), "skyblue", label="Front window")
    t.region("stripe", rect(80, 540, 840, 40).intersection(
        union(rect(80, 300, 650, 380, 50), poly([(700, 300), (800, 300), (920, 460), (920, 680), (700, 680)], 30))), "white")
    t.region("light", ellipse(900, 600, 26, 32), "yellow")
    _wheels(t, (250, 760), 700, 90)
    return t


def jeep():
    t = Template("jeep", "Jeep", CAT)
    t.region("spare", circle(110, 500, 90), "black", label="Spare tyre")
    t.region("body", rect(140, 420, 760, 260, 30), "green")
    t.region("roll_bar", band([(330, 430), (380, 230), (620, 230), (660, 430)], 36, smooth=False), "black")
    t.region("windshield", poly([(620, 420), (680, 260), (720, 270), (680, 420)], 10), "skyblue")
    t.region("door", rect(370, 460, 200, 160, 20), "lightgreen")
    t.region("light", circle(860, 480, 34), "yellow")
    t.region("bumper", rect(820, 630, 140, 50, 20), "grey")
    _wheels(t, (280, 760), 700, 110)
    return t


def garbage_truck():
    t = Template("garbage_truck", "Garbage Truck", CAT)
    t.region("container", poly([(60, 280), (620, 280), (620, 680), (110, 680)], 30), "green")
    for i, x in enumerate((180, 320, 460)):
        t.region(f"rib_{i + 1}", rect(x, 300, 40, 360, 12), "lightgreen", label=f"Stripe {i + 1}")
    t.region("cab", rect(600, 360, 320, 320, 40), "white")
    t.region("window", rect(660, 400, 200, 130, 20), "skyblue")
    t.region("bin", union(rect(80, 140, 160, 140, 16), rect(60, 120, 200, 40, 14)), "grey", label="Trash can")
    _wheels(t, (230, 770), 710, 90)
    return t


def ice_cream_truck():
    t = Template("ice_cream_truck", "Ice Cream Truck", CAT)
    t.region("cone", poly([(400, 250), (480, 250), (440, 360)], 10), "orange", label="Cone sign")
    t.region("scoop", circle(440, 220, 55), "pink", label="Ice cream sign")
    t.region("body", union(rect(80, 340, 640, 340, 40), poly([(700, 380), (800, 380), (920, 500), (920, 680), (700, 680)], 30)),
             "white")
    t.region("awning", union(*[circle(130 + 60 * k, 360, 34) for k in range(10)]).intersection(halfplane_below(340)), "pink")
    t.region("counter", rect(150, 420, 400, 160, 20), "skyblue", label="Window")
    t.region("front_window", poly([(720, 410), (790, 410), (880, 510), (720, 510)], 14), "skyblue", label="Front window")
    t.region("stripe", rect(80, 600, 840, 40).intersection(
        union(rect(80, 340, 640, 340, 40), poly([(700, 380), (800, 380), (920, 500), (920, 680), (700, 680)], 30))), "pink")
    _wheels(t, (250, 760), 710, 90)
    return t


def tow_truck():
    t = Template("tow_truck", "Tow Truck", CAT)
    t.region("crane", union(band([(440, 450), (230, 250)], 40, smooth=False), band([(230, 250), (120, 300)], 30)), "grey")
    t.region("hook", band([(120, 300), (110, 420), (150, 450)], 20), "black")
    t.region("bed", rect(100, 520, 480, 160, 20), "orange")
    t.region("cab", rect(560, 330, 340, 350, 40), "orange")
    t.region("window", rect(620, 380, 200, 140, 20), "skyblue")
    t.region("light", rect(660, 280, 120, 50, 18), "yellow")
    _wheels(t, (240, 770), 720, 95)
    return t


def sailboat():
    t = Template("sailboat", "Sailboat", CAT)
    t.region("water", ellipse(500, 860, 470, 110), "skyblue")
    t.region("mast", rect(480, 120, 30, 560), "brown")
    t.region("big_sail", poly([(470, 150), (470, 620), (180, 620)], 20), "white", label="Big sail")
    t.region("small_sail", poly([(520, 220), (520, 620), (760, 620)], 20), "yellow", label="Small sail")
    t.region("flag", poly([(510, 120), (620, 150), (510, 180)], 6), "red")
    t.region("hull", poly([(120, 660), (880, 660), (760, 820), (240, 820)], 30), "red")
    t.region("hull_stripe", rect(150, 700, 700, 40).intersection(poly([(120, 660), (880, 660), (760, 820), (240, 820)], 30)),
             "white", label="Hull stripe")
    return t


def ship():
    t = Template("ship", "Ship", CAT)
    t.region("water", ellipse(500, 880, 470, 100), "skyblue")
    t.region("funnel_1", rect(330, 200, 100, 200, 16), "red", label="Funnel 1")
    t.region("funnel_2", rect(530, 200, 100, 200, 16), "red", label="Funnel 2")
    t.region("deck_2", rect(260, 380, 460, 140, 20), "white", label="Top deck")
    t.region("deck_1", rect(180, 500, 640, 130, 20), "white", label="Middle deck")
    t.region("hull", poly([(60, 610), (940, 610), (820, 820), (180, 820)], 30), "darkblue")
    t.region("stripe", rect(80, 660, 840, 40).intersection(poly([(60, 610), (940, 610), (820, 820), (180, 820)], 30)), "red")
    for i, x in enumerate((240, 370, 500, 630, 760)):
        t.region(f"porthole_{i + 1}", circle(x, 565, 30), "skyblue", label=f"Window {i + 1}")
    return t


def canoe():
    t = Template("canoe", "Canoe", CAT)
    t.region("water", ellipse(500, 820, 470, 120), "skyblue")
    t.region("paddle", union(band([(700, 300), (560, 760)], 26, smooth=False), ellipse(530, 820, 45, 90, 18)), "brown")
    t.region("kid_body", ellipse(450, 560, 90, 100), "red", label="Life jacket")
    t.region("kid_head", circle(450, 410, 80), "peach", label="Face")
    t.region("hat", ellipse(450, 350, 100, 40).union(circle(450, 340, 60).intersection(halfplane_above(350))), "yellow")
    t.region("canoe", poly([(80, 620), (920, 620), (800, 760), (200, 760)], 60), "orange")
    t.region("canoe_stripe", rect(100, 650, 800, 34).intersection(poly([(80, 620), (920, 620), (800, 760), (200, 760)], 60)),
             "white", label="Canoe stripe")
    t.eyes(450, 410, 60, 12)
    t.smile(450, 440, 40, 14)
    return t


def scooter():
    t = Template("scooter", "Scooter", CAT)
    t.region("handle", band([(640, 170), (760, 170)], 40, smooth=False), "black")
    t.region("stem", band([(700, 180), (760, 720)], 44, smooth=False), "red")
    t.region("deck", rect(180, 640, 560, 60, 30), "red")
    t.region("deck_grip", rect(220, 620, 460, 30, 14), "black", label="Grip tape")
    _wheel(t, "back_wheel", 250, 760, 80, "Back wheel")
    _wheel(t, "front_wheel", 760, 760, 80, "Front wheel")
    t.region("bell", circle(640, 230, 34), "yellow")
    t.region("streamer", union(band([(780, 170), (870, 210)], 22), band([(780, 170), (860, 130)], 22)), "pink")
    return t


def skateboard():
    t = Template("skateboard", "Skateboard", CAT)
    board = union(rect(150, 420, 700, 120, 60), ellipse(150, 450, 90, 60, -20), ellipse(850, 450, 90, 60, 20))
    t.region("board", board, "purple")
    t.region("flame", poly([(350, 480), (420, 430), (470, 480), (540, 420), (590, 480), (650, 440), (680, 500), (330, 500)], 10),
             "orange")
    t.region("left_truck", rect(260, 540, 120, 50, 14), "grey", label="Left truck")
    t.region("right_truck", rect(620, 540, 120, 50, 14), "grey", label="Right truck")
    for i, x in enumerate((260, 380, 620, 740)):
        t.region(f"wheel_{i + 1}", circle(x, 640, 55), ["yellow", "green"][i % 2], label=f"Wheel {i + 1}")
    t.region("star", star(500, 250, 90), "yellow")
    return t


def tram():
    t = Template("tram", "Tram", CAT)
    t.line([(0, 140), (1000, 140)], 10, smooth=False)
    t.region("pole", union(band([(500, 280), (420, 140)], 22, smooth=False)), "grey")
    t.region("roof", rect(120, 260, 760, 60, 30), "red")
    t.region("body", rect(100, 300, 800, 420, 40), "yellow")
    for i, x in enumerate((150, 330, 510)):
        t.region(f"window_{i + 1}", rect(x, 360, 140, 140, 20), "skyblue", label=f"Window {i + 1}")
    t.region("door", rect(690, 360, 150, 330, 20), "orange")
    t.region("stripe", rect(100, 560, 590, 40), "red")
    t.region("rail", rect(60, 830, 880, 30, 10), "grey")
    _wheels(t, (260, 560), 780, 70)
    return t


def cable_car():
    t = Template("cable_car", "Cable Car", CAT)
    t.region("mountain", poly([(0, 1000), (0, 700), (220, 520), (420, 760), (650, 560), (1000, 860), (1000, 1000)], 20), "green")
    t.region("snow", poly([(170, 560), (220, 520), (270, 570)], 6), "white")
    t.line([(0, 120), (1000, 280)], 10, smooth=False)
    t.region("arm", union(band([(500, 200), (500, 330)], 26, smooth=False), rect(440, 180, 120, 40, 16)), "grey")
    t.region("cabin", rect(320, 330, 360, 330, 40), "red")
    t.region("window_1", rect(360, 380, 120, 130, 18), "skyblue", label="Window 1")
    t.region("window_2", rect(520, 380, 120, 130, 18), "skyblue", label="Window 2")
    t.region("bottom", rect(320, 580, 360, 80, 30).intersection(rect(320, 330, 360, 330, 40)), "yellow", label="Bottom stripe")
    return t


def blimp():
    t = Template("blimp", "Blimp", CAT)
    t.region("cloud", union(circle(200, 780, 80), circle(300, 740, 100), circle(400, 790, 70), rect(130, 780, 330, 80, 40)),
             "white")
    t.region("top_fin", poly([(220, 360), (100, 230), (190, 230), (300, 360)], 14), "red")
    t.region("bottom_fin", poly([(220, 500), (100, 630), (190, 630), (300, 500)], 14), "red")
    body = ellipse(520, 430, 360, 170)
    t.region("body", body, "skyblue")
    t.region("stripe", band([(170, 430), (880, 430)], 60, smooth=False).intersection(body), "white")
    t.region("gondola", rect(440, 590, 180, 80, 30), "yellow")
    t.region("window", rect(470, 610, 60, 40, 10), "skyblue")
    t.region("window_2", rect(550, 610, 50, 40, 10), "skyblue", label="Window 2")
    t.eyes(760, 400, 70, 16)
    t.smile(770, 450, 50, 16)
    return t


TEMPLATES = [
    fire_truck,
    police_car,
    ambulance,
    taxi,
    digger,
    cement_mixer,
    race_car,
    van,
    jeep,
    garbage_truck,
    ice_cream_truck,
    tow_truck,
    sailboat,
    ship,
    canoe,
    scooter,
    skateboard,
    tram,
    cable_car,
    blimp,
]
