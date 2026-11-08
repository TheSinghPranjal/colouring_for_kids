"""Twenty more Wild Animals sketches (11-30)."""

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

CAT = "wild_animals"


def _sitting(t, colour, *, ears=True, ear_r=62, muzzle_colour="peach", belly_colour="peach", head_r=(180, 165),
             ear_colour=None):
    """A front-facing sitting animal (bear-like). Returns the head geometry."""
    t.region("body", ellipse(500, 720, 200, 190), colour)
    if belly_colour:
        t.region("belly", ellipse(500, 740, 110, 130), belly_colour)
    t.region("left_foot", ellipse(380, 880, 85, 55), colour)
    t.region("right_foot", ellipse(620, 880, 85, 55), colour)
    if ears:
        t.region("left_ear", circle(355, 290, ear_r), ear_colour or colour)
        t.region("right_ear", circle(645, 290, ear_r), ear_colour or colour)
    head = ellipse(500, 420, *head_r)
    t.region("head", head, colour)
    t.region("muzzle", ellipse(500, 490, 90, 65), muzzle_colour)
    return head


def tiger():
    t = Template("tiger", "Tiger", CAT)
    t.region("tail", band([(650, 860), (800, 850), (860, 720), (820, 620)], 50), "orange")
    head = _sitting(t, "orange", muzzle_colour="white", belly_colour="white")
    t.region("left_inner", circle(355, 290, 30), "white", label="Left inner ear")
    t.region("right_inner", circle(645, 290, 30), "white", label="Right inner ear")
    for i, (pts) in enumerate([[(445, 240), (455, 315)], [(500, 235), (500, 330)], [(555, 240), (545, 315)]]):
        t.region(f"stripe_{i + 1}", band(pts, 30, smooth=False).intersection(head), "black", label=f"Stripe {i + 1}")
    t.eyes(500, 400, 130, 22)
    t.shape_detail(poly([(475, 470), (525, 470), (500, 495)], 6))
    t.line([(465, 515), (482, 528), (500, 512), (518, 528), (535, 515)], 9)
    for y in (640, 720, 800):
        t.line([(310, y), (360, y + 10)], 12, smooth=False)
        t.line([(690, y), (640, y + 10)], 12, smooth=False)
    return t


def bear():
    t = Template("bear", "Bear", CAT)
    _sitting(t, "brown")
    t.region("left_inner", circle(355, 290, 30), "peach", label="Left inner ear")
    t.region("right_inner", circle(645, 290, 30), "peach", label="Right inner ear")
    t.region("honey_pot", union(rect(420, 640, 160, 150, 40), rect(400, 620, 200, 40, 18)), "yellow", label="Honey pot")
    t.region("honey_label", rect(450, 690, 100, 50, 10), "orange", label="Honey label")
    t.region("left_paw", ellipse(400, 690, 50, 60, 30), "brown")
    t.region("right_paw", ellipse(600, 690, 50, 60, -30), "brown")
    t.eyes(500, 400, 130, 22)
    t.shape_detail(ellipse(500, 470, 32, 22))
    t.smile(500, 505, 60, 20)
    return t


def rhino():
    t = Template("rhino", "Rhino", CAT)
    legs = [(270, 640), (370, 650), (560, 650), (650, 640)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 90, 220, 36), "grey", label=f"Leg {i + 1}")
    t.region("body", ellipse(480, 560, 290, 190), "grey")
    t.region("ear", lens((690, 440), -100, 120, 58), "grey")
    t.region("head", ellipse(770, 520, 160, 120, 15), "grey")
    t.region("big_horn", poly([(860, 470), (920, 290), (930, 480)], 20), "white", label="Big horn")
    t.region("small_horn", poly([(800, 430), (830, 340), (850, 440)], 14), "white", label="Small horn")
    t.region("tail", band([(195, 520), (160, 600)], 22), "grey")
    t.region("bird", union(ellipse(470, 365, 55, 38), circle(510, 335, 28)), "yellow", label="Little bird")
    t.eye(780, 500, 16)
    t.smile(870, 580, 40, 14)
    t.dot(520, 330, 6)
    return t


