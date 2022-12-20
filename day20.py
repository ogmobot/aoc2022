class Num:
    def __init__(self, n):
        self.n = int(n)
    def __repr__(self):
        return repr(self.n)

with open("input20.txt") as f:
    nums = [Num(l.strip()) for l in f]
    nums_2 = nums.copy()

#nums = [Num(x) for x in (1, 2, -3, 3, -2, 0, 4)]
#nums_2 = [Num(x) for x in (1, 2, -3, 3, -2, 0, 4)]

def mix(nums, num_order):
    for num_i in num_order:
        orig_index = nums.index(num_i)
        new_index = orig_index + num_i.n
        #print("foo")
        #while new_index <= 0:
            #new_index += len(nums) - 1
        #print("bar")
        if new_index >= len(nums) or new_index <= 0:
            new_index = new_index % (len(nums) - 1)
            #new_index -= len(nums) - 1
        #print("baz")
        nums.pop(orig_index)
        nums.insert(new_index, num_i)
        #print(nums)
    return nums

nums = mix(nums, nums.copy())
#print(nums)

zero = [z for z in nums if z.n == 0][0]

zero_index = nums.index(zero)

groove = [nums[(zero_index + i) % len(nums)].n for i in (1000, 2000, 3000)]

# part 1
#print(groove)
print(sum(groove))

# part 2
KEY = 811589153
nums = [Num(KEY*x.n) for x in nums_2]
num_order = nums.copy()
#print(nums)
for _ in range(10):
    #print("mixing...")
    nums = mix(nums, num_order)
    #print(nums)

zero = [z for z in nums if z.n == 0][0]

zero_index = nums.index(zero)

groove = [nums[(zero_index + i) % len(nums)].n for i in (1000, 2000, 3000)]
#print(groove)
print(sum(groove))

