using System;
using System.Linq;
using System.IO;
using System.Collections.Generic;

class Shipyard {
    List<List<Char>> crates;
    List<string> instructions;

    void MoveCrates(int n, int from_i, int to_i, bool part2) {
        if (!part2) {
            for (int i = 0; i < n; i++) {
                crates[to_i].Insert(0, crates[from_i][0]);
                crates[from_i].RemoveAt(0);
            }
        } else {
            List<Char> tmp = new List<Char>();
            for (int i = 0; i < n; i++) {
                tmp.Insert(0, crates[from_i][0]);
                crates[from_i].RemoveAt(0);
            }
            for (int i = 0; i < n; i++) {
                crates[to_i].Insert(0, tmp[0]);
                tmp.RemoveAt(0);
            }
        }
        return;
    }

    public void ReadFile(string filename) {
        crates = new List<List<Char>>();
        instructions = new List<string>();
        for (int i = 0; i < 9; i++) {
            crates.Add(new List<char>());
        }
        int lineCount = 0;
        foreach (string line in System.IO.File.ReadLines(filename)) {
            // first eight lines are crates
            if (line.Length > 0) {
                if (lineCount < 8) {
                    for (int i = 0; i < 9; i++) {
                        char c = line[4 * i + 1];
                        if (c != ' ')
                            crates[i].Add(c);
                    }
                } else if (lineCount > 8) {
                    instructions.Add(line);
                }
            }
            lineCount++;
        }
        return;
    }

    public void Solve(bool part2) {
        foreach (string line in instructions) {
            string[] words = line.Split(' ');
            MoveCrates(
                int.Parse(words[1]),
                int.Parse(words[3]) - 1,
                int.Parse(words[5]) - 1,
                part2
            );
        }
        foreach (List<char> stack in crates)
            Console.Write(stack[0]);
        Console.WriteLine();
        return;
    }
}

class day05 {
    static void Main(string[] args) {
        Shipyard syp1 = new Shipyard();
        syp1.ReadFile("input05.txt");
        syp1.Solve(false);
        Shipyard syp2 = new Shipyard();
        syp2.ReadFile("input05.txt");
        syp2.Solve(true);
        return;
    }
}
