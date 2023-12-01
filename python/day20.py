class Num:
    def __init__(self, n):
        self.n = int(n)
    def __repr__(self):
        return repr(self.n)

def mix(nums, num_order):
    for num_i in num_order:
        orig_index = nums.index(num_i)
        new_index = orig_index + num_i.n
        nums.pop(orig_index)
        if new_index >= len(nums) or new_index <= 0:
            new_index = new_index % len(nums)
        nums.insert(new_index, num_i)
    return

def grove_sum(nums):
    zero_index = [index for index, num in enumerate(nums) if num.n == 0].pop()
    grove = [nums[(zero_index + x) % len(nums)].n for x in (1000, 2000, 3000)]
    return sum(grove)

with open("input20.txt") as f:
    nums_orig = [Num(l.strip()) for l in f]

# part 1
nums = nums_orig.copy()
mix(nums, nums.copy())
print(grove_sum(nums))

# part 2
KEY = 811589153
nums = [Num(KEY*x.n) for x in nums_orig]
num_order = nums.copy()
for _ in range(10):
    mix(nums, num_order)
print(grove_sum(nums))
