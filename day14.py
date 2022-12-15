SAND_START = (500, 0)
S_ROCK = "#"
S_SAND = "o"

with open("input14.txt") as f:
    lines = [l.strip() for l in f]

def draw_line(grid, a, b, symbol):
    ax, ay = a
    bx, by = b
    if ax != bx:
        dx = abs(bx - ax)//(bx - ax)
        dy = 0
    else:
        dx = 0
        dy = abs(by - ay)//(by - ay)
    grid[a] = symbol
    while a != b:
        a = (a[0] + dx, a[1] + dy)
        grid[a] = symbol
    grid["abyss"] = max([a[1], b[1], grid["abyss"]])
    grid["floor"] = max([a[1] + 2, b[1] + 2, grid["floor"]])
    return

def draw_from_text(grid, text):
    point_texts = text.split(" -> ")
    for i, _ in enumerate(point_texts):
        if i == 0: continue
        a, b = point_texts[i - 1], point_texts[i]
        a = tuple(int(x) for x in a.split(","))
        b = tuple(int(x) for x in b.split(","))
        draw_line(grid, a, b, S_ROCK)

def drop_sand(grid, part):
    # sand pours in from (500, 0)
    loc = SAND_START
    lower = (loc[0], loc[1] + 1)
    lower_left = (loc[0] - 1, loc[1] + 1)
    lower_right = (loc[0] + 1, loc[1] + 1)
    while True:
        if loc[1] > grid["abyss"] and part == 1:
            return False # abyss
        if part == 2 and loc[1] + 1 == grid["floor"]:
            break # landed on floor
        if lower not in grid:
            loc = lower
        elif lower_left not in grid:
            loc = lower_left
        elif lower_right not in grid:
            loc = lower_right
        else:
            # stop moving
            break
        lower = (loc[0], loc[1] + 1)
        lower_left = (loc[0] - 1, loc[1] + 1)
        lower_right = (loc[0] + 1, loc[1] + 1)
    grid[loc] = S_SAND
    return True # came to rest

def solve(grid, part):
    if part == 1:
        came_to_rest = True
        counter = 0
        while came_to_rest:
            came_to_rest = drop_sand(grid, 1)
            counter += 1
        counter -= 1
        return counter
    if part == 2:
        counter = 0
        while SAND_START not in grid:
            drop_sand(grid, 2)
            counter += 1
        return counter

grid = {"abyss": 0, "floor": 0}

for line in lines:
    draw_from_text(grid, line)

print(solve(grid, 1))


grid = {"abyss": 0, "floor": 0}

for line in lines:
    draw_from_text(grid, line)

print(solve(grid, 2))
