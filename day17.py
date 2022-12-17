import time
with open("input17.txt") as f:
    jets = f.read().strip()

jets = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

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
    #for r in range(min(k[0] for k in grid), max(k[0] for k in grid) + 1):
    for r in range(min(k[0] for k in grid), min(k[0] for k in grid) + 10):
        print("".join(("#" if (r, c) in grid else "." for c in range(7))))

grid = {}
for c in range(7):
    grid[(0, c)] = "#"
grid, _, _ = do_game(grid, jets, 2022)
print(max(k[0] for k in grid) - min(k[0] for k in grid))

# game repeats every lcm(jets, num_shapes) units
# shapes = 5, jets = 10091
cycle_length = len(jets) * len(SHAPES)

'''
# simulate until top is flat-ish
r = 0
ji = 0
si = 0
grid = {}
for c in range(7):
    grid[(0, c)] = "#"
while True:
    r += 1
    if r % 10000 == 0:
        print(r)
    grid, ji, si = do_game(grid, jets, 1, ji, si)
    top_row = min(k[0] for k in grid)
    if sum((top_row, c) in grid for c in range(7)) == 7:
        print(r) # 1361
    #if r > 3475 and r < 3480:
        #print()
        #print_grid_top(grid)
'''

offset = 2

num_rocks = 1000000000000 - offset
total_cycles = num_rocks // cycle_length
extra_rocks = num_rocks % cycle_length
print(f"{total_cycles=} {extra_rocks=}")

grid = {}
for c in range(7):
    grid[(0, c)] = "#"
jet_index = 0
shape_index = 0

start_time = time.time()
grid, jet_index, shape_index = do_game(grid, jets, offset, jet_index, shape_index)
initial_height = max(k[0] for k in grid) - min(k[0] for k in grid)
print(f"{initial_height=}\nt={time.time() - start_time}")

# takes ~1 min in pypy
start_time = time.time()
grid, jet_index, shape_index = do_game(
    grid, jets, cycle_length, jet_index, shape_index)
height_after_1 = (max(k[0] for k in grid) - min(k[0] for k in grid))
print(f"{height_after_1=}\nt={time.time() - start_time}")

# do it once more...
start_time = time.time()
grid, jet_index, shape_index = do_game(
    grid, jets, cycle_length, jet_index, shape_index)
height_after_2 = (max(k[0] for k in grid) - min(k[0] for k in grid))
print(f"{height_after_2=} delta={height_after_2-height_after_1}\nt={time.time() - start_time}")

# do it once more...
start_time = time.time()
grid, jet_index, shape_index = do_game(
    grid, jets, cycle_length, jet_index, shape_index)
height_after_3 = (max(k[0] for k in grid) - min(k[0] for k in grid))
print(f"{height_after_3=} delta={height_after_3-height_after_2}\nt={time.time() - start_time}")

# and once more for luck...
start_time = time.time()
grid, jet_index, shape_index = do_game(
    grid, jets, cycle_length, jet_index, shape_index)
height_after_4 = (max(k[0] for k in grid) - min(k[0] for k in grid))
print(f"{height_after_4=} delta={height_after_4-height_after_3}\nt={time.time() - start_time}")

# and once more for luck...
start_time = time.time()
grid, jet_index, shape_index = do_game(
    grid, jets, cycle_length, jet_index, shape_index)
height_after_5 = (max(k[0] for k in grid) - min(k[0] for k in grid))
print(f"{height_after_5=} delta={height_after_5-height_after_4}\nt={time.time() - start_time}")

# takes ~30 s
start_time = time.time()
grid, _, _ = do_game(grid, jets, extra_rocks, jet_index, shape_index)
extra_height = max(k[0] for k in grid) - min(k[0] for k in grid) - height_after_5
print(f"{extra_height=}\n{time.time() - start_time}")

delta_height = height_after_5 - height_after_4
print(height_after_5 + (delta_height * (total_cycles - 5)) + extra_height)
# since extra_height comes with a cycle

#          1500862154424 is too low :(

#          1501020711544 is too high :(

# cycle_height is 75726? 75734?

# example should give 1501020711544
