with open("input18.txt") as f:
    lines = [l.strip() for l in f]

def count_exposed(grid, droplet):
    total = 0
    for dx, dy, dz in [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]:
        x, y, z = droplet[0] + dx, droplet[1] + dy, droplet[2] + dz
        if (x, y, z) not in grid:
            total += 1
    return total

def make_all_air_pockets(grid):
    # mutates grid!
    for droplet in grid.copy():
        for dx, dy, dz in [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]:
            x, y, z = droplet[0] + dx, droplet[1] + dy, droplet[2] + dz
            if (x, y, z) not in grid:
                ap = make_air_pocket(grid, (x, y, z))
                if ap != None:
                    for a in ap:
                        grid.add(a)
    return


def make_air_pocket(grid, start_point):
    min_x = min(p[0] for p in grid)
    max_x = max(p[0] for p in grid)
    min_y = min(p[1] for p in grid)
    max_y = max(p[1] for p in grid)
    min_z = min(p[2] for p in grid)
    max_z = max(p[2] for p in grid)
    air_pocket = set()
    fronts = [start_point]
    while fronts:
        front = fronts.pop()
        if front in air_pocket or front in grid:
            continue
        air_pocket.add(front)
        for dx, dy, dz in [(1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)]:
            x, y, z = front[0] + dx, front[1] + dy, front[2] + dz
            if x > max_x or x < min_x or y > max_y or y < min_y or z > max_z or z < min_z:
                return None
            if (x, y, z) not in air_pocket and (x, y, z) not in grid:
                fronts.append((x, y, z))
    #print("made an air pocket")
    return air_pocket

grid = set()
for line in lines:
    x, y, z = [int(a) for a in line.split(",")]
    grid.add((x, y, z))

total = 0
for droplet in grid:
    total += count_exposed(grid, droplet)
print(total)

# part 2
total = 0
make_all_air_pockets(grid)
for droplet in grid:
    total += count_exposed(grid, droplet)
print(total)
