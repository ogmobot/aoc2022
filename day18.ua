&fras "input18.txt"
partition box != @\n .
rows (box partition parse != @, . unbox)
Points =

Deltas = [1_0_0 `1_0_0 0_1_0 0_`1_0 0_0_1 0_0_`1]

# Part 1
# (takes ~17s to evaluate, lol)
deshape cross (box + unbox) Deltas Points
keep not member : Points .
OpenSurfaces =
&p length OpenSurfaces

# Part 2
# (Sorry, Uiua devs -- it's too convenient to set up variables)
Maxes = + 1 reduce maximum Points
Mins  = - 1 reduce minimum Points
OutOfBounds = (> 0 /+ join < Mins : > Maxes .)

# Recursion not supported in uiua -- loop instead
# To conditional loop in uiua, repeat infinity times (until break)

# ( visited coords -- visited coords' )
FilterAllowed = (
    # Filters out coordinates that are already in visited,
    # as well as coordinates that are outside Mins or Maxes.
    : ,
    keep not rows OutOfBounds .
    keep : dip(!= 3 rows /+ member) .
)

# ( visited front -- visited' )
FloodFill = (|2.1 ; repeat(
    if(break 1)(identity) = 0 length .
    fork (drop 1) first
    # ( visited active-cell front' )
    dip(
        dip(join) . # add active-cell to visited
        FilterAllowed tribute + Deltas
        keep not member , ,
    )
    deduplicate join :
) infinity)

# Part 2
# (Takes ~50s to evaluate, lol)
FloodFill [Maxes] rows unbox Points
rows box
TheOutside =

&p length keep member : TheOutside . OpenSurfaces
