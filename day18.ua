"2,2,2\n1,2,2\n3,2,2\n2,1,2\n2,3,2\n2,2,1\n2,2,3\n2,2,4\n2,2,6\n,1,2,5\n3,2,5\n2,1,5\n2,3,5"
# Expected result is 64
#&fras "input18.txt"
partition box != @\n .
rows (box partition parse != @, . unbox)
Points =

Deltas = [1_0_0 `1_0_0 0_1_0 0_`1_0 0_0_1 0_0_`1]

# Part 1
# (takes ~17s to evaluate, lol)
deshape cross (box + unbox) Deltas Points
PartOne = length keep not member : Points .
&p PartOne

# Part 2
# (Sorry, Uiua devs -- it's too convenient to set up variables)
Maxes = + 1 reduce maximum Points
Mins  = - 1 reduce minimum Points
OutOfBounds = (> 0 /+ join < Mins : > Maxes .)

# Recursion not supported in uiua -- loop instead
# To conditional loop in uiua, repeat infinity times (until break)

# ( visited coords -- coords' )
FilterAllowed = (
    # Filters out coordinates that are already in visited,
    # as well as coordinates that are outside Mins or Maxes.
    keep not rows OutOfBounds .
    keep : dip(!= 3 rows /+ member) .
)

# ( visited front -- visited' )
FloodFill = (|2.1 ; repeat(
    dip(&p .)
    if(break 1)(identity) = 0 length .
    drop 1 : take 1 .
    # ( visited active-cell front' )
    ,
    dip(dip(
        not member : , ,
        if(
            FilterAllowed tribute + Deltas
        )(
            [[infinity_infinity_infinity]] ; ;
        )
    ))
    # ( visited 1xnew_cells front' active-cell )
    # TODO add active-cell to visited
    # ( visited' 1xnew_cells front' )
    trace deduplicate join first :
    dip(trace)
) infinity)

FloodFill [Maxes] [4_4_6]
