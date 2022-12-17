import time
with open("input17.txt") as f:
    jets = f.read().strip()

#jets = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

SHAPES = [
    [
        "####"
    ], [
        ".#.",
        "###",
        ".#."
    ], [
        "..#",
        "..#",
        "###"
    ], [
        "#",
        "#",
        "#",
        "#"
    ], [
        "##",
        "##"
    ]
]

def shape_height(shape):
    return len(shape)

def shape_width(shape):
    return max(len(row) for row in shape)

def collides(ri, ci, shape, grid): # row index, col index
    # x, y is top-left and top-right
    for sr, row in enumerate(shape):
        for sc, char in enumerate(row):
            if (ri + sr, ci + sc) in grid and char == "#":
                return True
    return False

def lock_in(grid, shape, ri, ci):
    for sr, row in enumerate(shape):
        for sc, char in enumerate(row):
            if (ri + sr, ci + sc) in grid and char == "#":
                raise Exception("Tried to lock in over existing shape")
            if char == "#":
                grid[(ri + sr, ci + sc)] = "#"
    return

def do_game(grid, jets, num_rocks, jet_index=0, shape_index=0):
    heights = []
    for _ in range(num_rocks):
        shape = SHAPES[shape_index]
        shape_index = (shape_index + 1) % len(SHAPES)
        highest_row = min(k[0] for k in grid)
        ri = highest_row - 3 - shape_height(shape)
        ci = 2

        # rock drops
        while True:
            jet = jets[jet_index]
            jet_index = (jet_index + 1) % len(jets)
            # attempt to move left or right
            if jet == "<":
                if ci > 0:
                    if not collides(ri, ci - 1, shape, grid):
                        ci -= 1
            else:
                assert jet == ">", f"'{jet}'"
                if ci + shape_width(shape) < 7:
                    if not collides(ri, ci + 1, shape, grid):
                        ci += 1
            # attempt to move down
            if (not collides(ri + 1, ci, shape, grid)):
                ri += 1
            else:
                lock_in(grid, shape, ri, ci)
                break
        #heights.append(max(k[0] for k in grid) - min(k[0] for k in grid))
    return grid, jet_index, shape_index

def print_grid_top(grid):
    print("=======")
    #for r in range(min(k[0] for k in grid), max(k[0] for k in grid) + 1):
    for r in range(min(k[0] for k in grid), min(k[0] for k in grid) + 10):
        print("".join(("#" if (r, c) in grid else "." for c in range(7))))

def find_cycle(jets):
    seen = {} # {(jet_index, shape_index): nshapes}
    grid = {}
    for c in range(7):
        grid[(0, c)] = "#"
    grid, ji, si = do_game(grid, jets, 1234) # prime the grid
    nshapes = 1234
    while True:
        if (ji, si) in seen:
            #print("Cycle detected:")
            #print(f"{ji=} {si=} {nshapes=}")
            #print("Previously, ji and si had the same values when")
            #print(f"nshapes={seen[(ji, si)]}")
            break
        seen[(ji, si)] = nshapes
        nshapes += 1
        grid, ji, si = do_game(grid, jets, 1, ji, si)
    return (seen[(ji, si)], nshapes)

# part 1
grid = {}
for c in range(7):
    grid[(0, c)] = "#"
grid, _, _ = do_game(grid, jets, 2022)
print(max(k[0] for k in grid) - min(k[0] for k in grid))

# part 2
cycle_indices = find_cycle(jets)
cycle_length = cycle_indices[1] - cycle_indices[0]
offset = cycle_indices[0]

num_rocks = 1000000000000 - offset
total_cycles = num_rocks // cycle_length
extra_rocks = num_rocks % cycle_length

grid = {}
for c in range(7):
    grid[(0, c)] = "#"

grid, ji, si = do_game(grid, jets, offset)
initial_h = max(k[0] for k in grid) - min(k[0] for k in grid)

grid, ji, si = do_game(grid, jets, cycle_length, ji, si)
cycle_h = (max(k[0] for k in grid) - min(k[0] for k in grid)) - initial_h

grid, ji, si = do_game(grid, jets, extra_rocks, ji, si)
extra_h = (max(k[0] for k in grid) - min(k[0] for k in grid)) - cycle_h

print((cycle_h * total_cycles) + extra_h)
