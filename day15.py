S_SENSOR = "s"
S_BEACON = "b"

def manhattan(a, b):
    return abs(a[0]-b[0]) + abs(a[1]-b[1])

def within_radius(sensor, point):
    return manhattan(point, (sensor["x"], sensor["y"])) <= sensor["r"]

with open("input15.txt") as f:
    lines = [l.strip() for l in f]

sensors = []
beacons = set()

for line in lines:
    parts = line.split()
    xcoord = int(parts[2][2:].strip(","))
    ycoord = int(parts[3][2:].strip(":"))
    beaconx = int(parts[-2][2:].strip(","))
    beacony = int(parts[-1][2:])
    radius = manhattan((xcoord, ycoord), (beaconx, beacony))
    sensors.append({
        "x": xcoord,
        "y": ycoord,
        "r": radius,
        "beacon": (beaconx, beacony)
    })
    beacons.add((beaconx, beacony))

# find interval on y=2000000 for each sensor
def get_interval(sensor, yval):
    if sensor["y"] < yval and sensor["y"] + sensor["r"] + 1 < yval:
        #return (sensor["y"], sensor["y"])
        return None
    if sensor["y"] > yval and sensor["y"] - sensor["r"] - 1 > yval:
        #return (sensor["y"], sensor["y"])
        return None
    if yval >= sensor["y"]: # row is below sensor
        halflen = sensor["y"] + sensor["r"] - yval
    if yval < sensor["y"]:
        halflen = yval - (sensor["y"] - sensor["r"])
    return (sensor["x"] - halflen, sensor["x"] + halflen)

def find_missing(intervals, maxval):
    invisible = [ (0, maxval) ]
    for interval_b in intervals:
        lo_b, hi_b = interval_b
        to_delete = []
        new_intervals = []
        for i, interval_w in enumerate(invisible):
            lo_w, hi_w = interval_w
            if ((lo_b > hi_w) or (hi_b < lo_w)):
                # no overlap
                pass
            elif ((lo_b <= lo_w) and (hi_b >= hi_w)):
                # covers
                to_delete.append(i)
            elif ((lo_b > lo_w) and (hi_b < hi_w)):
                # sits inside
                to_delete.append(i)
                new_intervals.append((lo_w, lo_b - 1))
                new_intervals.append((hi_b + 1, hi_w))
            elif lo_w < lo_b:
                # high end of radius overlaps
                invisible[i] = (lo_w, lo_b - 1)
            elif hi_w > hi_b:
                # low end of radius overlaps
                invisible[i] = (hi_b + 1, hi_w)
        #print(invisible)
        #print(to_delete)
        for i in sorted(to_delete, reverse=True):
            invisible.pop(i)
        invisible += new_intervals
    return invisible

'''
max_radius = max(b["r"] for b in sensors)
x_min = min(b["x"] for b in sensors)
x_max = max(b["x"] for b in sensors)

print(x_min - max_radius, x_max + max_radius)
y=2000000
total = 0
for x in range(x_min - max_radius, x_max + max_radius):
    total += 1
    for s in sensors:
        if within_radius(s, (x, y)) and (x, y) not in beacons:
            break
    else:
        total -= 1
print(total)
'''
# takes ~3 min

'''
y = 2000000
intervals = [get_interval(s, y) for s in sensors]
min_x = min(i[0] for i in intervals)
max_x = min(i[1] for i in intervals)
'''

MAXVAL = 4000000
for y in range(MAXVAL + 1):
    if y % 10000 == 0: print(f"{y=}")
    intervals = [get_interval(s, y) for s in sensors]
    intervals = [i for i in intervals if i]
    xs_left = set(i[0] - 1 for i in intervals)
    xs_right = set(i[1] + 1 for i in intervals)
    xs_of_interest = xs_left.intersection(xs_right)
    xs_of_interest = [x for x in xs_of_interest if x >= 0 and x <= MAXVAL]
    visible = False
    for x in xs_of_interest:
        visible = False
        for s in sensors:
            if within_radius(s, (x, y)):
                visible = True
                break
        if not visible:
            print(x, y)
            print((4000000 * x) + y)
            break
    else:
        continue
    break
