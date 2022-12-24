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

def bfs(grid, bcache, start_coord, checkpoints, b_period):
    timer = 0
    time_limit = 300 # must be >= solution
    paths = [(0,) + start_coord]
    seen = set()
    #max_t = 0
    while paths:
        timer += 1
        if timer % 1000000 == 0:
            print(f"{timer=} {len(paths)=} {time_limit=}")
            print(f"{paths[-1]=}")
        t, r, c = paths.pop(0)
        if (t, r, c) in seen:
            continue
        seen.add((t, r, c))
        if (r, c) == checkpoints[0]:
            checkpoints = checkpoints[1:]
            if len(checkpoints) == 0:
                return t
            paths = []
        adjacents = [(r + dr, c + dc) for dr, dc in [
            (0, 0), (-1, 0), (0, -1), (1, 0), (0, 1),
        ]]
        adjacents = [(ar, ac) for ar, ac in adjacents if (
            (not blizzard_at(bcache, (t + 1) % b_period, ar, ac)) and
            (grid.get((ar, ac), "#") == ".")
        )]
        for new_loc in adjacents:
            paths.append((t + 1,) + new_loc)
    return None

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

start_point = (0, 1)
end_point = (len(lines) - 1, len(lines[0]) - 2)

print(bfs(
    grid,
    bcache,
    start_point, [end_point],
    blizzard_period))

print(bfs(
    grid,
    bcache,
    start_point, [end_point, start_point, end_point],
    blizzard_period))
