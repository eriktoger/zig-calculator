const constants = @import("constants.zig");
const std = @import("std");
const calculate = @import("main.zig").calculate;

fn copy_before_parenthesis(input: [constants.input_length]u8, new_input: *[constants.input_length]u8, target_index: u64) u64 {
    var before_index: u64 = 0;
    while (before_index < target_index) {
        new_input[before_index] = input[before_index];
        before_index += 1;
    }
    return before_index;
}

fn resolve_parenthesis(input: [constants.input_length]u8, new_input: *[constants.input_length]u8, target_index: u64, current_index: u64, before_index: u64) !u64 {
    var inside_parenthesis: [constants.input_length]u8 = undefined;
    var inside_index: u64 = 0;
    var input_index = target_index + 1;
    while (inside_index < current_index) {
        inside_parenthesis[inside_index] = input[input_index];
        inside_index += 1;
        input_index += 1;
    }
    var calculated_inside_number = calculate(inside_parenthesis);
    var calculated_inside_chars: [constants.input_length]u8 = undefined;
    _ = try std.fmt.bufPrint(&calculated_inside_chars, "{}", .{calculated_inside_number});

    var calculated_index = before_index;
    for (calculated_inside_chars) |byte| {
        if (byte == 170) {
            break;
        }
        new_input[calculated_index] = byte;
        calculated_index += 1;
    }

    return calculated_index;
}

fn copy_after_parenthesis(input: [constants.input_length]u8, new_input: *[constants.input_length]u8, current_index: u64, calculated_index: u64) void {
    var new_after_index = calculated_index;
    var old_after_index = current_index + 1;
    while (old_after_index < constants.input_length and new_after_index < constants.input_length) {
        new_input[new_after_index] = input[old_after_index];
        new_after_index += 1;
        old_after_index += 1;
    }
}

pub fn handle_parenthesis(input: [constants.input_length]u8, target_index: u64) i64 {
    var current_index = target_index + 1;
    var nr_of_lefts: u64 = 1;
    var nr_of_rights: u64 = 0;

    while (current_index < constants.input_length) {
        if (input[current_index] == constants.left_parenthesis) {
            nr_of_lefts += 1;
        }
        if (input[current_index] == constants.right_parenthesis) {
            nr_of_rights += 1;
        }

        if (nr_of_lefts == nr_of_rights) {
            var new_input: [constants.input_length]u8 = undefined;
            var before_index = copy_before_parenthesis(input, &new_input, target_index);
            var calculated_index = resolve_parenthesis(input, &new_input, target_index, current_index, before_index);
            if (calculated_index) |number| {
                copy_after_parenthesis(input, &new_input, current_index, number);
                return calculate(new_input);
            } else |_| {
                unreachable;
            }
        }
        current_index += 1;
    }

    unreachable;
}

test "(1 + 1) * 2 = 4" {
    var input: [constants.input_length]u8 = undefined;
    input[0] = constants.left_parenthesis;
    input[1] = 49;
    input[2] = constants.plus;
    input[3] = 49;
    input[4] = constants.right_parenthesis;
    input[5] = constants.multiplication;
    input[6] = 50;
    input[7] = 10;
    var result = calculate(input);
    var expected: i64 = 4;
    try std.testing.expectEqual(expected, result);
}

test "(2 * ( 4 + 1 )) * 2 = 20" {
    // this should be a helper function
    var input: [constants.input_length]u8 = undefined;
    var input_string = "(2*(4+1))*2";
    for (input_string, 0..) |chr, index| {
        input[index] = chr;
    }

    var result = calculate(input);
    var expected: i64 = 20;
    try std.testing.expectEqual(expected, result);
}
