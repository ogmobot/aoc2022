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

def move(grid, location, facing, amount, portals=None):
    #if portals:
        #print(f"{location=} moving {facing} by {amount}")
    for _ in range(amount):
        match facing:
            case "left": delta = (0, -1)
            case "right": delta = (0, 1)
            case "up": delta = (-1, 0)
            case "down": delta = (1, 0)
        grid[location] = {
            "left": "<", "right": ">", "up": "^", "down": "v"
        }.get(facing, "*")
        new_location = (location[0] + delta[0], location[1] + delta[1])
        new_facing = facing
        if new_location not in grid and portals == None:
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
        elif new_location not in grid:
            r, c = new_location
            assert (r, c, facing) in portals, f"{r} {c} {facing}"
            #print(f"Portalled {location} => {portals[(r, c, facing)]}")
            nr, nc, new_facing = portals[(r, c, facing)]
            new_location = (nr, nc)
        if grid[new_location] != "#":
            location = new_location
            facing = new_facing
    #print_grid(grid)
    #input()
    return location, facing

def print_grid(grid):
    row_vals = set(r for r, c in grid)
    col_vals = set(c for r, c in grid)
    for r in sorted(row_vals):
        print("".join(grid.get((r, c), " ") for c in sorted(col_vals)))

def setup_portals(face_size):
    assert face_size == 50
    # hard code for input, not example
    portals = {}
    # {(attempted_r, attempted_c, facing) -> (new_r, new_c, new_facing)}
    #    12
    #   3AB4
    #   5C6
    #  7DE8
    #  9Fa
    #   b
    zones = {
        # always left-to-right or top-to-bottom
        "1lr": [(-1, c, "up") for c in range(face_size, face_size * 2)],
        "2lr": [(-1, c, "up") for c in range(face_size * 2, face_size * 3)],
        "3tb": [(r, face_size - 1, "left") for r in range(0, face_size)],
        "4tb": [(r, (face_size * 3), "right") for r in range(0, face_size)],
        "5tb": [(r, face_size - 1, "left") for r in range(face_size, face_size * 2)],
        "5lr": [((face_size * 2) - 1, c, "up") for c in range(0, face_size)],
        "6lr": [(face_size, c, "down") for c in range(face_size * 2, face_size * 3)],
        "6tb": [(r, (face_size * 2), "right") for r in range(face_size, face_size * 2)],
        "7tb": [(r, -1, "left") for r in range(face_size * 2, face_size * 3)],
        "8tb": [(r, (face_size * 2), "right") for r in range(face_size * 2, face_size * 3)],
        "9tb": [(r, -1, "left") for r in range(face_size * 3, face_size * 4)],
        "alr": [((face_size * 3), c, "down") for c in range(face_size, face_size * 2)],
        "atb": [(r, face_size, "right") for r in range(face_size * 3, face_size * 4)],
        "blr": [((face_size * 4), c, "down") for c in range(0, face_size)],
    }
    # Zone 1 maps to zone 9
    # Zone 9 maps to zone 1
    for p, q in zip(zones["1lr"], zones["9tb"]):
        pr, pc, _ = p
        qr, qc, _ = q
        portals[p] = (qr, qc + 1, "right")
        portals[q] = (pr + 1, pc, "down")
    # Zone 2 maps to zone b
    # Zone b maps to zone 2
    for p, q in zip(zones["2lr"], zones["blr"]):
        pr, pc, _ = p
        qr, qc, _ = q
        portals[p] = (qr - 1, qc, "up")
        portals[q] = (pr + 1, pc, "down")
    # Zone 3 maps to zone 7
    # Zone 7 maps to zone 3
    for p, q in zip(zones["3tb"], reversed(zones["7tb"])):
        pr, pc, _ = p
        qr, qc, _ = q
        portals[p] = (qr, qc + 1, "right")
        portals[q] = (pr, pc + 1, "right")
    # Zone 4 maps to zone 8
    # Zone 8 maps to zone 4
    for p, q in zip(zones["4tb"], reversed(zones["8tb"])):
        pr, pc, _ = p
        qr, qc, _ = q
        portals[p] = (qr, qc - 1, "left")
        portals[q] = (pr, pc - 1, "left")
    # Zone 5 maps to itself
    for p, q in zip(zones["5tb"], zones["5lr"]):
        pr, pc, _ = p
        qr, qc, _ = q
        portals[p] = (qr + 1, qc, "down")
        portals[q] = (pr, pc + 1, "right")
    # Zone 6 maps to itself
    for p, q in zip(zones["6tb"], zones["6lr"]):
        pr, pc, _ = p
        qr, qc, _ = q
        portals[p] = (qr - 1, qc, "up")
        portals[q] = (pr, pc - 1, "left")
    # Zone a maps to itself
    for p, q in zip(zones["atb"], zones["alr"]):
        pr, pc, _ = p
        qr, qc, _ = q
        portals[p] = (qr - 1, qc, "up")
        portals[q] = (pr, pc - 1, "left")
    return portals

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
        location, facing = move(grid, location, facing, int(buffer))
        buffer = ""
        facing = turn(facing, path[pi])
    pi += 1

if buffer:
    location, facing = move(grid, location, facing, int(buffer))
    buffer = ""

face_values = {"right": 0, "down": 1, "left": 2, "up": 3}
row, col = location
password = ((row + 1) * 1000) + ((col + 1) * 4) + face_values[facing]
#print_grid(grid)
print(password)

# part 2
portals = setup_portals(50)

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
        location, facing = move(grid, location, facing, int(buffer), portals)
        buffer = ""
        facing = turn(facing, path[pi])
    pi += 1

if buffer:
    location, facing = move(grid, location, facing, int(buffer))
    buffer = ""

face_values = {"right": 0, "down": 1, "left": 2, "up": 3}
row, col = location
password = ((row + 1) * 1000) + ((col + 1) * 4) + face_values[facing]
#print_grid(grid)
print(password)
