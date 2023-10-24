"2,2,2\n1,2,2\n3,2,2\n2,1,2\n2,3,2\n2,2,1\n2,2,3\n2,2,4\n2,2,6\n,1,2,5\n3,2,5\n2,1,5\n2,3,5"
# Expected result is 64
#&fras "input18.txt"
partition box != @\n dup
rows (box partition parse != @, dup unbox)
Points =

Deltas = [1_0_0 `1_0_0 0_1_0 0_`1_0 0_0_1 0_0_`1]

# Part 1
# (takes ~17s to evaluate, lol)
#deshape cross (box + unbox) Deltas Points
#&p length keep not member swap Points dup

# Part 2
# (Sorry, Uiua devs -- it's too convenient to set up variables)
Maxes = + 1 reduce maximum Points
Mins  = - 1 reduce minimum Points
# Reduce this with /*
OutOfBounds = (* >= Mins swap <= Maxes dup)
FloodFill = (
    # ( visited front -- visited' )
    > 0 length over
    if (
        # front length is non-zero
        first swap drop 1 dup
        # TODO ensure this is not already visited
        # ( visited front' active )
        swap dip (dip join dup) swap
        # ( visited' front' active )
        tribute + Deltas
        join dip (
            # ( visited' [new fronter] )
            # TODO ensure each new frontier not in visited
            # and not out of bounds
        ) swap
        FloodFill
    ) (
        # front length is zero
        pop
    )
)
FloodFill [Mins] []

