from functools import reduce
from itertools import cycle
def product(l):
    return reduce(lambda a, b: a * b, l)

with open("input08.txt") as f:
    lines = [line.strip() for line in f.readlines()]

width = len(lines[0])
height = len(lines)

grid = {}
for r, line in enumerate(lines):
    for c, char in enumerate(line):
        grid[(r, c)] = int(char)

seen = set()
for start_range, delta in [
    (zip(range(height), cycle([0])), (0, 1)), # left edge looking right
    (zip(range(height), cycle([width - 1])), (0, -1)), # right edge looking left
    (zip(cycle([0]), range(width)), (1, 0)), # top row looking down
    (zip(cycle([height - 1]), range(width)), (-1, 0)), # bottom row looking up
]:
    for start in start_range:
        r, c = start
        min_height = -1
        while r < height and r >= 0 and c < width and c >= 0:
            if grid[(r, c)] > min_height:
                seen.add((r, c))
                min_height = grid[(r, c)]
            r, c = (r + delta[0], c + delta[1])
print(len(seen))

candidates = list(grid)
score = 0
for cand in candidates:
    my_height = grid[cand]
    num_visible = []
    for delta in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
        num_seen = 1
        r, c = (cand[0] + delta[0], cand[1] + delta[1])
        while r < height and r >= 0 and c < width and c >= 0:
            if grid[(r, c)] < my_height:
                num_seen += 1
            else:
                break
            r, c = (r + delta[0], c + delta[1])
        else: # went off the map -- no blocking tree
            num_seen -= 1
        num_visible.append(max(num_seen, 0))
    if product(num_visible) > score:
        score = product(num_visible)

print(score)
