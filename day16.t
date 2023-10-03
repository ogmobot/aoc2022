Cstdlib = terralib.includec("stdlib.h")
Cstdio = terralib.includec("stdio.h")
local List = require("terralist")

-- Circular queue

struct BasicQueue {
    location : uint;
    dist     : int;
    behind   : &BasicQueue;
}
terra BasicQueue:init(location : uint, dist : int)
    self.location = location
    self.dist     = dist
    self.behind   = nil
end
terra pushBasic(
    self : &&BasicQueue, location : uint, dist : int
)
    -- Allocates memory!
    -- `self` is the back of the queue. self.behind is the front.
    var new = [&BasicQueue](Cstdlib.calloc(1, sizeof(BasicQueue)))
    new:init(location, dist)
    if (@self) == nil then
        new.behind = new
        @self = new
    else
        new.behind = (@self).behind
        (@self).behind = new
        @self = new
    end
end
terra popBasic(self : &&BasicQueue) : BasicQueue
    -- Frees memory!
    var result : BasicQueue
    if (@self).behind == @self then
        result:init((@self).location, (@self).dist)
        Cstdlib.free(@self)
        @self = nil
    else
        var front : &BasicQueue = (@self).behind
        (@self).behind = front.behind
        result:init(front.location, front.dist)
        Cstdlib.free(front)
    end
    return result
end
terra freeBasic(self : &&BasicQueue)
    -- Frees memory!
    while (@self) ~= nil do
        var _ = popBasic(self)
    end
end

-- World's worst priority queue

struct Priority {
    location : uint;
    score    : uint;
    time     : uint;
    valves   : uint64;
    next     : &Priority;
}
terra Priority:init(
    location : uint,
    score    : uint,
    time     : uint,
    valves   : uint64
)
    self.location = location
    self.score    = score
    self.time     = time
    self.valves   = valves
    self.next     = nil
end
terra pushPriority(
    self     : &&Priority,
    location : uint,
    score    : uint,
    time     : uint,
    valves   : uint64
)
    -- pushes in O(n) time
    var new : &Priority = [&Priority](Cstdlib.calloc(1, sizeof(Priority)))
    new:init(location, score, time, valves)
    -- maximum score goes to front of queue
    if (@self) == nil or new.score > (@self).score then
        new.next = @self
        @self = new
    else
        var trace : &Priority = (@self)
        while trace.next ~= nil do
            if new.score > trace.next.score then
                new.next = trace.next
                trace.next = new
                break
            end
            trace = trace.next
        end
        if trace.next == nil then
            trace.next = new
        end
    end
end
terra popPriority(self : &&Priority) : Priority
    var result : Priority
    var tmp = @self
    result:init(tmp.location, tmp.score, tmp.time, tmp.valves)
    @self = tmp.next
    Cstdlib.free(tmp)
    return result
end

-- Matrix struct/class

struct Matrix {
    width  : uint;
    height : uint;
    data   : &int;
}
terra Matrix:init(width : uint, height : uint)
    self.width = width
    self.height = height
    self.data = [&int](Cstdlib.calloc((width * height), sizeof(int)))
end

terra Matrix:set(i : uint, j : uint, val : int)
    self.data[(self.width*i) + j] = val
end
terra Matrix:get(i : uint, j : uint) : int
    return self.data[(self.width*i) + j]
end
terra Matrix:free()
    Cstdlib.free(self.data)
end

-- Lua helper functions

function get_contents(filename)
    local tmp = io.input()
    io.input(filename)
    local text = io.read("*all")
    io.input():close()
    io.input(tmp)
    local test_data = [[Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
]]
    local _ = [[
    0=AA
    1=DD
    2=II         9* - 2 -- 0 -- 3*
    3=BB                   |    |
    4=CC                   1*-- 4*
    5=EE                   |
    6=FF                   5*-- 6 -- 7 -- 8*
    7=GG
    8=HH
    9=JJ
    ]]
    return text
    --return test_data
end

