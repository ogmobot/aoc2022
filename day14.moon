export SAND_START
START_X = 500
START_Y =   0

-- tables are pointers, so can't easily be used as keys.
-- Use grid[idx(5, 7)] instead of grid[{5, 7}]
idx = (x, y) ->
    (10000*x)+y

get_text = (filename) ->
    tmp = io.input!
    io.input filename
    text = io.read "*all"
    io.input!\close!
    io.input tmp
    text

draw_line = (grid, a, b) ->
    x , y  = a\match "(%d+),(%d+)"
    x1, y1 = b\match "(%d+),(%d+)"
    x, x1, y, y1 = (tonumber x), (tonumber x1), (tonumber y), (tonumber y1)
    grid.lowest = math.max grid.lowest, y, y1
    dx, dy = 0, 0
    if x == x1
        dx = 0
        dy = if y1 > y then dy = 1 else dy = -1
    else
        dx = if x1 > x then dx = 1 else dx = -1
        dy = 0
    while not (x == x1 and y == y1)
        grid[idx(x, y)] = true
        x += dx
        y += dy
    grid[idx(x, y)] = true

make_grid = (text) ->
    grid = {lowest: 0}
    for line in text\gmatch "[^\n]+"
        coords = [pair for pair in line\gmatch "%d+,%d+"]
        for k = 1, #coords-1
            draw_line grid, coords[k], coords[k+1]
    return grid

drop_sand = (grid, part) ->
    x, y = START_X, START_Y
    while true
        if part == 1 and y > grid.lowest
            return false -- fell into abyss
        if part == 2 and y == grid.lowest + 1
            break -- landed on floor
        if     not grid[idx(x  , y+1)]
            y += 1
        elseif not grid[idx(x-1, y+1)]
            y += 1
            x -= 1
        elseif not grid[idx(x+1, y+1)]
            y += 1
            x += 1
        else
            break
    grid[idx(x, y)] = true
    return true -- came to rest

main = ->
    contents = get_text "input14.txt"

    -- Part 1
    grid = make_grid contents
    counter = 0
    while drop_sand grid, 1
        counter += 1
    print counter

    -- Part 2
    grid = make_grid contents
    counter = 0
    start_idx = idx(START_X, START_Y)
    while not grid[start_idx]
        drop_sand grid, 2
        counter += 1
    print counter

main!

