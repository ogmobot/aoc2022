use fmt;
use io;
use os;
use regex;
use strconv;
use strings;

type monkey = struct {
    active  : bool,
    action  : str,
    held    : []u64,
    divisor : u64,
    dest_T  : size,
    dest_F  : size,
    counter : u64
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
        append(monkeys[m].held, strconv::stou64(items[i])!);
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
    monkeys[m].divisor = strconv::stou64(strings::next_token(&tokens) as str)!;
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

fn operate(old : u64, operation : str) u64 = {
    let tokens = strings::tokenize(operation, " ");
    let a : u64 = 0;
    const stra = strings::next_token(&tokens) as str;
    if (strings::compare("old", stra) == 0) {
        a = old;
    } else {
        a = strconv::stou64(stra)!;
    };
    const op = strings::next_token(&tokens) as str;
    let b : u64 = 0;
    const strb = strings::next_token(&tokens) as str;
    if (strings::compare("old", strb) == 0) {
        b = old;
    } else {
        b = strconv::stou64(strb)!;
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

fn do_round(monkeys : *[12]monkey, who : size, modder : (void | u64)) void = {
    // Recurses until it reaches a non-active monkey
    if (!monkeys[who].active) {
        return;
    };

    for (len(monkeys[who].held) > 0) {
        monkeys[who].counter += 1;
        let value = monkeys[who].held[0];
        delete(monkeys[who].held[0]);
        value = operate(value, monkeys[who].action);
        match (modder) {
        case void => value /= 3;
        case let modval : u64 => value %= modval;
        };
        if (value % monkeys[who].divisor == 0) {
            append(monkeys[monkeys[who].dest_T].held, value);
        } else {
            append(monkeys[monkeys[who].dest_F].held, value);
        };
    };

    do_round(monkeys, who + 1, modder);
    return;
};

fn monkey_business(monkeys : *[12]monkey) u64 = {
    let first  : u64 = 0;
    let second : u64 = 0;
    for (let who = 0; monkeys[who].active; who += 1) {
        if (monkeys[who].counter > first) {
            second = first;
            first = monkeys[who].counter;
        } else {
            if (monkeys[who].counter > second) {
                second = monkeys[who].counter;
            };
        };
    };
    return first * second;
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

    // Part 1
    for (let i = 0z; i < 20; i += 1) {
        do_round(&monkeys_p1, 0, void);
    };
    fmt::println(monkey_business(&monkeys_p1))!;
    // Part 2
    let modval : u64 = 1;
    for (let who = 0z; monkeys_p2[who].active; who += 1) {
        modval *= monkeys_p2[who].divisor;
    };
    for (let i = 0z; i < 10000; i += 1) {
        do_round(&monkeys_p2, 0, modval);
    };
    fmt::println(monkey_business(&monkeys_p2))!;
};
