class Elf:
    def __init__(self, row, col):
        self.location = (row, col)
        self.propose = None
        self.directions = ["north", "south", "west", "east"]

    def think(self, elves, occupied):
        self.propose = None
        row, col = self.location
        if not any((r, c) in occupied
                   for r, c in [
                       (row - 1, col - 1),
                       (row - 1, col),
                       (row - 1, col + 1),
                       (row, col - 1),
                       (row, col + 1),
                       (row + 1, col - 1),
                       (row + 1, col),
                       (row + 1, col + 1)]):
            self.directions = self.directions[1:] + [self.directions[0]]
            return

        for d in self.directions:
            if d == "north":
                if not any((r, c) in occupied
                    for r, c in [
                        (row - 1, col - 1),
                        (row - 1, col),
                        (row - 1, col + 1)
                    ]
                ):
                    self.propose = (row - 1, col)
                    break
            elif d == "south":
                if not any((r, c) in occupied
                    for r, c in [
                        (row + 1, col - 1),
                        (row + 1, col),
                        (row + 1, col + 1)
                    ]
                ):
                    self.propose = (row + 1, col)
                    break
            elif d == "west":
                if not any((r, c) in occupied
                    for r, c in [
                        (row - 1, col - 1),
                        (row, col - 1),
                        (row + 1, col - 1)
                    ]
                ):
                    self.propose = (row, col - 1)
                    break
            elif d == "east":
                if not any((r, c) in occupied
                    for r, c in [
                        (row - 1, col + 1),
                        (row, col + 1),
                        (row + 1, col + 1)
                    ]
                ):
                    self.propose = (row, col + 1)
                    break
        self.directions = self.directions[1:] + [self.directions[0]]

    def act(self, prop_list, occupied):
        if self.propose:
            if prop_list.count(self.propose) == 1:
                occupied.remove(self.location)
                self.location = self.propose
                occupied.add(self.location)
                return True
        return False

    def __repr__(self):
        return f"Elf({self.location} {self.propose})"

def get_score(elves):
    # find number of empty ground tiles
    r_vals = [elf.location[0] for elf in elves]
    c_vals = [elf.location[1] for elf in elves]
    total = 0
    for r in range(min(r_vals), max(r_vals) + 1):
        for c in range(min(c_vals), max(c_vals) + 1):
            if not any(elf.location == (r, c) for elf in elves):
                total += 1
    return total

def print_elves(elves):
    # find number of empty ground tiles
    r_vals = [elf.location[0] for elf in elves]
    c_vals = [elf.location[1] for elf in elves]
    for r in range(min(r_vals), max(r_vals) + 1):
        for c in range(min(c_vals), max(c_vals) + 1):
            if any(elf.location == (r, c) for elf in elves):
                print("#", end="")
            else:
                print(".", end="")
        print()
    return


with open("input23.txt") as f:
    lines = [l.rstrip("\n") for l in f]

lines_ = [
    "....#..",
    "..###.#",
    "#...#.#",
    ".#...##",
    "#.###..",
    "##.#.##",
    ".#..#.."
]

lines__ = [
        "##",
        "#.",
        "..",
        "##",
        ]

elves = []
occupied = set()
for r, line in enumerate(lines):
    for c, char in enumerate(line):
        if char == "#":
            elves.append(Elf(r, c))
            occupied.add((r, c))

# Takes ~3 min
last_round = -1
i = 1
#print_elves(elves)
while True:
    #print(f"Round {i}")
    for elf in elves:
        elf.think(elves, occupied)
        #print(elf)
    props = [elf.propose for elf in elves]
    moved = False
    for elf in elves:
        res = elf.act(props, occupied)
        if res: moved = True
    #print_elves(elves)
    if i + 1 == 10:
        print(get_score(elves))
    if not moved:
        last_round = i
        break
    i += 1
print(last_round)