def kangaroo():
    t = Template("kangaroo", "Kangaroo", CAT)
    t.region("tail", band([(380, 760), (240, 860), (110, 880)], 70), "orange")
    t.region("foot", ellipse(560, 880, 170, 45), "orange")
    t.region("leg", ellipse(470, 720, 120, 170, -20), "orange")
    t.region("body", ellipse(560, 600, 160, 230, 10), "orange")
    t.region("pouch", ellipse(600, 700, 100, 90).intersection(ellipse(560, 600, 160, 230, 10)), "peach")
    t.region("joey", circle(610, 610, 55), "orange", label="Baby joey")
    t.region("arm", ellipse(700, 520, 30, 75, -30), "orange")
    t.region("left_ear", lens((560, 230), -110, 160, 60), "orange", label="Back ear")
    t.region("right_ear", lens((620, 230), -70, 160, 60), "orange", label="Front ear")
    t.region("head", ellipse(620, 300, 110, 80, 15), "orange")
    t.region("snout", ellipse(710, 330, 55, 40, 15), "peach")
    t.eye(620, 280, 16)
    t.dot(750, 320, 10)
    t.dot(600, 600, 8)
    t.dot(630, 600, 8)
    return t


def crocodile():
    t = Template("crocodile", "Crocodile", CAT)
    t.region("tail", poly([(50, 610), (300, 520), (300, 680)], 30), "green")
    for i, x in enumerate((290, 540)):
        t.region(f"leg_{i + 1}", ellipse(x, 700, 52, 75), "green", label=f"Leg {i + 1}")
    body = ellipse(420, 600, 270, 115)
    t.region("body", body, "green")
    t.region("belly", ellipse(420, 660, 200, 45).intersection(body.buffer(-8)), "lightgreen")
    t.region("jaw", rect(560, 590, 390, 64, 30), "green", label="Bottom jaw")
    t.region("teeth", poly([(600, 592), (625, 562), (650, 592), (680, 562), (705, 592), (735, 562), (760, 592),
                            (790, 562), (815, 592), (845, 562), (870, 592)], 3).buffer(0), "white")
    t.region("head", rect(560, 480, 390, 92, 42), "green")
    t.region("eye_bump", circle(650, 470, 52), "green")
    t.eye(650, 465, 19)
    for x in (260, 360, 460):
        t.line([(x, 520), (x + 30, 508)], 10, smooth=False)
    t.dot(915, 510, 8)
    return t


def camel():
    t = Template("camel", "Camel", CAT)
    legs = [(270, 600), (350, 610), (540, 610), (620, 600)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 55, 290, 24), "orange", label=f"Leg {i + 1}")
    t.region("tail", band([(220, 560), (180, 670)], 32), "brown")
    t.region("body", ellipse(450, 580, 240, 110), "orange")
    t.region("hump_1", ellipse(370, 470, 100, 110), "orange", label="Back hump")
    t.region("hump_2", ellipse(540, 470, 100, 110), "orange", label="Front hump")
    t.region("blanket", ellipse(455, 520, 80, 60).intersection(halfplane_above(560)), "red")
    t.region("neck", band([(640, 560), (720, 450), (740, 320)], 80), "orange")
    t.region("head", ellipse(790, 290, 100, 60, 10), "orange")
    t.region("ear", ellipse(730, 230, 22, 40, -20), "orange")
    t.eye(780, 275, 14)
    t.smile(860, 310, 30, 10)
    return t


