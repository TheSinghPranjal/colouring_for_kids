import math

from shapely.geometry import Polygon

from lib import Template, band, catmull, circle, ellipse, mirror, poly, rect, teardrop, union, lens

CAT = "toys_imagination"


def teddy_bear():
    t = Template("teddy_bear", "Teddy Bear", CAT)
    t.region("left_ear", circle(335, 190, 78), "brown")
    t.region("right_ear", circle(665, 190, 78), "brown")
    t.region("left_leg", ellipse(375, 855, 105, 85), "brown")
    t.region("right_leg", ellipse(625, 855, 105, 85), "brown")
    t.region("body", ellipse(500, 650, 195, 215), "brown")
    t.region("belly", ellipse(500, 690, 110, 120), "peach")
    t.region("left_arm", ellipse(300, 600, 70, 135, 35), "brown")
    t.region("right_arm", ellipse(700, 600, 70, 135, -35), "brown")
    t.region("left_paw", circle(375, 868, 52), "peach")
    t.region("right_paw", circle(625, 868, 52), "peach")
    t.region("head", circle(500, 310, 180), "brown")
    t.region("muzzle", ellipse(500, 380, 92, 68), "peach")
    t.region("bow", union(poly([(500, 495), (395, 445), (395, 545)], 16), poly([(500, 495), (605, 445), (605, 545)], 16), circle(500, 495, 34)), "red", label="Bow tie")
    t.eyes(500, 290, 130, 22)
    t.shape_detail(ellipse(500, 355, 34, 24))
    t.line([(500, 375), (500, 400)], 9, smooth=False)
    t.line([(460, 405), (480, 420), (500, 400), (520, 420), (540, 405)], 9)
    return t


def ball():
    t = Template("ball", "Ball", CAT)
    c = (500, 520)
    radius = 390
    ball = circle(*c, radius)
    pole = (470, 330)
    colours = ["red", "yellow", "blue", "white", "green", "orange"]
    curves = []
    for k in range(6):
        a = math.radians(-90 + k * 60 + 20)
        end = (c[0] + 560 * math.cos(a), c[1] + 560 * math.sin(a))
        bend = math.radians(-90 + k * 60 + 20 + 50)
        mid = ((pole[0] + end[0]) / 2 + 90 * math.cos(bend), (pole[1] + end[1]) / 2 + 90 * math.sin(bend))
        curves.append(catmull([pole, mid, end], False, 20))
    for k in range(6):
        a0 = math.radians(-90 + k * 60 + 20)
        a1 = math.radians(-90 + (k + 1) * 60 + 20)
        arc = [(c[0] + 560 * math.cos(a0 + (a1 - a0) * i / 10), c[1] + 560 * math.sin(a0 + (a1 - a0) * i / 10)) for i in range(11)]
        pts = curves[k] + arc + list(reversed(curves[(k + 1) % 6]))
        panel = Polygon(pts).buffer(0).intersection(ball)
        t.region(f"panel_{k + 1}", panel, colours[k], label=f"Ball panel {k + 1}")
    t.region("top", circle(*pole, 70), "white", label="Ball top")
    t.region("shine", lens((290, 470), -60, 140, 50), "white")
    return t


def kite():
    t = Template("kite", "Kite", CAT)
    top, right, bottom, left = (500, 55), (745, 330), (500, 600), (255, 330)
    centre = (500, 330)
    tail_pts = [(500, 600), (585, 690), (430, 790), (565, 895), (520, 955)]
    t.region("tail", band(tail_pts, 26), "red")
    panels = [(top, right), (right, bottom), (bottom, left), (left, top)]
    colours = ["red", "yellow", "blue", "green"]
    for i, (a, b) in enumerate(panels):
        t.region(f"panel_{i + 1}", poly([centre, a, b], 16), colours[i], label=f"Kite panel {i + 1}")
    t.region("center", circle(*centre, 46), "white", label="Kite middle")
    curve = catmull(tail_pts, False, 30)
    for i, idx in enumerate((30, 60, 90)):
        x, y = curve[idx]
        bow = union(poly([(x, y), (x - 66, y - 38), (x - 66, y + 38)], 12), poly([(x, y), (x + 66, y - 38), (x + 66, y + 38)], 12), circle(x, y, 20))
        t.region(f"bow_{i + 1}", bow, ["pink", "purple", "orange"][i], label=f"Bow {i + 1}")
    t.eyes(500, 315, 46, 10)
    t.smile(500, 342, 34, 12, 8)
    return t


def toy_robot():
    t = Template("toy_robot", "Toy Robot", CAT)
    t.region("antenna", union(band([(500, 100), (500, 170)], 20), circle(500, 82, 36)), "red")
    arm = union(band([(305, 450), (220, 560), (205, 650)], 62), circle(205, 690, 50))
    t.region("left_arm", arm, "grey")
    t.region("right_arm", mirror(arm), "grey")
    t.region("left_leg", union(rect(360, 690, 100, 170, 20), rect(330, 840, 150, 70, 30)), "blue")
    t.region("right_leg", union(rect(540, 690, 100, 170, 20), rect(520, 840, 150, 70, 30)), "blue")
    t.region("body", union(rect(300, 400, 400, 310, 40), rect(450, 360, 100, 60)), "skyblue")
    t.region("panel", rect(365, 450, 270, 200, 24), "white", label="Chest panel")
    for i, x in enumerate((425, 500, 575)):
        t.region(f"button_{i + 1}", circle(x, 530, 33), ["red", "yellow", "green"][i], label=f"Button {i + 1}")
    t.line([(410, 605), (590, 605)], 10, smooth=False)
    t.region("head", rect(330, 160, 340, 220, 44), "skyblue")
    t.region("face", rect(375, 200, 250, 140, 30), "white", label="Face screen")
    t.eyes(500, 255, 110, 24)
    t.smile(500, 295, 80, 22)
    return t


def toy_rocket():
    t = Template("toy_rocket", "Toy Rocket", CAT)
    t.region("outer_flame", teardrop(500, 780, 92, height=1.85, rot=180), "orange", label="Outer flame")
    t.region("inner_flame", teardrop(500, 780, 52, height=2.0, rot=180), "yellow", label="Inner flame")
    fin = poly([(390, 540), (240, 760), (250, 820), (400, 730)], 22)
    t.region("left_fin", fin, "red")
    t.region("right_fin", mirror(fin), "red")
    body = union(lens((500, 820), -90, 760, 300).intersection(rect(0, 0, 1000, 760)))
    t.region("body", body, "white")
    t.region("nose_cone", body.intersection(rect(0, 0, 1000, 250)), "red", label="Nose cone")
    t.region("big_window", circle(500, 400, 70), "skyblue", label="Big window")
    t.region("small_window", circle(500, 560, 44), "skyblue", label="Small window")
    t.region("nozzle", rect(420, 735, 160, 50, 18), "grey")
    return t


TEMPLATES = [teddy_bear, ball, kite, toy_robot, toy_rocket]
