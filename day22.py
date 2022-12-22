def turn(facing, direction):
    if direction == "R": # clockwise
        match facing:
            case "up": return "right"
            case "right": return "down"
            case "down": return "left"
            case "left": return "up"
    elif direction == "L": # anti-clockwise
        match facing:
            case "up": return "left"
            case "right": return "up"
            case "down": return "right"
            case "left": return "down"
    else:
        raise ValueError

def move(grid, location, facing, amount):
    #print(f"{location=} moving {facing} by {amount}")
    match facing:
        case "left": delta = (0, -1)
        case "right": delta = (0, 1)
        case "up": delta = (-1, 0)
        case "down": delta = (1, 0)
    for _ in range(amount):
        grid[location] = {
            "left": "<", "right": ">", "up": "^", "down": "v"
        }.get(facing, "*")
        new_location = (location[0] + delta[0], location[1] + delta[1])
        if new_location not in grid:
            match facing:
                case "left": tmpdelta = (0, 1)
                case "right": tmpdelta = (0, -1)
                case "up": tmpdelta = (1, 0)
                case "down": tmpdelta = (-1, 0)
            # move back until invalid location found
            tmp = location
            while tmp in grid:
                tmp = (tmp[0] + tmpdelta[0], tmp[1] + tmpdelta[1])
            tmp = (tmp[0] - tmpdelta[0], tmp[1] - tmpdelta[1])
            new_location = tmp
            '''
            if facing == "left" or facing == "right":
                row = sorted((r, c) for (r, c) in grid if r == location[0])
                if facing == "left":
                    new_location = row.pop()
                else:
                    new_location = row.pop(0)
            elif facing == "up" or facing == "down":
                col = sorted((r, c) for (r, c) in grid if c == location[1])
                if facing == "up":
                    new_location = col.pop()
                else:
                    new_location = col.pop(0)
            '''
        if grid[new_location] != "#":
            location = new_location
    #print_grid(grid)
    #input()
    return location

def print_grid(grid):
    row_vals = set(r for r, c in grid)
    col_vals = set(c for r, c in grid)
    for r in sorted(row_vals):
        print("".join(grid.get((r, c), " ") for c in sorted(col_vals)))

with open("input22.txt") as f:
    lines = [l.rstrip("\n") for l in f]

lines_ = [
"        ...#",
"        .#..",
"        #...",
"        ....",
"...#.......#",
"........#...",
"..#....#....",
"..........#.",
"        ...#....",
"        .....#..",
"        .#......",
"        ......#.",
"",
"10R5L5R10L4R5L5",
]

grid = {}
for r, line in enumerate(lines):
    if r == len(lines) - 1:
        path = line
    elif r == len(lines) - 2:
        assert line == ""
        pass
    else:
        for c, char in enumerate(line):
            if char != " ":
                grid[(r, c)] = char

location = sorted([
    coord for coord, char in grid.items() if coord[0] == 0 and char == "."
]).pop(0)
facing = "right"

pi = 0 # path index
buffer = ""
while pi < len(path):
    if path[pi].isdigit():
        buffer += path[pi]
    else:
        location = move(grid, location, facing, int(buffer))
        buffer = ""
        facing = turn(facing, path[pi])
    pi += 1

if buffer:
    location = move(grid, location, facing, int(buffer))
    buffer = ""

face_values = {"right": 0, "down": 1, "left": 2, "up": 3}
row, col = location
password = ((row + 1) * 1000) + ((col + 1) * 4) + face_values[facing]
print_grid(grid)
print(password)


