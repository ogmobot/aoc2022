from math import gcd

def manhattan(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1])

def lcm(a, b):
    return int(a * b // gcd(a, b))

def update_blizzards(grid, blizzards):
    res = []
    for b in blizzards:
        r, c, facing = b
        deltas = {"<": (0, -1), ">": (0, 1), "^": (-1, 0), "v": (1, 0)}
        delta = deltas.get(facing)
        r, c = r + delta[0], c + delta[1]
        if grid[(r, c)] == "#":
            # wrap
            r, c = r - delta[0], c - delta[1]
            while grid[(r, c)] != "#":
                r, c = r - delta[0], c - delta[1]
            r, c = r + delta[0], c + delta[1]
        res.append((r, c, facing))
    return res

def cache_blizzards(grid, blizzards, amount):
    res = {}
    # {t: set of blizzard coords}
    for t in range(amount):
        res[t] = set((b[0], b[1]) for b in blizzards)
        blizzards = update_blizzards(grid, blizzards)
    return res

def blizzard_at(bcache, t, r, c):
    return (r, c) in bcache[t]

def bfs(grid, bcache, checkpoints, b_period):
    paths = [(0,) + checkpoints.pop(0)]
    seen = set()
    while paths:
        t, r, c = paths.pop(0)
        if (t, r, c) in seen:
            continue
        seen.add((t, r, c))
        if (r, c) == checkpoints[0]:
            checkpoints = checkpoints[1:]
            if len(checkpoints) == 0:
                return t
            paths = []
        adjacents = [
            (r + dr, c + dc) for dr, dc in [
                (0, 0), (-1, 0), (0, -1), (1, 0), (0, 1),
            ]
        if
            (not blizzard_at(bcache, (t + 1) % b_period, r + dr, c + dc)) and
            (grid.get((r + dr, c + dc), "#") == ".")
        ]
        for new_loc in adjacents:
            paths.append((t + 1,) + new_loc)
    return None

with open("input24.txt") as f:
    lines = [l.strip() for l in f]

blizzards = []
grid = {}
for r, line in enumerate(lines):
    for c, char in enumerate(line):
        if char in "<>^v":
            blizzards.append((r, c, char))
            grid[(r, c)] = "."
        else:
            grid[(r, c)] = char

blizzard_period = lcm(len(lines) - 2, len(lines[0]) - 2)
bcache = cache_blizzards(grid, blizzards, blizzard_period)

start_point = (0, 1)
end_point = (len(lines) - 1, len(lines[0]) - 2)

print(bfs(grid, bcache, [start_point, end_point], blizzard_period))

checkpoints = [start_point, end_point, start_point, end_point]
print(bfs(grid, bcache, checkpoints, blizzard_period))

# possible optimisation: for part 2, don't repeat part 1's work
