use IO;
use Map;

proc testVisible(grid: map((int, int), int), startCoord: (int, int)): bool {
  const myHeight = grid.get(startCoord, -1);
  for (dr, dc) in [(-1, 0), (0, -1), (1, 0), (0, 1)] do {
    var (r, c) = startCoord;
    while grid.contains((r, c)) {
      (r, c) = (r + dr, c + dc);
      if !grid.contains((r, c)) { // edge of the grid
        return true;
      }
      if grid.get((r, c), -1) >= myHeight {
        break;
      }
    }
  }
  return false;
}

proc admireTheView(grid: map((int, int), int), startCoord: (int, int)): int {
  const myHeight = grid.get(startCoord, -1);
  var scenicScore = 1;
  for (dr, dc) in [(-1, 0), (0, -1), (1, 0), (0, 1)] do {
    var (r, c) = startCoord;
    var dist = 0;
    while grid.contains((r, c)) {
      (r, c) = (r + dr, c + dc);
      if !grid.contains((r, c)) { // edge of the grid
        break;
      }
      dist += 1;
      if grid.get((r, c), -1) >= myHeight {
        break;
      }
    }
    scenicScore *= dist;
  }
  return scenicScore;
}

proc main() : void {
  var grid: map((int, int), int, parSafe=true);
  const fp = openReader("input08.txt");
  //const fp = stdin;
  for (line, r) in zip(fp.lines(stripNewline=true), 1..) do {
    for (digit, c) in zip(line, 1..) do {
      grid.add((r, c), digit:int);
    }
  }
  // part 1
  var numVisible = 0;
  forall coord in grid.keysToArray() with (+ reduce numVisible) {
    numVisible reduce= testVisible(grid, coord);
  }
  writeln(numVisible);
  // part 2
  var bestScore = 0;
  forall coord in grid.keysToArray() with (max reduce bestScore) {
    bestScore reduce= admireTheView(grid, coord);
  }
  writeln(bestScore);
  return;
}
