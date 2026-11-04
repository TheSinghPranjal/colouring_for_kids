from shapely import affinity

from lib import Template, band, blob, circle, ellipse, lens, poly, rect, union

CAT = "fruits_vegetables"


def apple():
    t = Template("apple", "Apple", CAT)
    t.region("stem", band([(500, 400), (510, 300), (530, 220)], 36), "brown")
    t.region("leaf", lens((520, 290), -25, 220, 110), "green")
    body = union(circle(395, 580, 235), circle(605, 580, 235), ellipse(500, 720, 250, 180))
    t.region("body", body, "red")
    t.region("shine", lens((290, 560), -70, 150, 60), "white")
    t.eyes(500, 600, 130, 22)
    t.smile(500, 670, 90, 34)
    return t


def banana():
    t = Template("banana", "Banana", CAT)
    t.region("fruit", union(band([(500, 540), (495, 300), (482, 200)], 160), circle(482, 195, 80)), "white")
    t.region("left_peel", lens((470, 525), 122, 290, 130), "yellow")
    t.region("right_peel", lens((530, 525), 58, 290, 130), "yellow")
    peel = union(band([(500, 530), (520, 680), (480, 840)], 190), rect(405, 500, 190, 60, 24))
    t.region("peel", peel, "yellow")
    t.region("stem", rect(440, 860, 70, 80, 20), "brown")
    t.eyes(487, 300, 80, 18)
    t.smile(487, 360, 56, 22)
    t.line([(470, 610), (490, 720), (468, 810)], 9)
    return t


def strawberry():
    t = Template("strawberry", "Strawberry", CAT)
    t.region("stem", band([(500, 330), (510, 230), (530, 170)], 34), "green")
    body = blob([(500, 920), (330, 790), (245, 570), (300, 395), (500, 360), (700, 395), (755, 570), (670, 790)])
    t.region("body", body, "red")
    leaves = union(*[lens((500, 370), a, 175, 85) for a in (-175, -140, -95, -40, -5)])
    t.region("leafy_top", leaves, "green", label="Leafy top")
    t.region("shine", lens((330, 600), -75, 130, 50).intersection(body.buffer(-20)), "white")
    for x, y in [(410, 500), (590, 500), (500, 560), (380, 640), (620, 640), (500, 690), (430, 770), (570, 770)]:
        t.closed_line([(x, y - 22), (x + 13, y), (x, y + 22), (x - 13, y)], 8)
    return t


def carrot():
    t = Template("carrot", "Carrot", CAT)
    for i, a in enumerate((-125, -90, -55)):
        t.region(f"leaf_{i + 1}", lens((500, 300), a, 240, 95), ["green", "lightgreen", "green"][i], label=f"Leaf {i + 1}")
    body = poly([(355, 280), (645, 280), (525, 930), (475, 930)], 60)
    t.region("body", body, "orange")
    for i, y in enumerate((440, 590, 730)):
        stripe = affinity.rotate(rect(250, y, 500, 46), -8, origin=(500, y))
        t.region(f"band_{i + 1}", stripe.intersection(body), "yellow", label=f"Band {i + 1}")
    t.eyes(500, 370, 100, 20)
    t.smile(500, 400, 60, 20)
    return t


