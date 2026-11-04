from lib import Template, band, circle, ellipse, lens, mirror, petal, poly, rect, union

CAT = "birds_insects"


def _bird_foot(x, y):
    return union(
        band([(x, y), (x - 4, y + 90)], 20, smooth=False),
        band([(x - 4, y + 90), (x - 46, y + 110)], 16, smooth=False),
        band([(x - 4, y + 90), (x - 2, y + 122)], 16, smooth=False),
        band([(x - 4, y + 90), (x + 36, y + 110)], 16, smooth=False),
    )


def bird():
    t = Template("bird", "Bird", CAT)
    t.region("left_foot", _bird_foot(450, 730), "orange")
    t.region("right_foot", _bird_foot(550, 730), "orange")
    t.region("tail", union(lens((690, 560), -32, 230, 100), lens((690, 570), -2, 215, 90)), "blue")
    body = ellipse(510, 560, 240, 200)
    t.region("body", body, "skyblue")
    t.region("belly", ellipse(440, 650, 150, 110).intersection(body.buffer(-10)), "yellow")
    t.region("wing", lens((470, 520), 15, 280, 140), "blue")
    t.region("head", circle(360, 380, 130), "skyblue")
    t.region("beak", poly([(240, 365), (150, 395), (240, 430)], 12), "orange")
    t.eye(340, 360, 22)
    t.region("cheek", circle(300, 432, 26), "pink")
    return t


def duck():
    t = Template("duck", "Duck", CAT)
    for i, x in enumerate((430, 570)):
        foot = union(
            band([(x, 760), (x, 830)], 26, smooth=False),
            poly([(x, 820), (x - 70, 895), (x + 70, 895)], 14),
        )
        t.region(["left_foot", "right_foot"][i], foot, "orange")
    body = union(
        ellipse(520, 640, 260, 165),
        poly([(700, 560), (830, 470), (780, 650)], 30),
        band([(350, 450), (410, 580)], 130),
    )
    t.region("body", body, "yellow")
    t.region("wing", lens((420, 650), -12, 330, 150), "orange")
    t.region("head", circle(330, 380, 125), "yellow")
    t.region("beak", ellipse(200, 415, 85, 36, -5), "orange")
    t.eye(340, 350, 22)
    t.line([(130, 418), (250, 412)], 8, smooth=False)
    return t


def owl():
    t = Template("owl", "Owl", CAT)
    t.region("branch", band([(110, 840), (500, 830), (890, 845)], 60), "brown")
    body = ellipse(500, 590, 230, 260)
    t.region("body", body, "brown")
    t.region("belly", ellipse(500, 660, 140, 160).intersection(body.buffer(-10)), "peach")
    t.region("left_wing", ellipse(285, 610, 72, 175, 10), "brown")
    t.region("right_wing", ellipse(715, 610, 72, 175, -10), "brown")
    head = union(
        ellipse(500, 380, 220, 165),
        poly([(290, 340), (305, 180), (420, 260)], 16),
        poly(mirror_pts([(290, 340), (305, 180), (420, 260)]), 16),
    )
    t.region("head", head, "brown")
    t.region("left_face", circle(415, 385, 92), "peach", label="Left face circle")
    t.region("right_face", circle(585, 385, 92), "peach", label="Right face circle")
    t.region("left_eye", circle(415, 385, 52), "yellow")
    t.region("right_eye", circle(585, 385, 52), "yellow")
    t.region("beak", poly([(465, 445), (535, 445), (500, 510)], 12), "orange")
    t.region(
        "feet",
        union(*[circle(420 + dx, 835, 22) for dx in (-40, 0, 40)], *[circle(580 + dx, 835, 22) for dx in (-40, 0, 40)]),
        "orange",
    )
    t.eye(415, 385, 24)
    t.eye(585, 385, 24)
    for row, y in enumerate((610, 680, 750)):
        n = 3 if row != 1 else 2
        for k in range(n):
            x = 500 + (k - (n - 1) / 2) * 75
            t.arc(x, y - 18, 30, 30, 150, 8)
    return t


def mirror_pts(points, axis_x=500):
    return [(2 * axis_x - x, y) for x, y in points]


def butterfly():
    t = Template("butterfly", "Butterfly", CAT)
    upper = ellipse(320, 370, 190, 160, 30)
    lower = ellipse(355, 650, 140, 125, -25)
    t.region("left_top_wing", upper, "purple")
    t.region("left_bottom_wing", lower, "pink")
    t.region("right_top_wing", mirror(upper), "purple")
    t.region("right_bottom_wing", mirror(lower), "pink")
    t.region("left_top_spot", ellipse(300, 360, 95, 70, 30), "skyblue")
    t.region("left_bottom_spot", circle(350, 655, 58), "yellow")
    t.region("right_top_spot", mirror(ellipse(300, 360, 95, 70, 30)), "skyblue")
    t.region("right_bottom_spot", mirror(circle(350, 655, 58)), "yellow")
    t.region("left_antenna", union(band([(482, 230), (450, 160), (400, 110)], 16), circle(392, 102, 28)), "black")
    t.region(
        "right_antenna", mirror(union(band([(482, 230), (450, 160), (400, 110)], 16), circle(392, 102, 28))), "black"
    )
    t.region("body", band([(500, 310), (500, 780)], 74), "brown")
    t.region("head", circle(500, 265, 60), "brown")
    t.eyes(500, 258, 46, 11)
    t.smile(500, 285, 30, 10, 8)
    return t