def deer():
    t = Template("deer", "Deer", CAT)
    legs = [(300, 640), (370, 650), (540, 650), (610, 640)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 50, 250, 22), "brown", label=f"Leg {i + 1}")
    t.region("tail", ellipse(250, 520, 40, 30, -30), "white")
    body = ellipse(460, 570, 220, 120)
    t.region("body", body, "brown")
    t.region("spots", union(*[circle(x, y, 22) for x, y in ((380, 520), (450, 500), (520, 530), (410, 590))]), "white")
    t.region("neck", poly([(560, 560), (620, 330), (700, 340), (640, 590)], 30), "brown")
    t.region("antlers", union(band([(640, 230), (600, 120), (560, 80)], 22), band([(612, 160), (660, 100)], 20),
                              band([(700, 230), (740, 120), (780, 80)], 22), band([(728, 160), (680, 100)], 20)), "peach")
    t.region("ear", ellipse(610, 260, 60, 26, -30), "brown")
    t.region("head", ellipse(700, 300, 100, 70, 30), "brown")
    t.region("nose", circle(780, 350, 26), "black")
    t.eye(700, 285, 16)
    return t


def wolf():
    t = Template("wolf", "Wolf", CAT)
    t.region("moon", circle(820, 180, 110), "yellow")
    t.region("tail", band([(620, 860), (790, 820), (850, 700)], 100), "grey")
    t.region("body", ellipse(480, 710, 170, 200), "grey")
    t.region("chest", ellipse(480, 690, 85, 130), "white")
    t.region("left_leg", rect(372, 770, 92, 150, 44), "grey")
    t.region("right_leg", rect(496, 770, 92, 150, 44), "grey")
    ear = poly([(320, 350), (330, 150), (450, 290)], 18)
    t.region("left_ear", ear, "grey")
    t.region("right_ear", mirror(ear, 480), "grey")
    head = blob([(310, 320), (480, 285), (650, 320), (690, 410), (590, 520), (480, 560), (370, 520), (270, 410)])
    t.region("head", head, "grey")
    t.region("face", blob([(390, 440), (480, 420), (570, 440), (540, 530), (480, 555), (420, 530)]), "white")
    t.eyes(480, 385, 120, 21)
    t.shape_detail(ellipse(480, 475, 28, 20))
    t.smile(480, 515, 44, 16)
    return t


def raccoon():
    t = Template("raccoon", "Raccoon", CAT)
    t.region("tail", band([(620, 860), (780, 820), (850, 680)], 90), "grey")
    for i, (a, b) in enumerate([(700, 760), (800, 720)]):
        t.region(f"tail_ring_{i + 1}", band([(a - 30, b - 60), (a + 40, b + 60)], 46, smooth=False).intersection(
            band([(620, 860), (780, 820), (850, 680)], 90)), "black", label=f"Tail ring {i + 1}")
    _sitting(t, "grey", muzzle_colour="white", belly_colour="white", ear_r=55)
    t.region("mask", union(ellipse(420, 410, 90, 55, 15), ellipse(580, 410, 90, 55, -15)), "black")
    t.eye(430, 405, 22)
    t.eye(570, 405, 22)
    t.shape_detail(ellipse(500, 475, 28, 20))
    t.smile(500, 510, 50, 16)
    return t


def squirrel():
    t = Template("squirrel", "Squirrel", CAT)
    t.region("tail", blob([(560, 850), (760, 820), (880, 640), (860, 400), (760, 280), (640, 330), (700, 480), (700, 650),
                           (600, 760)]), "orange")
    t.region("body", ellipse(450, 680, 160, 200), "orange")
    t.region("belly", ellipse(430, 700, 90, 140), "peach")
    t.region("foot", ellipse(430, 890, 110, 40), "orange")
    t.region("acorn", union(ellipse(420, 640, 60, 70).intersection(halfplane_below(600)), ellipse(420, 600, 70, 30)),
             "brown")
    t.region("ear", lens((480, 330), -80, 110, 60), "orange")
    t.region("head", circle(430, 420, 130), "orange")
    t.region("cheek", circle(360, 470, 45), "peach")
    t.eye(410, 400, 18)
    t.dot(310, 440, 12)
    t.smile(340, 480, 30, 10)
    return t


