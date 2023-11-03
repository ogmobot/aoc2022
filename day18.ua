# Written with Uiua 0.0.23
&fras "input18.txt"
⊜□ ≠ @\n .
≡(□ ⊜parse ≠ @, . ⊔)
Points ←

Deltas ← [1_0_0 ¯1_0_0 0_1_0 0_¯1_0 0_0_1 0_0_¯1]

# Part 1
# (takes ~17s to evaluate, lol)
♭ ⊠(□ + ⊔) Deltas Points
▽ ¬ ∊ ∶ Points .
OpenSurfaces ←
&p ⧻ OpenSurfaces

# Part 2
# (Sorry, Uiua devs -- it's too convenient to set up variables)
Maxes ← + 1 /↥ Points
Mins ← - 1 /↧ Points
OutOfBounds ← (> 0 /+ ⊂ < Mins ∶ > Maxes .)

# Recursion not supported in uiua -- loop instead
# To conditional loop in uiua, repeat infinity times (until break)

# ( visited coords -- visited coords' )
FilterAllowed ← (
  # Filters out coordinates that are already in visited,
  # as well as coordinates that are outside Mins or Maxes.
  ∶ ,
  ▽ ¬ ≡OutOfBounds .
  ▽ ∶ ⊙(≠ 3 ≡/+ ∊) .
)

# ( visited front -- visited' )
FloodFill ← (|2
  ; ⍥(
    ?(⎋ 1)(∘) = 0 ⧻ .
    ⊃(↘ 1) ⊢
    # ( visited active-cell front' )
    ⊙(
      ⊙(⊂) . # add active-cell to visited
      FilterAllowed ≐+ Deltas
      ▽ ¬ ∊ , ,
    )
    ⊝ ⊂ ∶
  ) ∞
)

# Part 2
# (Takes ~50s to evaluate, lol)
FloodFill [Maxes] ≡⊔ Points
≡□
TheOutside ←

&p ⧻ ▽ ∊ ∶ TheOutside . OpenSurfaces
