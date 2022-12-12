with open("input12.txt") as f:
    lines = [l.strip() for l in f]

loc = None
target = None
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

def get_adjacent(grid, loc):
    result = []
    for delta in [(0, -1), (0, 1), (1, 0), (-1, 0)]:
        candidate = (loc[0] + delta[0], loc[1] + delta[1])
        if candidate in grid:
            if ord(grid[candidate]) <= ord(grid[loc]) + 1:
                result.append(candidate)
    return result

def bfs(grid, from_loc, to_loc):
    paths = [[from_loc]]
    seen = set()
    while paths:
        path = paths.pop(0)
        current_loc = path[-1]
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

ays = [key for key, value in grid.items() if value == 'a']
ay_paths = [bfs(grid, a, target) for a in ays]
ay_dists = [len(path) - 1 for path in ay_paths if path]
print(min(ay_dists))
