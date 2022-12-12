with open("input12.txt") as f:
    lines = [l.strip() for l in f]

loc = None
target = None
ays = []
grid = {}
for r, line in enumerate(lines):
    for c, char in enumerate(line):
        grid[(r, c)] = char
        if char == "S":
            loc = (r, c)
            grid[loc] = 'a'
        elif char == "E":
            target = (r, c)
            grid[target] = 'z'
        if char == "S" or char == "a":
            ays.append((r, c))


def get_adjacent(grid, loc):
    result = []
    for delta in [(0, -1), (0, 1), (1, 0), (-1, 0)]:
        candidate = (loc[0] + delta[0], loc[1] + delta[1])
        if candidate in grid:
            if ord(grid[candidate]) <= ord(grid[loc]) + 1:
                result.append(candidate)
    return result

def bfs(grid, from_loc, to_loc, maxdist=999999):
    paths = [[from_loc]]
    seen = set()
    while paths:
        path = paths.pop(0)
        current_loc = path[-1]
        if len(path) > maxdist:
            return None # too long
        if current_loc in seen:
            continue
        seen.add(current_loc)
        if current_loc == to_loc:
            return path
        # else
        for c in get_adjacent(grid, current_loc):
            paths.append(path + [c])
    return None # no path

path = bfs(grid, loc, target)
#print(path)
#print([grid[c] for c in path])

print(len(bfs(grid, loc, target))-1)

print(ays)
min_a_path = 999999
for i, a in enumerate(ays):
    #print(f'{i}/{len(ays)}')
    path = bfs(grid, a, target, min_a_path)
    if path:
        min_a_path = len(path)
print(min_a_path - 1)
