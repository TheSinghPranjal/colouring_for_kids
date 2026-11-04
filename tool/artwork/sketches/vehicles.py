import math

from lib import Template, band, circle, ellipse, lens, poly, rect, union

CAT = "vehicles"


def _wheel(t, name, x, y, r, label):
    t.region(f"{name}", circle(x, y, r), "black", label=label)
    t.region(f"{name}_hub", circle(x, y, r * 0.42), "grey", label=f"{label} middle")


def car():
    t = Template("car", "Car", CAT)
    t.region("roof", poly([(270, 500), (370, 320), (640, 320), (750, 500)], 34), "red")
    body = rect(110, 470, 790, 210, 70)
    t.region("body", body, "red")
    t.region("back_window", poly([(320, 470), (395, 355), (490, 355), (490, 470)], 16), "skyblue")
    t.region("front_window", poly([(525, 470), (525, 355), (615, 355), (700, 470)], 16), "skyblue")
    t.region("door", rect(500, 500, 190, 150, 24), "orange")
    t.region("headlight", ellipse(860, 545, 32, 36).intersection(body.buffer(-8)), "yellow")
    t.region("front_bumper", rect(820, 625, 110, 50, 24), "grey")
    t.region("back_bumper", rect(75, 625, 110, 50, 24), "grey")
    _wheel(t, "back_wheel", 300, 690, 98, "Back wheel")
    _wheel(t, "front_wheel", 710, 690, 98, "Front wheel")
    t.line([(530, 540), (580, 540)], 10, smooth=False)
    return t


def bus():
    t = Template("bus", "Bus", CAT)
    body = rect(80, 280, 840, 420, 56)
    t.region("body", body, "yellow")
    for i, x in enumerate((130, 275, 420)):
        t.region(f"window_{i + 1}", rect(x, 340, 115, 140, 20), "skyblue", label=f"Window {i + 1}")
    t.region("windshield", rect(765, 330, 120, 200, 24), "skyblue", label="Front windshield")
    t.region("door", rect(590, 340, 140, 320, 20), "orange")
    t.region("stripe", rect(80, 540, 840, 40).intersection(body).difference(rect(590, 340, 140, 320, 20)), "red")
    t.region("headlight", ellipse(880, 610, 34, 30).intersection(body.buffer(-6)), "white")
    t.region("bumper", rect(60, 680, 880, 50, 25), "grey")
    _wheel(t, "back_wheel", 260, 720, 92, "Back wheel")
    _wheel(t, "front_wheel", 720, 720, 92, "Front wheel")
    t.line([(660, 360), (660, 640)], 9, smooth=False)
    return t


def train():
    t = Template("train", "Train", CAT)
    t.region("smoke_1", union(circle(210, 205, 52), circle(260, 180, 48)), "white", label="Smoke puff 1")
    t.region("smoke_2", union(circle(320, 110, 56), circle(380, 95, 46)), "white", label="Smoke puff 2")
    chimney = union(rect(130, 330, 76, 160, 14), rect(108, 300, 120, 50, 18))
    t.region("chimney", chimney, "black")
    t.region("engine", union(rect(60, 450, 330, 220, 46), poly([(60, 600), (20, 700), (120, 700)], 10)), "red")
    t.region("cab", union(rect(330, 320, 200, 350, 24), rect(310, 290, 240, 56, 24)), "blue")
    t.region("cab_window", rect(370, 380, 120, 110, 18), "skyblue", label="Cab window")
    t.region("carriage_roof", rect(560, 360, 400, 56, 26), "red", label="Carriage roof")
    t.region("carriage", rect(580, 400, 360, 270, 30), "green")
    for i, x in enumerate((615, 780)):
        t.region(f"carriage_window_{i + 1}", rect(x, 450, 120, 110, 18), "skyblue", label=f"Carriage window {i + 1}")
    for i, (x, r) in enumerate([(150, 78), (330, 78), (660, 66), (860, 66)]):
        t.region(f"wheel_{i + 1}", circle(x, 700, r), "black", label=f"Wheel {i + 1}")
        t.dot(x, 700, 14)
    t.line([(530, 615), (580, 615)], 14, smooth=False)
    t.line([(30, 800), (970, 800)], 12, smooth=False)
    return t


def airplane():
    t = Template("airplane", "Airplane", CAT)
    t.region("far_wing", poly([(440, 470), (560, 470), (470, 260), (390, 260)], 24), "blue")
    t.region("tail", poly([(130, 500), (110, 250), (220, 260), (300, 470)], 24), "red")
    t.region("body", ellipse(480, 510, 370, 115), "white", label="Plane body")
    t.region("cockpit", lens((720, 470), 10, 120, 70).intersection(ellipse(480, 510, 360, 105)), "skyblue")
    for i, x in enumerate((340, 430, 520, 610)):
        t.region(f"window_{i + 1}", circle(x, 480, 30), "skyblue", label=f"Window {i + 1}")
    t.region("engine", band([(430, 680), (560, 680)], 76), "grey")
    t.region("near_wing", poly([(420, 545), (580, 545), (480, 780), (360, 780)], 24), "blue")
    t.line([(200, 560), (300, 560)], 10, smooth=False)
    return t


