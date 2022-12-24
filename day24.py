import heapq
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
    print("Caching blizzards...")
    res = {}
    # {t: set of blizzard coords}
    for t in range(amount):
        if t % 100 == 0:
            print(f"{100*t//amount}% ", end="", flush=True)
        res[t] = set((b[0], b[1]) for b in blizzards)
        blizzards = update_blizzards(grid, blizzards)
    print()
    return res

def blizzard_at(bcache, t, r, c):
    return (r, c) in bcache[t]
    #blizzards = bcache[t]
    #return any(b[0] == r and b[1] == c for b in blizzards)

def dfs(grid, bcache, start_coord, finish_coord, b_period):
    timer = 0
    time_limit = 300
    paths = [(
        manhattan(start_coord, finish_coord),
        0,
        start_coord
    )] # distance, time, location
    heapq.heapify(paths)
    seen = {}
    #max_t = 0
    while paths:
        timer += 1
        if timer % 1000000 == 0:
            print(f"{timer=} {len(paths)=} {time_limit=}")
        _, t, location = heapq.heappop(paths)
        if t + manhattan(location, finish_coord) >= time_limit:
            continue
        #if t > max_t:
            #print(f"{t=} nodes={len(paths)}")
            #max_t = t
        #print(t, location)
        r, c = location
        if location == finish_coord:
            time_limit = t
            continue
        adjacents = [(r + dr, c + dc) for dr, dc in [
            (0, 1), (0, -1), (1, 0), (-1, 0), (0, 0)
        ]]
        adjacents = [(ar, ac) for ar, ac in adjacents if (
            (not blizzard_at(bcache, (t + 1) % b_period, ar, ac)) and
            (grid.get((ar, ac), "#") == ".")
        )]
        for new_loc in adjacents:
            heapq.heappush(paths,(manhattan(new_loc, finish_coord) - t, t + 1, new_loc))
            #heapq.heappush(paths,(t + 1, new_loc))
        #if len(paths) > HEAP_CULL_AT:
            #print(f"Heap exceeded {HEAP_CULL_AT} elements. Culling...", end="", flush=True)
            #new_paths = []
            #heapq.heapify(new_paths)
            #for _ in range(HEAP_CULL_TO):
                #heapq.heappush(new_paths, heapq.heappop(paths))
            #paths = new_paths
            #print(" Done.")
    return time_limit

with open("input24.txt") as f:
    lines = [l.strip() for l in f]

lines_ = [
"#.######",
"#>>.<^<#",
"#.<..<<#",
"#>v.><>#",
"#<^v^^>#",
"######.#",
]

blizzards = []
grid = {}
for r, line in enumerate(lines):
    for c, char in enumerate(line):
        if char in "<>^v":
            blizzards.append((r, c, char))
            grid[(r, c)] = "."
        else:
            grid[(r, c)] = char

# period of the blizzards is 100 * 35 = 3500
blizzard_period = lcm(len(lines) - 2, len(lines[0]) - 2)
bcache = cache_blizzards(grid, blizzards, blizzard_period)

print(dfs(
    grid,
    bcache,
    (0, 1), (len(lines) - 1, len(lines[0]) - 2),
    blizzard_period))

# 286 is too high
