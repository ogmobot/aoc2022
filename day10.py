with open("input10.txt") as f:
    lines = [l.strip() for l in f.readlines()]

def generate_sigs(instructions):
    x = 1
    sigs = [1]
    for instr in instructions:
        if instr == "noop":
            sigs.append(x)
        else: #addx
            sigs.append(x)
            sigs.append(x)
            num = int(instr.split()[1])
            x += num
    return sigs

def drawbuff(vals):
    for row in range(6):
        for col in range(40):
            cycle = 40 * row + col
            sig = vals[cycle]
            if sig <= col and col <= sig + 2:
                symbol = "# "
            else:
                symbol = "  "
            print(symbol, end="")
        print()

sigs = generate_sigs(lines)

print(sum(key * sigs[key] for key in range(20, len(sigs), 40)))

drawbuff(sigs)
