const std = @import("std");

const input_length = 100;
const multiplication = 42;
const plus = 43;
const minus = 45;

fn get_input() ![input_length]u8 {
    const in = std.io.getStdIn();
    var buf = std.io.bufferedReader(in.reader());

    var buf_reader = buf.reader();

    var input: [input_length]u8 = undefined;
    _ = try buf_reader.readUntilDelimiterOrEof(&input, '\n');
    return input;
}

fn find_index(input: [input_length]u8, target: u8) !u64 {
    for (input, 0..) |item, index| {
        if (item == target) return index;
    }
    return error.NotFound;
}

const SplitInput = struct {
    prefix: [input_length]u8,
    suffix: [input_length]u8,
};

fn split_on_operation(input: [input_length]u8, target_index: u64) SplitInput {
    var prefix: [input_length]u8 = undefined;
    var suffix: [input_length]u8 = undefined;
    var suffix_counter: u64 = 0;
    for (input, 0..) |item, index| {
        if (index < target_index) {
            prefix[index] = item;
        }
        if (index > target_index) {
            suffix[suffix_counter] = item;
            suffix_counter += 1;
        }

        if (item < 40 or item > 57) {
            break;
        }
    }
    return SplitInput{ .prefix = prefix, .suffix = suffix };
}

fn handle_multiplication(input: [input_length]u8, target_index: u64) i64 {
    var splitInput = split_on_operation(input, target_index);
    return calculate(splitInput.prefix) * calculate(splitInput.suffix);
}

fn handle_plus(input: [input_length]u8, target_index: u64) i64 {
    var splitInput = split_on_operation(input, target_index);
    return calculate(splitInput.prefix) + calculate(splitInput.suffix);
}

fn handle_minus(input: [input_length]u8, target_index: u64) i64 {
    var splitInput = split_on_operation(input, target_index);

    var is_negative_number = target_index == 0;
    if (is_negative_number) {
        return -calculate(splitInput.suffix);
    }
    return calculate(splitInput.prefix) - calculate(splitInput.suffix);
}

fn calculate(input: [input_length]u8) i64 {
    if (find_index(input, multiplication)) |target_index| {
        return handle_multiplication(input, target_index);
    } else |_| {}

    if (find_index(input, plus)) |target_index| {
        return handle_plus(input, target_index);
    } else |_| {}

    if (find_index(input, minus)) |target_index| {
        return handle_minus(input, target_index);
    } else |_| {}

    var number: i32 = 0;

    // we should only have numbers
    for (input) |byte| {
        if (byte < 48 or byte > 57) {
            break;
        }
        number = number * 10 + (byte - 48);
    }
    return number;
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("Example: 1+1\n", .{});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.

    var default: [input_length]u8 = undefined;
    var input = get_input() catch default;

    var answer = calculate(input);
    std.debug.print("{d}\n", .{answer});
}

test "1 + 1 = 2" {
    var input: [input_length]u8 = undefined;
    input[0] = 49;
    input[1] = plus;
    input[2] = 49;
    input[3] = 10;
    var result = calculate(input);
    var expected: i64 = 2;
    try std.testing.expectEqual(expected, result);
}

test "434 + 354 = 788" {
    var input: [input_length]u8 = undefined;
    input[0] = 52;
    input[1] = 51;
    input[2] = 52;
    input[3] = plus;
    input[4] = 51;
    input[5] = 53;
    input[6] = 52;
    input[7] = 10;
    var result = calculate(input);
    var expected: i64 = 788;
    try std.testing.expectEqual(expected, result);
}

test "1 - 1 = 0" {
    var input: [input_length]u8 = undefined;
    input[0] = 49;
    input[1] = minus;
    input[2] = 49;
    input[3] = 10;
    var result = calculate(input);
    var expected: i64 = 0;
    try std.testing.expectEqual(expected, result);
}

test "434 - 354 = 80" {
    var input: [input_length]u8 = undefined;
    input[0] = 52;
    input[1] = 51;
    input[2] = 52;
    input[3] = minus;
    input[4] = 51;
    input[5] = 53;
    input[6] = 52;
    input[7] = 10;
    var result = calculate(input);
    var expected: i64 = 80;
    try std.testing.expectEqual(expected, result);
}

test "-10 = -10" {
    var input: [input_length]u8 = undefined;
    input[0] = minus;
    input[1] = 49;
    input[2] = 48;
    input[3] = 10;
    var result = calculate(input);
    var expected: i64 = -10;
    try std.testing.expectEqual(expected, result);
}

test "-1 + 1 = 0" {
    var input: [input_length]u8 = undefined;
    input[0] = minus;
    input[1] = 49;
    input[2] = plus;
    input[3] = 49;
    input[4] = 10;
    var result = calculate(input);
    var expected: i64 = 0;
    try std.testing.expectEqual(expected, result);
}

test "1--1 = 2" {
    var input: [input_length]u8 = undefined;
    input[0] = 49;
    input[1] = minus;
    input[2] = minus;
    input[3] = 49;
    input[4] = 10;
    var result = calculate(input);
    var expected: i64 = 2;
    try std.testing.expectEqual(expected, result);
}

test "2 * 3 = 6" {
    var input: [input_length]u8 = undefined;
    input[0] = 50;
    input[1] = multiplication;
    input[2] = 51;
    input[3] = 10;
    var result = calculate(input);
    var expected: i64 = 6;
    try std.testing.expectEqual(expected, result);
}

test "2 * -3 = 6" {
    var input: [input_length]u8 = undefined;
    input[0] = 50;
    input[1] = multiplication;
    input[2] = minus;
    input[3] = 51;
    input[4] = 10;
    var result = calculate(input);
    var expected: i64 = -6;
    try std.testing.expectEqual(expected, result);
}
