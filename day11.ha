use fmt;
use io;
use os;
use regex;
use strconv;
use strings;

type monkey = struct {
    active  : bool,
    action  : str,
    held    : []int,
    divisor : int,
    dest_T  : size,
    dest_F  : size,
    counter : size
};

fn monkey_init(monkeys : *[12]monkey, text : str) void = {
    const lines = strings::split(text, "\n");
    defer free(lines);
    // Name
    let tokens = strings::tokenize(lines[0], " ");
    strings::next_token(&tokens); // Monkey
    const m = strconv::stoz(
        strings::rtrim(strings::next_token(&tokens) as str, ':')
    )!;
    monkeys[m].active = true;
    // Items
    let tokens = strings::tokenize(strings::ltrim(lines[1], ' '), " ");
    strings::next_token(&tokens); // Starting
    strings::next_token(&tokens); // items:
    const items = strings::split(
        strings::remaining_tokens(&tokens),
        ", "
    );
    defer free(items);
    for (let i = 0z; i < len(items); i += 1) {
        append(monkeys[m].held, strconv::stoi(items[i])!);
    };
    // Operation
    let tokens = strings::tokenize(strings::ltrim(lines[2], ' '), " ");
    strings::next_token(&tokens); // Operation:
    strings::next_token(&tokens); // new
    strings::next_token(&tokens); // =
    monkeys[m].action = strings::dup(strings::remaining_tokens(&tokens));
    // Test
    let tokens = strings::tokenize(strings::ltrim(lines[3], ' '), " ");
    strings::next_token(&tokens); // Test:
    strings::next_token(&tokens); // divisible
    strings::next_token(&tokens); // by
    monkeys[m].divisor = strconv::stoi(strings::next_token(&tokens) as str)!;
    // If true
    let tokens = strings::tokenize(strings::ltrim(lines[4], ' '), " ");
    strings::next_token(&tokens); // If
    strings::next_token(&tokens); // true:
    strings::next_token(&tokens); // throw
    strings::next_token(&tokens); // to
    strings::next_token(&tokens); // monkey
    monkeys[m].dest_T = strconv::stoz(strings::next_token(&tokens) as str)!;
    // If false
    let tokens = strings::tokenize(strings::ltrim(lines[5], ' '), " ");
    strings::next_token(&tokens); // If
    strings::next_token(&tokens); // false:
    strings::next_token(&tokens); // throw
    strings::next_token(&tokens); // to
    strings::next_token(&tokens); // monkey
    monkeys[m].dest_F = strconv::stoz(strings::next_token(&tokens) as str)!;
    return;
};

fn operate(old : int, operation : str) int = {
    let tokens = strings::tokenize(operation, " ");
    let a = 0;
    const stra = strings::next_token(&tokens) as str;
    if (strings::compare("old", stra) == 0) {
        a = old;
    } else {
        a = strconv::stoi(stra)!;
    };
    const op = strings::next_token(&tokens) as str;
    let b = 0;
    const strb = strings::next_token(&tokens) as str;
    if (strings::compare("old", strb) == 0) {
        b = old;
    } else {
        b = strconv::stoi(strb)!;
    };
    if (strings::compare("+", op) == 0) {
        return a + b;
    };
    if (strings::compare("*", op) == 0) {
        return a * b;
    };
    // impossible
    return 0;
};

fn do_round(monkeys : *[12]monkey, who : size, part1 : bool) void = {
    // Recurses until it finds a non-active monkey
    if (!monkeys[who].active) {
        return;
    };

    for (len(monkeys[who].held) > 0) {
        monkeys[who].counter += 1;
        let value = monkeys[who].held[0];
        delete(monkeys[who].held[0]);
        fmt::println("monkey", who, "inspects", value)!;
        value = operate(value, monkeys[who].action);
        if (part1) {
            value = value / 3;
        };
        if (value % monkeys[who].divisor == 0) {
            append(monkeys[monkeys[who].dest_T].held, value);
            fmt::println("sends", value, "to monkey", monkeys[who].dest_T)!;
        } else {
            append(monkeys[monkeys[who].dest_F].held, value);
            fmt::println("sends", value, "to monkey", monkeys[who].dest_F)!;
        };
    };

    do_round(monkeys, who + 1, part1);
    return;
};

export fn main() void = {
    const input_file = os::open("input11.txt")!;
    defer io::close(input_file)!;
    const input_data = io::drain(input_file)!;
    defer free(input_data);
    const input_text = strings::fromutf8(input_data);
    const monkey_strings = strings::split(input_text, "\n\n");
    defer free(monkey_strings);

    const dummy = monkey {
            active  = false,
            action  = "",
            held = [],
            divisor = 0,
            dest_T  = 0,
            dest_F  = 0,
            counter = 0
    };
    // 12 monkeys ought to be enough for anybody
    let monkeys_p1 : [12]monkey = [dummy...];
    let monkeys_p2 : [12]monkey = [dummy...];

    for (let i = 0z; i < len(monkey_strings); i += 1) {
        monkey_init(&monkeys_p1, monkey_strings[i]);
        monkey_init(&monkeys_p2, monkey_strings[i]);
    };
    defer for (let i = 0z; i < len(monkeys_p1); i += 1) {
        free(monkeys_p1[i].action);
        free(monkeys_p1[i].held);
    };
    defer for (let i = 0z; i < len(monkeys_p2); i += 1) {
        free(monkeys_p1[i].action);
        free(monkeys_p1[i].held);
    };

    fmt::println("Hello, world!")!;
    for (let i = 0z; i < 20; i += 1) {
        do_round(&monkeys_p1, 0, true);
    };
    fmt::println(monkeys_p1[0].counter)!;
    fmt::println(monkeys_p1[1].counter)!;
    fmt::println(monkeys_p1[2].counter)!;
    fmt::println(monkeys_p1[3].counter)!;
    fmt::println(monkeys_p1[4].counter)!;
    fmt::println(monkeys_p1[5].counter)!;
    fmt::println(monkeys_p1[6].counter)!;
    fmt::println(monkeys_p1[7].counter)!;
};