def hedgehog():
    t = Template("hedgehog", "Hedgehog", CAT)
    spikes = union(*[poly([(500 + 300 * math.cos(math.radians(a - 8)), 600 + 220 * math.sin(math.radians(a - 8))),
                           (500 + 400 * math.cos(math.radians(a)), 600 + 300 * math.sin(math.radians(a))),
                           (500 + 300 * math.cos(math.radians(a + 8)), 600 + 220 * math.sin(math.radians(a + 8)))], 8)
                      for a in range(150, 390, 16)], ellipse(450, 600, 320, 230).intersection(halfplane_above(700)))
    t.region("spikes", spikes, "brown")
    t.region("body", ellipse(560, 680, 260, 150), "peach")
    t.region("left_foot", ellipse(430, 830, 60, 30), "brown")
    t.region("right_foot", ellipse(650, 830, 60, 30), "brown")
    t.region("ear", circle(640, 540, 36), "peach")
    t.region("nose", circle(820, 680, 30), "black")
    t.region("apple", union(circle(300, 350, 70), lens((300, 285), -60, 70, 36)), "red")
    t.eye(720, 640, 18)
    t.smile(760, 710, 50, 16)
    return t


def sloth():
    t = Template("sloth", "Sloth", CAT)
    t.region("branch", band([(40, 230), (500, 210), (960, 250)], 60), "brown")
    t.region("leaf_1", lens((200, 230), 110, 120, 60), "green", label="Leaf 1")
    t.region("leaf_2", lens((820, 240), 70, 120, 60), "lightgreen", label="Leaf 2")
    t.region("left_arm", band([(380, 560), (360, 380), (390, 230)], 70), "brown")
    t.region("right_arm", band([(620, 560), (640, 380), (610, 230)], 70), "brown")
    t.region("body", ellipse(500, 650, 190, 240), "brown")
    t.region("belly", ellipse(500, 690, 110, 160), "peach")
    t.region("head", circle(500, 450, 130), "brown")
    t.region("face", ellipse(500, 470, 100, 80), "peach")
    t.region("left_patch", ellipse(450, 460, 40, 25, 20), "brown")
    t.region("right_patch", ellipse(550, 460, 40, 25, -20), "brown")
    t.sleepy_eye(450, 460, 30, 9)
    t.sleepy_eye(550, 460, 30, 9)
    t.shape_detail(ellipse(500, 490, 18, 12))
    t.smile(500, 515, 40, 12)
    return t


def gorilla():
    t = Template("gorilla", "Gorilla", CAT)
    t.region("left_arm", band([(330, 560), (250, 720), (280, 880)], 100), "black")
    t.region("right_arm", band([(670, 560), (750, 720), (720, 880)], 100), "black")
    t.region("body", ellipse(500, 690, 200, 220), "black")
    t.region("chest", ellipse(500, 680, 120, 140), "grey")
    t.region("left_foot", ellipse(400, 900, 80, 40), "black")
    t.region("right_foot", ellipse(600, 900, 80, 40), "black")
    t.region("left_ear", circle(350, 380, 40), "grey")
    t.region("right_ear", circle(650, 380, 40), "grey")
    t.region("head", ellipse(500, 360, 150, 150), "black")
    t.region("face", union(ellipse(500, 400, 115, 100), circle(450, 340, 55), circle(550, 340, 55)), "grey")
    t.region("banana", lens((630, 820), -40, 220, 70), "yellow")
    t.eyes(500, 350, 100, 18)
    t.dot(480, 410, 10)
    t.dot(520, 410, 10)
    t.smile(500, 445, 60, 18)
    return t


