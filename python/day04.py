with open("input04.txt") as f:
    lines = f.readlines()

pairs = [
    tuple(tuple(int(p) for p in part.split("-"))
    for part in line.split(","))
    for line in lines
]

total = 0
for a, b in pairs:
    if a[0] <= b[0] and a[1] >= b[1]:
        total += 1
    elif a[0] >= b[0] and a[1] <= b[1]:
        total += 1

print(total)

total = 0
for a, b in pairs:
    # a to the left
    if a[0] <= b[0] and a[1] >= b[0]:
        total += 1
    # a to the right
    elif a[0] >= b[0] and a[0] <= b[1]:
        total += 1

print(total)
