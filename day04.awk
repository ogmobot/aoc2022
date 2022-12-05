#!/usr/bin/env -S awk -f
# Usage: ./day04.awk < input04.txt

BEGIN {
    FS = "[,\-]" # field separator
}

{
    sum_p1 += ($1 <= $3 && $2 >= $4) || ($1 >= $3 && $2 <= $4)
    sum_p2 += ($1 <= $3 && $2 >= $3) || ($1 >= $3 && $1 <= $4)
}

END {
    print sum_p1; print sum_p2
}
