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


TEMPLATES = [bird, duck, owl, butterfly, bee]