def boat():
    t = Template("boat", "Boat", CAT)
    t.region("mast", band([(610, 130), (610, 580)], 26), "brown")
    t.region("big_sail", poly([(590, 160), (590, 520), (300, 520)], 18), "white")
    t.region("small_sail", poly([(632, 200), (632, 520), (810, 520)], 18), "yellow")
    t.region("flag", poly([(622, 95), (740, 125), (622, 160)], 10), "red")
    t.region("cabin", rect(320, 545, 260, 120, 22), "orange")
    for i, x in enumerate((395, 505)):
        t.region(f"window_{i + 1}", circle(x, 600, 32), "skyblue", label=f"Window {i + 1}")
    hull = poly([(130, 640), (870, 640), (750, 820), (250, 820)], 22)
    t.region("hull", hull, "red")
    t.region("stripe", rect(0, 690, 1000, 44).intersection(hull), "white")
    waves = union(rect(40, 800, 920, 140, 40), *[circle(95 + i * 90, 805, 50) for i in range(10)])
    t.region("water", waves.intersection(rect(40, 740, 920, 200, 40)), "skyblue")
    return t


def bicycle():
    t = Template("bicycle", "Bicycle", CAT)
    _wheel(t, "front_wheel", 700, 720, 120, "Front wheel")
    _wheel(t, "back_wheel", 300, 720, 120, "Back wheel")
    t.region("frame", band([(300, 720), (500, 480), (700, 720), (500, 480), (500, 360)], 36), "red")
    t.region("seat", ellipse(480, 340, 70, 30), "black")
    t.region("handle", band([(500, 360), (620, 300), (680, 280)], 28), "grey")
    return t


def truck():
    t = Template("truck", "Truck", CAT)
    t.region("cab", rect(200, 420, 220, 280, 24), "red")
    t.region("window", rect(240, 460, 140, 100, 16), "skyblue")
    t.region("bed", rect(420, 500, 380, 200, 20), "blue")
    t.region("bumper", rect(180, 680, 80, 40, 12), "grey")
    _wheel(t, "front_wheel", 300, 760, 90, "Front wheel")
    _wheel(t, "back_wheel", 700, 760, 90, "Back wheel")
    t.eyes(300, 520, 60, 12)
    t.smile(300, 580, 40, 14)
    return t


def helicopter():
    t = Template("helicopter", "Helicopter", CAT)
    t.region("body", ellipse(500, 560, 200, 130), "red")
    t.region("cabin", ellipse(420, 520, 90, 70), "skyblue")
    t.region("tail", band([(680, 560), (880, 520)], 40), "red")
    t.region("tail_fin", poly([(860, 500), (920, 440), (900, 560)], 12), "blue")
    t.region("rotor", band([(200, 400), (800, 400)], 28), "grey")
    t.region("mast", rect(480, 400, 40, 80, 10), "grey")
    t.region("skid_l", band([(350, 700), (450, 700)], 22), "black")
    t.region("skid_r", band([(550, 700), (650, 700)], 22), "black")
    t.eyes(400, 510, 45, 12)
    return t


def motorcycle():
    t = Template("motorcycle", "Motorcycle", CAT)
    _wheel(t, "front_wheel", 720, 720, 110, "Front wheel")
    _wheel(t, "back_wheel", 280, 720, 110, "Back wheel")
    t.region("body", ellipse(500, 560, 160, 80), "orange")
    t.region("tank", ellipse(520, 500, 90, 55), "red")
    t.region("seat", ellipse(400, 520, 70, 35), "black")
    t.region("handle", band([(600, 480), (700, 400)], 26), "grey")
    t.region("exhaust", band([(320, 620), (200, 640)], 22), "grey")
    return t


def submarine():
    t = Template("submarine", "Submarine", CAT)
    t.region("body", ellipse(500, 560, 320, 140), "yellow")
    t.region("window_1", circle(380, 540, 40), "skyblue")
    t.region("window_2", circle(500, 540, 40), "skyblue")
    t.region("window_3", circle(620, 540, 40), "skyblue")
    t.region("tower", rect(450, 360, 100, 120, 20), "yellow")
    t.region("periscope", rect(520, 280, 30, 100, 8), "grey")
    t.region("prop", circle(180, 560, 50), "orange")
    t.region("fin", poly([(700, 480), (780, 420), (740, 560)], 12), "orange")
    t.smile(500, 600, 60, 18)
    return t


TEMPLATES = [car, bus, train, airplane, boat, bicycle, truck, helicopter, motorcycle, submarine]
