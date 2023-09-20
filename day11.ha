use fmt;
use io;
use os;
use strings;

type monkey = struct {
    action  : str,
    held    : []int,
    divisor : int,
    dest_T  : int,
    dest_F  : int
};

fn monkey_init(mp : *monkey, text : str) void = {
    const lines = strings::split(text, "\n");
    defer free(lines);
    return;
};

export fn main() void = {
    const input_file = os::open("input11.txt")!;
    defer io::close(input_file)!;
    const input_data = io::drain(input_file)!;
    defer free(input_data);
    const input_text = strings::fromutf8(input_data);
    const monkey_strings = strings::split(input_text, "\n\n");

    let monkeys : []monkey = [];
    defer free(monkeys);

    for (let i = 0z; i < len(monkey_strings); i += 1) {
        const monkey_string = monkey_strings[i];
        let mp = alloc(monkey {
            // TODO
            //action = null,
            //held = [],
            //divisor = 0,
            //dest_T = 0,
            //dest_F = 0
        });
        append(monkeys, monkey_init(monkey_string));
    };

    fmt::println("Hello, world!")!;
    fmt::println(len(monkey_strings))!;
};