def cheetah():
    t = Template("cheetah", "Cheetah", CAT)
    t.region("tail", band([(215, 490), (130, 520), (90, 640), (140, 720)], 36), "yellow")
    legs = [(240, 600), (320, 610), (520, 610), (600, 600)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 56, 280, 26), "yellow", label=f"Leg {i + 1}")
    body = ellipse(440, 540, 260, 110)
    t.region("body", body, "yellow")
    t.region("spots", union(*[circle(x, y, 22) for x, y in ((300, 520), (370, 480), (440, 540), (510, 490), (580, 540),
                                                             (350, 590), (480, 600))]).intersection(body), "black")
    t.region("left_ear", circle(680, 330, 40), "yellow")
    t.region("right_ear", circle(800, 330, 40), "yellow")
    t.region("head", circle(740, 420, 110), "yellow")
    t.region("muzzle", ellipse(740, 470, 60, 40), "white")
    t.eyes(740, 400, 80, 16)
    t.line([(700, 420), (690, 480)], 9)
    t.line([(780, 420), (790, 480)], 9)
    t.shape_detail(ellipse(740, 455, 18, 12))
    return t


def polar_bear():
    t = Template("polar_bear", "Polar Bear", CAT)
    t.region("ice", poly([(80, 880), (220, 820), (800, 820), (930, 880), (900, 950), (100, 950)], 20), "skyblue",
             label="Ice")
    _sitting(t, "white", muzzle_colour="white", belly_colour=None, ear_r=55)
    t.region("scarf", band([(340, 580), (500, 610), (660, 580)], 50), "red")
    t.region("scarf_end", rect(560, 580, 70, 140, 20), "red", label="Scarf end")
    t.region("fish", union(ellipse(240, 760, 80, 40), poly([(160, 760), (110, 720), (110, 800)], 10)), "orange")
    t.eyes(500, 400, 130, 22)
    t.shape_detail(ellipse(500, 470, 32, 22))
    t.smile(500, 505, 60, 20)
    return t


def frog():
    t = Template("frog", "Frog", CAT)
    t.region("left_leg", ellipse(290, 760, 120, 80, -20), "green")
    t.region("right_leg", ellipse(710, 760, 120, 80, 20), "green")
    t.region("body", ellipse(500, 640, 250, 220), "green")
    t.region("belly", ellipse(500, 690, 150, 140), "lightgreen")
    t.region("left_eye_bump", circle(370, 380, 95), "green", label="Left eye")
    t.region("right_eye_bump", circle(630, 380, 95), "green", label="Right eye")
    t.region("left_hand", ellipse(390, 850, 70, 35), "green")
    t.region("right_hand", ellipse(610, 850, 70, 35), "green")
    t.region("left_cheek", circle(330, 560, 40), "pink")
    t.region("right_cheek", circle(670, 560, 40), "pink")
    t.region("crown", poly([(430, 260), (450, 190), (480, 240), (500, 170), (520, 240), (550, 190), (570, 260)], 6),
             "yellow")
    t.region("crown_band", rect(420, 250, 160, 40, 10), "yellow", label="Crown band")
    t.eye(370, 380, 36)
    t.eye(630, 380, 36)
    t.smile(500, 540, 220, 60)
    return t


def snake():
    t = Template("snake", "Snake", CAT)
    path = [(180, 820), (360, 870), (520, 800), (480, 680), (330, 620), (300, 500), (440, 440), (600, 470), (700, 420)]
    t.region("body", band(path, 110), "green")
    for i, (x, y) in enumerate([(360, 868), (480, 700), (310, 560), (520, 452)]):
        t.region(f"stripe_{i + 1}", circle(x, y, 40).intersection(band(path, 110)), "yellow", label=f"Spot {i + 1}")
    t.region("head", ellipse(740, 380, 130, 95, -15), "green")
    t.region("tongue", union(band([(860, 380), (930, 390)], 16, smooth=False), band([(930, 390), (960, 360)], 14,
                                                                                         smooth=False),
                             band([(930, 390), (960, 420)], 14, smooth=False)), "red")
    t.eyes(740, 350, 80, 18)
    t.smile(780, 410, 60, 18)
    return t


