"""Twenty more Fruits & Vegetables sketches (11-30)."""

import math

from lib import (
    Template,
    annulus,
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

CAT = "fruits_vegetables"


def _face(t, x, y, spacing=120, r=22, cheeks=True):
    t.eyes(x, y, spacing, r)
    t.smile(x, y + 55, spacing * 0.55, spacing * 0.2)
    if cheeks:
        t.dot(x - spacing * 0.85, y + 45, r * 1.2, "#F48FB1")
        t.dot(x + spacing * 0.85, y + 45, r * 1.2, "#F48FB1")


def orange():
    t = Template("orange", "Orange", CAT)
    t.region("leaf", lens((510, 230), -30, 220, 100), "green")
    t.region("stalk", band([(500, 260), (505, 200)], 30), "brown")
    t.region("fruit", circle(500, 540, 290), "orange")
    t.region("slice", circle(780, 820, 140).intersection(halfplane_above(820)), "orange", label="Orange slice")
    t.region("slice_inside", circle(780, 820, 110).intersection(halfplane_above(810)), "yellow", label="Slice inside")
    _face(t, 500, 520)
    for a in (200, 240, 270, 300, 340):
        r = math.radians(a)
        t.line([(780, 810), (780 + 100 * math.cos(r), 810 + 100 * math.sin(r))], 7, smooth=False)
    return t


def lemon():
    t = Template("lemon", "Lemon", CAT)
    t.region("leaf", lens((640, 260), -40, 200, 90), "green")
    body = union(ellipse(500, 520, 330, 230, -15), ellipse(790, 440, 70, 50, -15), ellipse(210, 600, 70, 50, -15))
    t.region("lemon", body, "yellow")
    t.region("shine", ellipse(380, 420, 70, 30, -20), "white")
    t.region("left_cheek", circle(400, 560, 32), "pink")
    t.region("right_cheek", circle(600, 560, 32), "pink")
    t.region("slice", circle(800, 800, 130).intersection(halfplane_above(800)), "yellow", label="Lemon slice")
    _face(t, 500, 510, cheeks=False)
    for a in (200, 240, 270, 300, 340):
        r = math.radians(a)
        t.line([(800, 790), (800 + 95 * math.cos(r), 790 + 95 * math.sin(r))], 7, smooth=False)
    return t


def cherry():
    t = Template("cherry", "Cherries", CAT)
    t.region("leaf", lens((520, 150), -20, 260, 110), "green")
    t.region("left_stem", band([(510, 150), (420, 350), (330, 560)], 26), "brown", label="Left stem")
    t.region("right_stem", band([(510, 150), (590, 350), (660, 560)], 26), "brown", label="Right stem")
    t.region("left_cherry", circle(320, 680, 180), "red", label="Left cherry")
    t.region("right_cherry", circle(690, 680, 180), "red", label="Right cherry")
    t.region("left_shine", ellipse(250, 620, 40, 25, -30), "white", label="Left shine")
    t.region("right_shine", ellipse(620, 620, 40, 25, -30), "white", label="Right shine")
    _face(t, 320, 690, 100, 18, cheeks=False)
    _face(t, 690, 690, 100, 18, cheeks=False)
    return t


def pineapple():
    t = Template("pineapple", "Pineapple", CAT)
    for i, a in enumerate((-125, -105, -90, -75, -55)):
        t.region(f"leaf_{i + 1}", lens((500, 330), a, 260 if a == -90 else 220, 80), ["green", "lightgreen"][i % 2],
                 label=f"Leaf {i + 1}")
    body = ellipse(500, 620, 230, 300)
    t.region("fruit", body, "yellow")
    t.region("band", band([(270, 720), (730, 720)], 60, smooth=False).intersection(body), "orange", label="Stripe")
    from shapely.geometry import LineString

    inner = body.buffer(-10)
    for k in range(-5, 6):
        for a, b in (((500 + k * 90 - 200, 330), (500 + k * 90 + 200, 930)),
                     ((500 + k * 90 + 200, 330), (500 + k * 90 - 200, 930))):
            seg = LineString([a, b]).intersection(inner)
            if not seg.is_empty and seg.length > 20:
                t.line(list(seg.coords), 8, smooth=False)
    return t


def peach():
    t = Template("peach", "Peach", CAT)
    t.region("leaf", lens((520, 230), -30, 240, 110), "green")
    fruit = union(circle(400, 560, 260), circle(600, 560, 260)).intersection(halfplane_above(830))
    fruit = union(fruit, ellipse(500, 760, 280, 120))
    t.region("left_half", fruit.intersection(rect(0, 0, 500, 1000)), "peach", label="Left side")
    t.region("right_half", fruit.intersection(rect(500, 0, 500, 1000)), "orange", label="Right side")
    t.region("blush", circle(660, 500, 70), "pink")
    _face(t, 500, 590, 140, 22, cheeks=False)
    return t


def plum():
    t = Template("plum", "Plum", CAT)
    t.region("stalk", band([(500, 300), (520, 180)], 30), "brown")
    t.region("leaf", lens((520, 200), 0, 220, 100), "green")
    t.region("plum", union(circle(500, 560, 280), ellipse(500, 480, 260, 230)), "purple")
    t.region("shine", ellipse(360, 440, 60, 30, -30), "white")
    t.region("left_cheek", circle(350, 620, 40), "pink")
    t.region("right_cheek", circle(650, 620, 40), "pink")
    t.eyes(500, 560, 170, 24)
    t.smile(500, 620, 80, 30)
    t.line([(500, 300), (480, 420)], 9)
    return t


def kiwi():
    t = Template("kiwi", "Kiwi", CAT)
    t.region("whole", ellipse(300, 600, 200, 160, 20), "brown", label="Whole kiwi")
    t.region("skin", circle(640, 480, 270), "brown", label="Kiwi skin")
    t.region("flesh", circle(640, 480, 230), "lightgreen")
    t.region("core", ellipse(640, 480, 80, 60), "white")
    for k in range(12):
        a = math.radians(k * 30)
        t.dot(640 + 120 * math.cos(a), 480 + 95 * math.sin(a), 12)
    t.eyes(640, 470, 70, 14)
    t.smile(640, 500, 40, 14)
    for x, y in ((240, 560), (300, 520), (360, 600), (280, 650)):
        t.line([(x, y), (x + 15, y + 8)], 7, smooth=False)
    return t


def mango():
    t = Template("mango", "Mango", CAT)
    t.region("leaf", lens((560, 230), -10, 260, 110), "green")
    body = blob([(560, 240), (760, 380), (800, 600), (660, 820), (420, 860), (240, 720), (240, 500), (380, 300)])
    t.region("mango", body, "yellow")
    t.region("blush", ellipse(650, 400, 140, 110, 30).intersection(body.buffer(-10)), "orange")
    t.region("blush_2", ellipse(700, 330, 60, 40, 30).intersection(body.buffer(-10)), "red", label="Red blush")
    _face(t, 480, 580)
    return t


def coconut():
    t = Template("coconut", "Coconut", CAT)
    t.region("whole", circle(300, 620, 220), "brown", label="Whole coconut")
    t.region("half_shell", circle(700, 560, 230).intersection(halfplane_below(520)), "brown", label="Half shell")
    t.region("half_inside", ellipse(700, 540, 200, 60), "white", label="Coconut inside")
    t.region("straw", band([(740, 520), (800, 200), (880, 160)], 30), "pink")
    t.region("umbrella", union(ellipse(860, 150, 110, 50).intersection(halfplane_above(160))), "yellow", label="Little umbrella")
    t.dot(260, 560, 22)
    t.dot(340, 560, 22)
    t.dot(300, 630, 22)
    t.eyes(700, 650, 100, 18)
    t.smile(700, 700, 50, 18)
    return t


def avocado():
    t = Template("avocado", "Avocado", CAT)
    skin = union(circle(500, 650, 270), ellipse(500, 400, 190, 260))
    t.region("skin", skin, "green")
    t.region("flesh", union(circle(500, 650, 230), ellipse(500, 410, 150, 220)), "lightgreen")
    t.region("pit", circle(500, 680, 120), "brown")
    t.region("left_cheek", circle(400, 520, 30), "pink")
    t.region("right_cheek", circle(600, 520, 30), "pink")
    t.eyes(500, 470, 140, 20)
    t.smile(500, 520, 60, 22)
    t.dot(460, 650, 20, "#FFFFFF")
    return t


def blueberries():
    t = Template("blueberries", "Blueberries", CAT)
    t.region("bowl", ellipse(500, 760, 380, 160).intersection(halfplane_below(700)), "white")
    berries = [(330, 620, 110), (500, 580, 120), (670, 620, 110), (410, 470, 100), (600, 470, 100), (500, 360, 95)]
    for i, (x, y, r) in enumerate(reversed(berries)):
        t.region(f"berry_{6 - i}", circle(x, y, r), ["blue", "darkblue"][i % 2], label=f"Berry {6 - i}")
    t.region("bowl_front", ellipse(500, 720, 400, 170).intersection(halfplane_below(700)), "skyblue", label="Bowl")
    for x, y, r in berries:
        t.shape_detail(star(x, y - r * 0.55, r * 0.22, r=2))
    t.eyes(500, 600, 80, 16)
    t.smile(500, 640, 40, 14)
    return t


def pumpkin():
    t = Template("pumpkin", "Pumpkin", CAT)
    t.region("stalk", band([(500, 330), (520, 200), (570, 170)], 50), "brown")
    t.region("leaf", lens((520, 250), -10, 220, 100), "green")
    t.region("left_lobe", ellipse(300, 600, 190, 270), "orange", label="Left side")
    t.region("right_lobe", ellipse(700, 600, 190, 270), "orange", label="Right side")
    t.region("middle", ellipse(500, 600, 200, 290), "orange")
    t.region("left_eye", poly([(400, 510), (460, 510), (430, 450)], 6), "yellow", label="Left eye")
    t.region("right_eye", poly([(540, 510), (600, 510), (570, 450)], 6), "yellow", label="Right eye")
    t.region("mouth", poly([(380, 650), (440, 700), (500, 660), (560, 700), (620, 650), (560, 760), (440, 760)], 10), "yellow")
    return t


def eggplant():
    t = Template("eggplant", "Eggplant", CAT)
    body = union(ellipse(560, 620, 260, 290, 30), circle(380, 330, 150))
    t.region("eggplant", body, "purple")
    t.region("shine", ellipse(450, 550, 50, 120, 30), "white")
    t.region("cap", union(circle(320, 260, 120).intersection(halfplane_above(330)),
                          *[lens((320, 280), a, 170, 70) for a in (60, 100, 140)]), "green")
    t.region("stalk", band([(280, 180), (230, 100)], 40), "green")
    _face(t, 580, 620, 130, 22)
    return t


def potato():
    t = Template("potato", "Potato", CAT)
    t.region("potato", blob([(240, 420), (420, 300), (650, 320), (800, 450), (790, 650), (620, 780), (380, 780), (220, 640)]),
             "brown")
    t.region("sprout", union(band([(560, 320), (580, 220)], 20), lens((580, 230), -40, 110, 50)), "green")
    for i, (x, y) in enumerate([(320, 420), (720, 600), (380, 690)]):
        t.region(f"spot_{i + 1}", ellipse(x, y, 34, 24), "peach", label=f"Spot {i + 1}")
    _face(t, 520, 520, 130, 22)
    return t


def onion():
    t = Template("onion", "Onion", CAT)
    t.region("roots", union(*[band([(500, 820), (500 + 40 * k, 900)], 14, smooth=False) for k in (-1, 0, 1)]), "white")
    t.region("tops", union(band([(500, 260), (470, 120), (430, 70)], 40), band([(500, 260), (540, 110), (590, 70)], 40)), "green")
    body = union(circle(500, 580, 260), poly([(400, 380), (500, 240), (600, 380)], 40))
    t.region("onion", body, "purple")
    t.region("stripe_left", band([(420, 320), (300, 580), (420, 820)], 30).intersection(body.buffer(-10)), "pink",
             label="Left stripe")
    t.region("stripe_right", band([(580, 320), (700, 580), (580, 820)], 30).intersection(body.buffer(-10)), "pink",
             label="Right stripe")
    _face(t, 500, 580, 110, 20, cheeks=False)
    return t


def peas():
    t = Template("peas", "Peas", CAT)
    pod = lens((120, 620), -15, 800, 300)
    t.region("pod", pod, "green")
    t.region("inside", lens((180, 600), -15, 680, 200), "lightgreen")
    for i in range(4):
        x = 280 + 150 * i
        y = 560 - 40 * i
        t.region(f"pea_{i + 1}", circle(x, y, 70), "green", label=f"Pea {i + 1}")
    t.region("stalk", band([(880, 400), (930, 300), (900, 230)], 30), "lightgreen")
    for i in range(4):
        x = 280 + 150 * i
        y = 560 - 40 * i
        t.eyes(x, y - 5, 50, 10)
        t.smile(x, y + 22, 30, 10, 7)
    return t


def bell_pepper():
    t = Template("bell_pepper", "Bell Pepper", CAT)
    t.region("stalk", band([(500, 280), (510, 180), (560, 150)], 46), "green")
    t.region("cap", ellipse(500, 300, 120, 50), "green")
    t.region("left_lobe", ellipse(340, 580, 160, 300), "red", label="Left side")
    t.region("right_lobe", ellipse(660, 580, 160, 300), "red", label="Right side")
    t.region("middle", ellipse(500, 610, 170, 300), "red")
    t.region("shine", ellipse(420, 460, 30, 80, 10), "white")
    _face(t, 500, 600, 120, 22)
    return t


def cucumber():
    t = Template("cucumber", "Cucumber", CAT)
    body = band([(150, 700), (400, 450), (750, 300)], 220)
    t.region("cucumber", body, "green")
    t.region("stripe", band([(220, 690), (440, 480), (760, 340)], 50).intersection(body.buffer(-15)), "lightgreen")
    t.region("slice", circle(760, 760, 150), "green", label="Slice skin")
    t.region("slice_inside", circle(760, 760, 120), "lightgreen", label="Slice inside")
    for k in range(6):
        a = math.radians(k * 60)
        t.shape_detail(ellipse(760 + 60 * math.cos(a), 760 + 60 * math.sin(a), 12, 20, k * 60 + 90), "#FFFFFF")
    t.eyes(430, 450, 100, 20)
    t.smile(440, 510, 60, 22)
    for x, y in ((250, 640), (580, 360), (680, 330)):
        t.dot(x, y, 10)
    return t


def radish():
    t = Template("radish", "Radish", CAT)
    for i, a in enumerate((-120, -90, -60)):
        t.region(f"leaf_{i + 1}", lens((500, 320), a, 260, 120), ["green", "lightgreen"][i % 2], label=f"Leaf {i + 1}")
    body = union(circle(500, 540, 230), poly([(400, 700), (500, 920), (600, 700)], 20))
    t.region("radish", body, "pink")
    t.region("tip", poly([(440, 780), (500, 920), (560, 780)], 20).intersection(body), "white")
    _face(t, 500, 520, 130, 22, cheeks=False)
    t.dot(380, 580, 26, "#E53935")
    t.dot(620, 580, 26, "#E53935")
    return t


def lettuce():
    t = Template("lettuce", "Lettuce", CAT)
    t.region("outer_leaves", union(*[circle(500 + 280 * math.cos(math.radians(a)), 560 + 240 * math.sin(math.radians(a)), 120)
                                     for a in range(0, 360, 30)], ellipse(500, 560, 300, 260)), "green", label="Outer leaves")
    t.region("middle_leaves", union(*[circle(500 + 170 * math.cos(math.radians(a)), 560 + 150 * math.sin(math.radians(a)), 90)
                                      for a in range(0, 360, 45)]), "lightgreen", label="Middle leaves")
    t.region("heart", circle(500, 560, 130), "lightgreen", label="Lettuce heart")
    t.region("ladybug", circle(760, 330, 50), "red")
    t.eyes(500, 540, 90, 18)
    t.smile(500, 590, 50, 18)
    t.dot(760, 300, 20)
    for a in range(0, 360, 45):
        r = math.radians(a)
        t.line([(500 + 140 * math.cos(r), 560 + 120 * math.sin(r)), (500 + 230 * math.cos(r), 560 + 200 * math.sin(r))], 8,
               smooth=False)
    return t


TEMPLATES = [
    orange,
    lemon,
    cherry,
    pineapple,
    peach,
    plum,
    kiwi,
    mango,
    coconut,
    avocado,
    blueberries,
    pumpkin,
    eggplant,
    potato,
    onion,
    peas,
    bell_pepper,
    cucumber,
    radish,
    lettuce,
]
