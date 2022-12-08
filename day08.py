from functools import reduce
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
# from left
for r in range(height):
    min_height = -1
    for c in range(width):
        if grid[(r, c)] > min_height:
            seen.add((r, c))
            min_height = grid[(r, c)]
# from right
for r in range(height):
    min_height = -1
    for c in range(width - 1, -1, -1):
        if grid[(r, c)] > min_height:
            seen.add((r, c))
            min_height = grid[(r, c)]
# from bottom
for c in range(width):
    min_height = -1
    for r in range(height):
        if grid[(r, c)] > min_height:
            seen.add((r, c))
            min_height = grid[(r, c)]
# from right
for c in range(width):
    min_height = -1
    for r in range(height - 1, -1, -1):
        if grid[(r, c)] > min_height:
            seen.add((r, c))
            min_height = grid[(r, c)]

print(len(seen))

candidates = list(grid)
score = 0
for cand in candidates:
    my_height = grid[cand]
    value = []
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
        value.append(max(num_seen, 0))
    if product(value) > score:
        score = product(value)

print(score)
