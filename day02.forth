8 Constant buffer-len
s" input02.txt" r/o open-file throw Value fd-in
Create line-buffer buffer-len allot

: score-part-1 ( XYZ ABC -- score )
    dup 65 = if     \ A (rock)
        drop
        dup 88 = if     \ X (rock)
            drop
            4               \ draw with rock = 3 + 1
        else
            89 = if     \ Y (paper)
                8           \ win with paper = 6 + 2
            else        \ Z (scissors)
                3           \ lose with scissors = 0 + 3
            then
        then
    else
        66 = if     \ B (paper)
            dup 88 = if     \ X (rock)
                drop
                1               \ lose with rock = 0 + 1
            else
                89 = if     \ Y (paper)
                    5           \ draw with paper = 3 + 2
                else        \ Z (scissors)
                    9           \ win with scissors = 6 + 3
                then
            then
        else        \ C (scissors)
            dup 88 = if     \ X (rock)
                drop
                7               \ win with rock = 6 + 1
            else
                89 = if     \ Y (paper)
                    2           \ lose with paper = 0 + 2
                else        \ Z (scissors)
                    6           \ draw with scissors = 3 + 3
                then
            then
        then
    then
;

: score-part-2 ( XYZ ABC -- score )
    dup 65 = if     \ A (rock)
        drop
        dup 88 = if     \ X (lose)
            drop
            3               \ lose with scissors = 0 + 3
        else
            89 = if     \ Y (draw)
                4           \ draw with rock = 3 + 1
            else        \ Z (win)
                8           \ win with paper = 6 + 2
            then
        then
    else
        66 = if     \ B (paper)
            dup 88 = if     \ X (lose)
                drop
                1               \ lose with rock = 0 + 1
            else
                89 = if     \ Y (draw)
                    5           \ draw with paper = 3 + 2
                else        \ Z (win)
                    9           \ win with scissors = 6 + 3
                then
            then
        else        \ C (scissors)
            dup 88 = if     \ X (lose)
                drop
                2               \ lose with paper = 0 + 2
            else
                89 = if     \ Y (draw)
                    6           \ draw with scissors = 3 + 3
                else        \ Z (win)
                    7           \ win with rock = 6 + 1
                then
            then
        then
    then
;

: process-file ( -- total-score )
    0 0
    begin
        line-buffer buffer-len fd-in read-line throw
    while
        drop
        line-buffer 2 chars + c@    \ third character
        line-buffer 0 chars + c@    \ first character
        score-part-1 +
        swap
        line-buffer 2 chars + c@
        line-buffer 0 chars + c@
        score-part-2 +
        swap
    repeat
    drop
;

process-file . cr . cr

bye
