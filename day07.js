const fs = require("fs");

function get_size(d) {
    let total = 0;
    for ([name, data] of Object.entries(d)) {
        if (isNaN(data)) {
            total += get_size(data);
        } else {
            total += data;
        }
    }
    return total;
}

function all_sizes(d, buffer) {
    // mutates buffer
    buffer.push(get_size(d));
    for ([name, data] of Object.entries(d)) {
        if (isNaN(data)) {
            all_sizes(data, buffer);
        }
    }
    return;
}

function build_tree(lines) {
    let root = {};
    let current_path = [];
    let working_directory = root;
    for (line of lines) {
        if (line[0] === '$') { // command
            if (line === "$ cd /") {
                current_path = [];
            } else if (line === "$ cd ..") {
                current_path.pop();
            } else if (line === "$ ls") {
                // do nothing
            } else { // $ cd <directory>
                let words = line.split(" ");
                current_path.push(words[2]);
            }
            working_directory = root;
            for (dir of current_path) {
                working_directory = working_directory[dir];
            }
        } else { // listing
            let words = line.split(" ");
            if (words[0] == "dir") {
                working_directory[words[1]] = {};
            } else {
                working_directory[words[1]] = parseInt(words[0]);
            }
        }
    }
    return root;
}

fs.readFile("input07.txt", "utf8", (err, data) => {
    if (err) {
        return;
    }
    let lines = data.trim().split("\n");
    let root = build_tree(lines);
    let sizes = [];
    all_sizes(root, sizes);
    console.log(sizes.filter(x => x <= 100000)
                     .reduce((x, y) => x + y));

    const TOTAL    = 70000000;
    const REQUIRED = 30000000;
    let need_to_delete = REQUIRED + get_size(root) - TOTAL;
    console.log(sizes.filter(x => x >= need_to_delete)
                     .reduce((x, y) => x < y ? x : y));
});