function build_basic(text)
    -- Builds a basic network where every edge length is 1.
    -- Assigns "AA" to index 1, and all other nodes to arbitrary indices.
    -- connections = e.g. { [1] = {[2]=true, [3]=true} }
    -- rewards     = e.g. { [1] = 0, [2] = 3, [3] = 0 }
    local connections = {}
    local rewards     = {}
    local indices     = {["AA"] = 1}
    local counter     = 1
    for line in text:gmatch("[^\n]+") do
        local _, _, name, flow, exits = line:find(
            "^Valve (..) has flow rate=(%d+); tunnels? leads? to valves? (.*)$"
        )
        if not indices[name] then
            counter = counter + 1
            indices[name] = counter
        end
        rewards[indices[name]] = tonumber(flow)
        connections[indices[name]] = {}
        for ex in exits:gmatch("%a+") do
            if not indices[ex] then
                counter = counter + 1
                indices[ex] = counter
            end
            connections[indices[name]][indices[ex]] = true
        end
    end
    -- Returned functions add 1 to argument before lookup
    local connects = function (a, b)
        local tmp = connections[a + 1] or {}
        return tmp[b + 1] or false
    end
    local get_reward = function (a)
        return rewards[a + 1] or -1
    end
    return connects, get_reward, counter
end

function make_cache()
    local cache = {}
    local cache_test = function(location, score, time, valves)
        -- returns false if there is already an equal or better node
        -- returns true (and enters the node in the cache) otherwise
        -- (better: equal location *and* equal or higher score *and* 
        --  equal or lesser time, *and* equal or greater valves)
        if cache[location] == nil then
            cache[location] = {}
        end
        for _, node in pairs(cache[location]) do
            if node.score >= score
            and node.time <= time
            and node.valves >= valves then
                return false
            end
        end
        table.insert(cache[location], {score=score, time=time, valves=valves})
        return true
    end
    return terralib.cast(
        {uint, uint, uint, uint64} -> {bool},
        cache_test
    )
end

-- Terra functions

terra build_expert(
    connects   : {uint, uint} -> {bool},
    get_reward : {uint} -> {int},
    n          : uint
) : Matrix
    var distances : Matrix
    distances:init(n, n) -- Memory allocation
    -- Note: get_reward takes arguments in range [0..n-1]
    for i = 0, n do
        -- BFS from here
        var queue : &BasicQueue = nil
        var visited : uint64 = 0
        pushBasic(&queue, i, 0)
        while queue ~= nil do -- queue is freed by this process
            var node = popBasic(&queue)
            if ((1 << node.location) and visited) == 0 then
                visited = (1 << node.location) or visited
                distances:set(i, node.location, node.dist)
                for j = 0, n do
                    if (connects(node.location, j)
                        and (((1 << j) and visited) == 0)) then
                        pushBasic(&queue, j, node.dist + 1)
                    end
                end
            end
        end
    end
    return distances
end

terra solve(
    connects   : {uint, uint} -> {bool},
    get_reward : {uint} -> {int},
    n          : uint
)
    var distances = build_expert(connects, get_reward, n)

    -- Part 1
    var attempts : &Priority = nil
    var best_score : uint = 0
    var is_good = [ make_cache() ]
    --var best_scores : &int = [&int](Cstdlib.calloc(n, sizeof(int)))
    --defer Cstdlib.free(best_scores)
    -- location, score, time, valves
    pushPriority(&attempts, 0, 0, 0, 0)
    while attempts ~= nil do
        var attempt = popPriority(&attempts)
        if attempt.time == 30 then
            if attempt.score > best_score then
                best_score = attempt.score
            end
        elseif (attempt.time < 30)
        and is_good(
            attempt.location, attempt.score, attempt.time, attempt.valves
        ) then
            Cstdio.printf("Popping node\n\tloc=%2u time=%2u score=%4u\n\t%064b\n",
                attempt.location, attempt.time, attempt.score, attempt.valves)
            var score_delta : uint = 0
            for j = 0, n do
                if ((1 << j) and attempt.valves) > 0 then
                    score_delta = score_delta + get_reward(j)
                end
            end
            -- the "do nothing" option
            pushPriority(&attempts,
                attempt.location,
                attempt.score + ((30 - attempt.time) * score_delta),
                30,
                attempt.valves
            )
            for dest = 0, n do
                if ((dest ~= attempt.location)
                and (((1 << dest) and attempt.valves) == 0)
                and (get_reward(dest) > 0)
                ) then
                    var dist : uint = distances:get(attempt.location, dest)
                    pushPriority(&attempts,
                        dest,
                        attempt.score + ((dist + 1) * score_delta),
                        attempt.time + dist + 1,
                        attempt.valves or (1 << dest)
                    )
                end
            end
        end
    end
    Cstdio.printf("%u\n", best_score)
end

function main()
    local connects, get_reward, n = build_basic(get_contents("input16.txt"))
    local terra_connected = terralib.cast({uint, uint} -> {bool}, connects)
    local terra_reward    = terralib.cast({uint} -> {int}, get_reward)
    solve(terra_connected, terra_reward, n)
end

main()
