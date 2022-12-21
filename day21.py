class Monkey:
    def __init__(self, text, monkeys):
        self.monkeys = monkeys
        self.symbolic = False
        if text.isnumeric():
            self.is_atom = True
            self.value = int(text)
        else:
            self.is_atom = False
            words = text.split()
            self.op = words[1]
            self.a = words[0]
            self.b = words[2]

    def eval(self):
        if self.is_atom:
            return self.value
        else:
            a = self.monkeys[self.a].eval()
            b = self.monkeys[self.b].eval()
            return do_op(self.op, a, b)

    def __str__(self):
        return f"({self.op} {self.a} {self.b})"

def do_op(op, a, b):
    match op, a, b:
        case "+", int(), int(): return a + b
        case "-", int(), int(): return a - b
        case "*", int(), int(): return a * b
        case "/", int(), int(): return a // b
        case "=", int(), int(): return a == b
        case "=", int(), _____: return unwrap(a, b)
        case "=", _____, int(): return unwrap(b, a)
        case ___, int(), int(): raise ValueError(f"invalid op: '{op}'")
        case ___, _____, _____: return [op, a, b]

def do_reverse(op, result, b):
    match op:
        case "+": return int(result - b)
        case "-": return int(result + b)
        case "*": return int(result // b)
        case "/": return int(result * b)

def unwrap(integer, expression):
    while type(expression) == list:
        op, a, b = expression
        #print(f"{integer}")
        #print(f"({op} {a} {b})")
        if op == "-" and type(a) == int:
            a, b = b, a
            integer = -integer
        elif op == "/" and type(a) == int:
            a, b = b, a
            integer = 1/integer # doesn't come up in actual input, thankfully
        if type(a) == int and type(b) != int:
            integer = do_reverse(op, integer, a)
            expression = b
        elif type(b) == int and type(a) != int:
            integer = do_reverse(op, integer, b)
            expression = a
    return integer

with open("input21.txt") as f:
    lines = [line.strip() for line in f]

monkeys = {}
for line in lines:
    parts = line.split(": ")
    monkeys[parts[0]] = Monkey(parts[1], monkeys)

print(monkeys["root"].eval())

monkeys["root"].op = "="
monkeys["humn"].value = "x" # any non-int, non-list will do
print(monkeys["root"].eval())
