with open("input09.txt") as f:
    instructions = [l.strip().split() for l in f.readlines()]

def step_tail(head, tail):
    # returns new position of tail
    hr, hc = head
    tr, tc = tail
    r, c = tail
    if tr < hr:
        r = tr + 1
    elif tr > hr:
        r = tr - 1
    if tc < hc:
        c = tc + 1
    elif tc > hc:
        c = tc - 1
    return (r, c)

def maxdist(a, b):
    return max(abs(a[0]-b[0]), abs(a[1]-b[1]))

def trace_tail(num_knots, instructions):
    seen = set()
    seen.add((0, 0))
    knots = [(0, 0) for _ in range(num_knots)]
    for parts in instructions:
        for _ in range(int(parts[1])):
            for i, knot in enumerate(knots.copy()):
                if i == 0: # head
                    r, c = knot
                    if parts[0] == "R":
                        c += 1
                    if parts[0] == "L":
                        c -= 1
                    if parts[0] == "D":
                        r += 1
                    if parts[0] == "U":
                        r -= 1
                    knots[0] = (r, c)
                else:
                    while maxdist(knots[i], knots[i - 1]) > 1:
                        knots[i] = step_tail(knots[i - 1], knot)
                    if i == len(knots) - 1: # tail
                        seen.add(knots[i])

    return len(seen)

print(trace_tail(2, instructions))
print(trace_tail(10, instructions))
