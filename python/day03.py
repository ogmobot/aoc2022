# written very fast
f = open("input03.txt")
lines = [line.strip() for line in f.readlines()]

# part 1
pairs = [(line[:len(line)//2], line[len(line)//2:]) for line in lines]
overlaps = [set(p[0]).intersection(p[1]) for p in pairs]
vals = ["".join(o) for o in overlaps]

def mapper(c):
    if c.islower():
        return ord(c) - ord('a') + 1
    else:
        return ord(c) - ord('A') + 1 + 26

print(sum(map(mapper, vals)))

# part 2
badges = 0
i = 0
while i < len(lines):
    a, b, c = lines[i], lines[i+1], lines[i+2]
    i += 3
    badges += mapper("".join(set(a).intersection(b).intersection(c)))
print(badges)
