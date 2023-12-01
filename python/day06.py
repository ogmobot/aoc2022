def find_signal(text, length):
    for i, _ in enumerate(text):
        if i + length >= len(text):
            break
        if len(set(text[i:i + length])) == length:
            return i + length

with open("input06.txt") as f:
    text = f.read()

print(find_signal(text, 4))
print(find_signal(text, 14))

