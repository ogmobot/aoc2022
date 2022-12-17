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

num_rocks = 1000000000000
total_cycles = num_rocks // cycle_length
extra_rocks = num_rocks % cycle_length

grid = {}
for c in range(7):
    grid[(0, c)] = "#"
jet_index = 0
shape_index = 0
cycle_counter = 0
heights = {} # n_cycles: height
last_delta = 0
while True:
    # do a cycle
    grid, jet_index, shape_index = do_game(grid, jets, cycle_length, jet_index, shape_index)
    cycle_counter += 1
    max_row = max(k[0] for k in grid)
    heights[cycle_counter] = max_row - min(k[0] for k in grid)
    if cycle_counter == 1:
        continue
    delta = heights[cycle_counter] - heights[cycle_counter - 1]
    print(f"{cycle_counter=} {delta=}")
    if delta == last_delta:
        #break
        pass
    last_delta = delta
    # cull all but the top 1000 rows
    for key in grid:
        if key[0] != 0 and key[0] > max_row + 1000:
            del grid[key]

hidden_cycles = total_cycles - cycle_counter
hidden_height = delta * hidden_cycles

grid, _, _ = do_game(grid, jets, extra_rocks, jet_index, shape_index)
extra_height = max(k[0] for k in grid) - min(k[0] for k in grid) - max(heights.values())

print(max(heights.values()) + hidden_height + extra_height)


#          1500862154424 is too low :(

#          1501020711544 is too high :(

# cycle_height is 75726? 75734?

# example should give 1501020711544

'''
cycle_counter= 2 delta=75746
cycle_counter= 3 delta=75723
cycle_counter= 4 delta=75742
cycle_counter= 5 delta=75714
cycle_counter= 6 delta=75726
cycle_counter= 7 delta=75723
cycle_counter= 8 delta=75708
cycle_counter= 9 delta=75745
cycle_counter=10 delta=75729
cycle_counter=11 delta=75732
cycle_counter=12 delta=75715
cycle_counter=13 delta=75731
cycle_counter=14 delta=75735
cycle_counter=15 delta=75706
cycle_counter=16 delta=75748
cycle_counter=17 delta=75713
cycle_counter=18 delta=75728
cycle_counter=19 delta=75722
cycle_counter=20 delta=75722
cycle_counter=21 delta=75736
cycle_counter=22 delta=75729
'''
# this table took 12h to produce.
# there seems to be neither rhyme nor reason...