def bee():
    t = Template("bee", "Bee", CAT)
    t.region("back_wing", ellipse(560, 330, 95, 140, 25), "skyblue")
    t.region("front_wing", ellipse(670, 350, 95, 140, 45), "white")
    t.region("stinger", poly([(770, 545), (880, 590), (770, 630)], 12), "black")
    body = ellipse(570, 590, 225, 165)
    t.region("body", body, "yellow")
    for i, x in enumerate((505, 640)):
        t.region(f"stripe_{i + 1}", rect(x, 300, 72, 600).intersection(body), "black", label=f"Stripe {i + 1}")
    t.region("left_antenna", union(band([(310, 420), (270, 330), (230, 290)], 16), circle(222, 282, 26)), "black")
    t.region("right_antenna", union(band([(365, 410), (380, 310), (410, 260)], 16), circle(418, 252, 26)), "black")
    t.region("head", circle(330, 530, 130), "yellow")
    t.eyes(330, 510, 90, 20)
    t.smile(330, 565, 70, 26)
    t.region("cheek", circle(272, 572, 24), "pink")
    return t


def ladybug():
    t = Template("ladybug", "Ladybug", CAT)
    t.region("body", ellipse(500, 560, 220, 200), "red")
    t.region("head", ellipse(500, 340, 110, 90), "black")
    t.region("spot_1", circle(400, 500, 40), "black")
    t.region("spot_2", circle(600, 500, 40), "black")
    t.region("spot_3", circle(450, 620, 35), "black")
    t.region("spot_4", circle(550, 620, 35), "black")
    t.region("left_leg", band([(340, 560), (260, 640)], 22), "black")
    t.region("right_leg", band([(660, 560), (740, 640)], 22), "black")
    t.eyes(500, 330, 70, 14)
    t.smile(500, 370, 40, 14)
    return t


def snail():
    t = Template("snail", "Snail", CAT)
    t.region("shell", circle(520, 480, 180), "orange")
    t.region("shell_spiral", circle(520, 480, 90), "yellow")
    t.region("body", ellipse(400, 700, 220, 90), "peach")
    t.region("head", ellipse(220, 640, 80, 70), "peach")
    t.region("left_antenna", band([(200, 600), (150, 480)], 22), "peach")
    t.region("right_antenna", band([(240, 600), (280, 470)], 22), "peach")
    t.region("left_tip", circle(145, 470, 32), "pink")
    t.region("right_tip", circle(285, 460, 32), "pink")
    t.eyes(210, 630, 40, 10)
    t.smile(210, 660, 25, 10)
    return t


def parrot():
    t = Template("parrot", "Parrot", CAT)
    t.region("body", ellipse(500, 580, 140, 180), "green")
    t.region("belly", ellipse(500, 620, 80, 100), "yellow")
    t.region("head", circle(500, 340, 110), "red")
    t.region("beak", poly([(480, 350), (620, 390), (480, 430)], 14), "orange")
    t.region("wing", ellipse(380, 560, 90, 140, 20), "blue")
    t.region("tail", band([(500, 740), (460, 880), (540, 900), (520, 760)], 40), "red")
    t.region("perch", rect(300, 900, 400, 30, 12), "brown")
    t.eyes(480, 320, 40, 12)
    return t


def penguin():
    t = Template("penguin", "Penguin", CAT)
    t.region("body", ellipse(500, 560, 170, 240), "black")
    t.region("belly", ellipse(500, 600, 110, 170), "white")
    t.region("head", circle(500, 300, 100), "black")
    t.region("face", ellipse(500, 320, 60, 55), "white")
    t.region("beak", poly([(455, 330), (545, 330), (500, 400)], 12), "orange")
    t.region("left_flipper", ellipse(330, 560, 50, 110, 25), "black")
    t.region("right_flipper", ellipse(670, 560, 50, 110, -25), "black")
    t.region("left_foot", ellipse(430, 820, 55, 35), "orange")
    t.region("right_foot", ellipse(570, 820, 55, 35), "orange")
    t.eyes(500, 300, 50, 12)
    return t


def dragonfly():
    t = Template("dragonfly", "Dragonfly", CAT)
    t.region("body", band([(300, 500), (700, 500)], 50), "teal")
    t.region("head", circle(260, 500, 55), "teal")
    t.region("tail", band([(700, 500), (880, 500)], 28), "blue")
    t.region("wing_tl", ellipse(420, 360, 140, 60, -20), "skyblue")
    t.region("wing_tr", ellipse(580, 360, 140, 60, 20), "skyblue")
    t.region("wing_bl", ellipse(420, 640, 140, 60, 20), "skyblue")
    t.region("wing_br", ellipse(580, 640, 140, 60, -20), "skyblue")
    t.eyes(250, 490, 40, 12)
    t.smile(240, 520, 25, 10)
    return t


TEMPLATES = [bird, duck, owl, butterfly, bee, ladybug, snail, parrot, penguin, dragonfly]