def moose():
    t = Template("moose", "Moose", CAT)
    legs = [(270, 640), (350, 650), (540, 650), (620, 640)]
    for i, (x, y) in enumerate(legs):
        t.region(f"leg_{i + 1}", rect(x, y, 60, 250, 26), "brown", label=f"Leg {i + 1}")
    t.region("body", ellipse(450, 580, 250, 140), "brown")
    t.region("left_antler", union(ellipse(615, 245, 105, 55, -20), *[circle(535 + 40 * k, 190 - 12 * k, 30) for k in range(4)]),
             "peach", label="Back antler")
    t.region("right_antler", union(ellipse(830, 245, 105, 55, 20), *[circle(770 + 40 * k, 180 + 8 * k, 30) for k in range(4)]),
             "peach", label="Front antler")
    t.region("head", union(ellipse(720, 350, 100, 120), ellipse(760, 450, 90, 70)), "brown")
    t.region("nose", ellipse(790, 470, 60, 45), "peach")
    t.region("beard", ellipse(720, 560, 30, 50), "brown")
    t.eyes(720, 330, 70, 15)
    t.dot(770, 470, 9)
    t.dot(810, 470, 9)
    return t


def beaver():
    t = Template("beaver", "Beaver", CAT)
    t.region("tail", ellipse(760, 830, 170, 70, -15), "brown")
    t.region("body", ellipse(480, 680, 180, 210), "orange")
    t.region("belly", ellipse(480, 700, 100, 140), "peach")
    t.region("left_foot", ellipse(380, 890, 80, 40), "orange")
    t.region("right_foot", ellipse(580, 890, 80, 40), "orange")
    t.region("log", rect(320, 610, 320, 90, 45), "brown", label="Log")
    t.region("left_ear", circle(370, 300, 40), "orange")
    t.region("right_ear", circle(590, 300, 40), "orange")
    t.region("head", circle(480, 400, 140), "orange")
    t.region("muzzle", ellipse(480, 450, 80, 55), "peach")
    t.region("teeth", rect(455, 485, 50, 50, 8), "white")
    t.eyes(480, 380, 110, 18)
    t.shape_detail(ellipse(480, 430, 24, 16))
    t.line([(480, 488), (480, 532)], 7, smooth=False)
    for x in (680, 750, 820):
        t.line([(x, 790), (x + 20, 870)], 8, smooth=False)
    return t


def skunk():
    t = Template("skunk", "Skunk", CAT)
    tail = blob([(560, 860), (760, 830), (880, 640), (850, 400), (730, 300), (640, 360), (700, 500), (690, 680)])
    t.region("tail", tail, "black")
    t.region("tail_stripe", band([(620, 820), (780, 720), (800, 520), (720, 380)], 60).intersection(tail), "white",
             label="Tail stripe")
    _sitting(t, "black", muzzle_colour="white", belly_colour=None, ear_r=50)
    t.region("head_stripe", band([(500, 260), (500, 420)], 50), "white", label="Head stripe")
    t.region("flower", union(*[circle(380 + 30 * math.cos(math.radians(a)), 720 + 30 * math.sin(math.radians(a)), 26)
                                for a in range(0, 360, 60)]), "pink")
    t.eyes(500, 410, 130, 22)
    t.shape_detail(ellipse(500, 470, 30, 20))
    t.smile(500, 505, 60, 20)
    return t


TEMPLATES = [
    tiger,
    bear,
    rhino,
    kangaroo,
    crocodile,
    camel,
    deer,
    wolf,
    raccoon,
    squirrel,
    hedgehog,
    sloth,
    gorilla,
    cheetah,
    polar_bear,
    frog,
    snake,
    moose,
    beaver,
    skunk,
]
