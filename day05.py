def move_crates_p1(crates, n, from_i, to_i):
    for _ in range(n):
        crates[to_i].insert(0, crates[from_i].pop(0))

def move_crates_p2(crates, n, from_i, to_i):
    crates[to_i] = crates[from_i][:n] + crates[to_i]
    crates[from_i] = crates[from_i][n:]

instructions = []
crates = {}
crates_2 = {}
for i in range(9):
    crates[i + 1] = list()
    crates_2[i + 1] = list()

with open("input05.txt") as f:
    lines = f.readlines()

for line in lines[:8]:
    for i in range(9):
        c = line[4 * i + 1]
        if c != " ":
            crates[i + 1].append(c)
            crates_2[i + 1].append(c)

for line in lines[10:]:
    parts = line.split()
    move_crates_p1(crates, int(parts[1]), int(parts[3]), int(parts[5]))

print("".join(crates[i + 1][0] for i in range(9)))

for line in lines[10:]:
    parts = line.split()
    move_crates_p2(crates_2, int(parts[1]), int(parts[3]), int(parts[5]))

print("".join(crates_2[i + 1][0] for i in range(9)))
