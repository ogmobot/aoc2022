with open("input09.txt") as f:
    lines = f.readlines()

# grid?
grid = {}
for r, line in enumerate(lines):
    for c, char in enumerate(line):
        grid[(r, c)] = char

# distance?
def manhattan(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1])


head = (0, 0)
tail = (0, 0)

def sign(x):
    if x == 0: return 0
    return x // abs(x)

def step_tail(head, tail):
    # returns new position of tail
    hr, hc = head
    tr, tc = tail
    r, c = tail
    if tr < hr:
        r = tr + 1
    elif tr > hr:
        r = tr - 1
    if tc < hc:
        c = tc + 1
    elif tc > hc:
        c = tc - 1
    return (r, c)

def maxdist(a, b):
    return max(abs(a[0]-b[0]), abs(a[1]-b[1]))

seen = set()
seen.add(tail)
r, c = head
for line in lines:
    parts = line.strip().split()
    for _ in range(int(parts[1])):
        if parts[0] == "R":
            c += 1
        if parts[0] == "L":
            c -= 1
        if parts[0] == "D":
            r += 1
        if parts[0] == "U":
            r -= 1
        head = (r, c)
        if maxdist(head, tail) > 1:
            tail = step_tail(head, tail)
        seen.add(tail)

print(len(seen))

seen = set()
seen.add((0, 0))
knots = [(0, 0) for _ in range(10)]
for line in lines:
    parts = line.strip().split()
    for _ in range(int(parts[1])):
        for i, knot in enumerate(knots.copy()):
            if i == 0: # head
                r, c = knot
                if parts[0] == "R":
                    c += 1
                if parts[0] == "L":
                    c -= 1
                if parts[0] == "D":
                    r += 1
                if parts[0] == "U":
                    r -= 1
                knots[0] = (r, c)
            else:
                if maxdist(knot, knots[i - 1]) > 1:
                    knots[i] = step_tail(knots[i - 1], knot)
                if i == len(knots) - 1:
                    seen.add(knots[i])

print(len(seen))
