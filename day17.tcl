#/usr/bin/env tclsh

set fp [open "input17.txt"]
set jets [read -nonewline $fp]
close $fp

#set jets ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

## RHS of each assignment is a list literal, heh
#set SHAPES(0) "####"
#set SHAPES(1) ".#. ### .#."
#set SHAPES(2) "..# ..# ###"
#set SHAPES(3) "# # # #"
#set SHAPES(4) "## ##"

#proc shape_height {s} {return [llength $s]}
#proc shape_width  {s} {return [string length [lindex $s 0]]}

set SHAPES(0) {15}
set SHAPES(1) {2 7 2}
set SHAPES(2) {4 4 7}
set SHAPES(3) {1 1 1 1}
set SHAPES(4) {3 3}

# Represent playing field as an array of numbers,
# with field(0) <- 0b1111111 as the bottom row.
# Least significant digit is on the left, so
# 0b1100000 is 3
# Indexing the array extracts one row from the playing field.
# (to push a piece one unit to the right, use <<1)

proc collides {gridref shape ri ci} {
    upvar $gridref grid
    for {set sr 0} {$sr < [llength $shape]} {incr sr} {
        if {![info exists grid([expr $ri - $sr])]} {
            continue
        }
        set shaperow [expr [lindex $shape $sr] << $ci]
        if {$shaperow & $grid([expr $ri - $sr])} {
            # collision detected
            return 1
        }
    }
    return 0
}

proc lock_in {gridref shape ri ci} {
    # mutates grid
    upvar $gridref grid
    for {set sr 0} {$sr < [llength $shape]} {incr sr} {
        if {![info exists grid([expr $ri - $sr])]} {
            set grid([expr $ri - $sr]) 0
        }
        set shaperow [expr [lindex $shape $sr] << $ci]
        if {$shaperow & $grid([expr $ri - $sr])} { puts "uh oh" }
        set grid([expr $ri - $sr]) [expr $grid([expr $ri - $sr]) | $shaperow]
    }
}

proc do_game {gridref jets nrocks ji si} {
    # mutates grid
    upvar $gridref grid
    global SHAPES
    for {set i 0} {$i < $nrocks} {incr i} {
        set shape $SHAPES($si)
        set si [expr ($si + 1) % [array size SHAPES]]
        set ri [expr [array size grid] + 2 + [llength $shape]]
        set ci 2
        while {1} {
            # push by jet
            set jet [string index $jets $ji]
            # set jet... future radio?
            if {[string equal [string index $jets $ji] >]} {
                #puts "right"
                set can_go 1
                for {set j 0} {$j < [llength $shape]} {incr j} {
                    if {64 & [expr [lindex $shape $j] << $ci]} {
                        set can_go 0
                    }
                }
                if {$can_go && ![collides grid $shape $ri [expr $ci + 1]]} {
                    #puts "    (went right)"
                    incr ci
                }
            } else {
                #puts "left"
                set can_go [expr $ci > 0]
                if {$can_go && ![collides grid $shape $ri [expr $ci - 1]]} {
                    #puts "    (went left)"
                    set ci [expr $ci - 1]
                }
            }
            set ji [expr ($ji + 1) % [string length $jets]]
            # drop it or lock it
            if {[collides grid $shape [expr $ri - 1] $ci]} {
                lock_in grid $shape $ri $ci
                #puts "locked at ri=$ri ci=$ci"
                #putgrid grid
                break
            } else {
                set ri [expr $ri - 1]
            }
        }
    }
    return "$ji $si"
}

proc putgrid {gridref} {
    upvar $gridref grid
    for {set r -3} {$r + 1 <= [array size grid]} {incr r} {
        if {[info exists grid([expr [array size grid] - $r - 1])]} {
            puts [format "%02x" $grid([expr [array size grid] - $r - 1])]
        } else {
            puts "00"
        }
    }
}

# part 1
set grid(0) 127
do_game grid $jets 2022 0 0
puts [expr [array size grid] - 1]
unset grid

# part 2
# (Assume length of jets is prime)
# TODO
#set cycle_indices [find_cycle $jets]
#set offset [expr  [lindex $cycle_indices 0]
#set cycle_length  [expr [lindex $cycle_indices 1] - $offset]
set offset         1234
set cycle_length   1715
set num_rocks      [expr 1000000000000 - $offset]
set total_cycles   [expr $num_rocks / $cycle_length]
set extra_rocks    [expr $num_rocks % $cycle_length]

set grid(0) 127
set res [do_game grid $jets $offset 0 0]
set initial_h [array size grid]
set res [do_game grid $jets $cycle_length [lindex $res 0] [lindex $res 1]]
set cycle_h [expr [array size grid] - $initial_h]
set res [do_game grid $jets $extra_rocks [lindex $res 0] [lindex $res 1]]
# extra_h is the sum of cap and foundation heights
set extra_h [expr [array size grid] - $cycle_h]

puts [expr ($cycle_h * $total_cycles) + $extra_h - 1]
