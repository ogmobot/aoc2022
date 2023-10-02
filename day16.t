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
    --return text
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
        A   B   C   D   E   F   G   H   I   J
    A   0   1   2   1   2   .   .   .   1   .
    B   1   0   1   2   .   .   .   .   2   .
    C   2   1   0   .   .   .   .   .   .   .
    ]]
    return test_data
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

-- Terra functions

terra build_expert(
    connects   : {uint, uint} -> {bool},
    get_reward : {uint} -> {int},
    n          : uint
) : Matrix
    -- The only cells populated are ones with non-zero rewards and AA,
    -- so a lot of this matrix will be zeroes.
    var distances : Matrix
    distances:init(n, n) -- Memory allocation
    -- Note: get_reward takes arguments in range [0..n-1]
    for i = 0, n do
        if i == 0 or get_reward(i) > 0 then
            -- BFS from here
            Cstdio.printf("\nBFSing...\n")
            var queue : &BasicQueue = nil
            var visited : uint64 = 0
            pushBasic(&queue, i, 0)
            var qlen = 1
            while queue ~= nil do -- queue is freed by this process
                Cstdio.printf("qlen=%d ", qlen)
                var node = popBasic(&queue)
                qlen = qlen - 1
                Cstdio.printf("node at loc=%d\n", node.location)
                if ((1 << node.location) and visited) == 0 then
                    Cstdio.printf("\tvisiting %d\n", node.location)
                    visited = (1 << node.location) or visited
                    if get_reward(node.location) > 0 then
                        distances:set(i, node.location, node.dist)
                    end
                    for j = 0, n do
                        if connects(i, j) and (((1 << j) and visited) == 0) then
                            Cstdio.printf("\tpushing %d\n", j)
                            pushBasic(&queue, j, node.dist + 1)
                            qlen = qlen + 1
                        end
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
    for a = 0, n do
        for b = 0, n do
            Cstdio.printf("%d ", distances:get(a, b))
        end
        Cstdio.printf("\n")
    end
    Cstdio.printf("foo\n")
end

function main()
    local connects, get_reward, n = build_basic(get_contents("input16.txt"))
    local terra_connected = terralib.cast({uint, uint} -> {bool}, connects)
    local terra_reward    = terralib.cast({uint} -> {int}, get_reward)
    solve(terra_connected, terra_reward, n)
end

main()
