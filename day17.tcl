#/usr/bin/env tclsh

#set fp [open "input17.txt"]
#set jets [read -nonewline $fp]
#close $fp

set jets ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"

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
set SHAPES(2) {7 4 4}
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
        if {$ri - $sr < [array size grid]} {
            set shaperow [expr [lindex $shape $sr] << $ci]
            if {$grid([expr $ri - $sr]) & $shaperow} {
                # collision detected
                return 1
            }
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
            # TODO push by jet
            # TODO drop it or lock it
        }
    }
    return $ji,$si
}

proc putgrid {gridref} {
    upvar $gridref grid
    for {set r -3} {$r + 1 <= [array size grid]} {incr r} {
        if {[info exists grid([expr [array size grid] - $r - 1])]} {
            puts [format "%2x" $grid([expr [array size grid] - $r - 1])]
        } else {
            puts "00"
        }
    }
}

set grid(0) 127

#puts [ collides grid {3 3} 0 0 ]
#lock_in grid {3 3} 3 5
putgrid grid
puts [do_game grid jets 3 0 0]
putgrid grid
