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
    sensors.append({"x": xcoord, "y": ycoord, "r": radius})
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

def merge_intervals(intervals):
    did_merge = True
    while did_merge:
        did_merge = False
        merged = []
        for i in intervals:
            for m in merged.copy():
                if i[0] >= m[0] and i[1] <= m[1]:
                    did_merge = True
                    break # new interval contained within old
                elif m[0] >= i[0] and m[1] <= i[1]:
                    merged.remove(m)
                    merged.append(i)
                    did_merge = True
                    break # old interval contained within new
                elif i[0] <= m[0] and i[1] >= m[0]:
                    # new interval overlaps leftmost point of old
                    merged.remove(m)
                    merged.append((i[0], m[1]))
                    did_merge = True
                    break
                elif i[0] <= m[1] and i[1] >= m[1]:
                    # new interval overlaps rightmost point of old
                    merged.remove(m)
                    merged.append((m[0], i[1]))
                    did_merge = True
                    break
            else:
                merged.append(i)
        intervals = merged
    return merged

def outline_of(sensor):
    x = sensor["x"]
    y = sensor["y"] - sensor["r"] - 1
    while y < sensor["y"]:
        yield (x, y)
        x += 1
        y += 1
    while x > sensor["x"]:
        yield (x, y)
        x -= 1
        y += 1
    while y > sensor["y"]:
        yield (x, y)
        x -= 1
        y -= 1
    while x < sensor["x"]:
        yield (x, y)
        x += 1
        y -= 1

y = 2000000
intervals = [get_interval(s, y) for s in sensors]
intervals = [i for i in intervals if i]
intervals = merge_intervals(intervals)
total = 0
for i in intervals:
    total += i[1] - i[0]
print(total)

MAXVAL = 4000000
# takes about 20s
sensors.sort(key=lambda s: s.get("r"))
for s in sensors:
    #print(f"{s['r']=}")
    nearby = [a for a in sensors if a["r"] + s["r"] + 1 >= manhattan((s["x"], s["y"]), (a["x"], a["y"]))]
    for x, y in outline_of(s):
        if x >= 0 and x <= MAXVAL and y >= 0 and y <= MAXVAL:
            if not any(within_radius(a, (x, y)) for a in nearby):
                #print(x, y)
                print((4000000 * x) + y)
                break
    else:
        continue
    break