def corn():
    t = Template("corn", "Corn", CAT)
    t.region("stalk", rect(455, 850, 90, 110, 24), "green")
    cob = union(band([(500, 230), (500, 760)], 300))
    t.region("cob_top", cob, "yellow", label="Cob top")
    xs = [(340, 500), (500, 660)]
    ys = [(320, 480), (480, 640), (640, 900)]
    k = 1
    for y0, y1 in ys:
        for x0, x1 in xs:
            cell = rect(x0, y0, x1 - x0, y1 - y0).intersection(cob)
            t.region(f"kernels_{k}", cell, ["yellow", "orange"][(k + (k - 1) // 2) % 2], label=f"Kernels {k}")
            k += 1
    left_husk = lens((505, 905), -116, 470, 175)
    right_husk = lens((495, 905), -64, 470, 175)
    t.region("left_husk", left_husk, "green", label="Left leaf")
    t.region("right_husk", right_husk, "lightgreen", label="Right leaf")
    husks = union(left_husk, right_husk).buffer(30)
    from shapely.geometry import Point

    for x0, x1 in xs:
        for y0, y1 in ys:
            cx = (x0 + x1) / 2
            for dy in (0.3, 0.65):
                y = y0 + (y1 - y0) * dy
                if not husks.contains(Point(cx, y)) and y < 800:
                    t.arc(cx, y - 10, 22, 30, 150, 7)
    return t


def grapes():
    t = Template("grapes", "Grapes", CAT)
    t.region("stem", band([(500, 200), (500, 320)], 28), "brown")
    t.region("leaf", lens((500, 280), -40, 180, 100), "green")
    positions = [(430, 400), (570, 400), (360, 500), (500, 500), (640, 500), (430, 600), (570, 600), (500, 700)]
    colours = ["purple", "purple", "purple", "pink", "purple", "purple", "pink", "purple"]
    for i, ((x, y), c) in enumerate(zip(positions, colours)):
        t.region(f"grape_{i + 1}", circle(x, y, 55), c, label=f"Grape {i + 1}")
    return t


def watermelon():
    t = Template("watermelon", "Watermelon", CAT)
    t.region("rind", ellipse(500, 560, 320, 260), "green")
    t.region("flesh", ellipse(500, 560, 260, 200), "red")
    t.region("seed_1", ellipse(420, 500, 28, 42, -20), "black")
    t.region("seed_2", ellipse(520, 480, 28, 42, 10), "black")
    t.region("seed_3", ellipse(580, 560, 28, 42, -15), "black")
    t.region("seed_4", ellipse(450, 620, 28, 42, 20), "black")
    t.region("seed_5", ellipse(550, 640, 28, 42, -10), "black")
    t.eyes(500, 540, 70, 14)
    t.smile(500, 600, 55, 18)
    return t


def pear():
    t = Template("pear", "Pear", CAT)
    t.region("stem", band([(500, 220), (520, 160)], 24), "brown")
    t.region("leaf", lens((530, 180), 30, 120, 60), "green")
    body = union(ellipse(500, 420, 120, 140), ellipse(500, 620, 180, 200))
    t.region("body", body, "yellow")
    t.region("blush", circle(400, 580, 40), "pink")
    t.eyes(500, 500, 80, 16)
    t.smile(500, 560, 55, 18)
    return t


def tomato():
    t = Template("tomato", "Tomato", CAT)
    t.region("body", circle(500, 560, 240), "red")
    t.region("stem", band([(500, 340), (500, 220)], 40), "green")
    t.region("leaf_1", lens((500, 280), -120, 160, 70), "green")
    t.region("leaf_2", lens((500, 280), -60, 160, 70), "lightgreen")
    t.region("leaf_3", lens((500, 280), 0, 160, 70), "green")
    t.region("highlight", lens((380, 480), -50, 100, 50), "pink")
    t.eyes(500, 520, 90, 16)
    t.smile(500, 590, 60, 20)
    return t


def broccoli():
    t = Template("broccoli", "Broccoli", CAT)
    t.region("stalk", rect(420, 560, 160, 300, 40), "lightgreen")
    t.region("floret_1", circle(400, 420, 110), "green")
    t.region("floret_2", circle(500, 340, 130), "green")
    t.region("floret_3", circle(600, 420, 110), "green")
    t.region("floret_4", circle(450, 500, 90), "green")
    t.region("floret_5", circle(550, 500, 90), "green")
    t.eyes(500, 700, 70, 14)
    t.smile(500, 760, 50, 16)
    return t


TEMPLATES = [apple, banana, strawberry, carrot, corn, grapes, watermelon, pear, tomato, broccoli]
