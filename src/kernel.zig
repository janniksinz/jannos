const std = @import("std");

const bss = @extern([*]u8, .{ .name = "__bss" }); // variable defined in the linker script
const bss_end = @extern([*]u8, .{ .name = "__bss_end" });
const stack_top = @extern([*]u8, .{ .name = "__stack_top" });

export fn kernel_main() noreturn {
    const bss_len = bss_end - bss;
    @memset(bss[0..bss_len], 0);

    const hello = "Hello Kernel!\n";
    console.print("{s}", .{hello}) catch {};

    while (true) asm volatile ("wfi");
}

// .Naked = compiler do not generate unnecessary code before and after function (return)
// linksection(".text.boot") controls placement of the function in the linker script
//      OpenSBI jumps to 0x80200000 by default -> boot function needs to be placed there
export fn boot() linksection(".text.boot") callconv(.Naked) void {
    asm volatile (
        \\ mv sp, %[stack_top]
        \\ j kernel_main
        :
        : [stack_top] "r" (stack_top),
    );
}

const SbiRet = struct {
    err: usize,
    value: usize,
};

const console: std.io.AnyWriter = .{
    .context = undefined,
    .writeFn = write_fn,
};

fn write_fn(_: *const anyopaque, bytes: []const u8) !usize {
    for (bytes) |b| _ = sbi(b, 0, 0, 0, 0, 0, 0, 1);
    return bytes.len;
}

pub fn sbi(
    arg0: usize,
    arg1: usize,
    arg2: usize,
    arg3: usize,
    arg4: usize,
    arg5: usize,
    arg6: usize,
    arg7: usize,
) SbiRet {
    var err: usize = undefined;
    var value: usize = undefined;

    asm volatile ("ecall"
        : [err] "={a0}" (err),
          [value] "={a1}" (value),
        : [arg0] "{a0}" (arg0),
          [arg1] "{a1}" (arg1),
          [arg2] "{a2}" (arg2),
          [arg3] "{a3}" (arg3),
          [arg4] "{a4}" (arg4),
          [arg5] "{a5}" (arg5),
          [arg6] "{a6}" (arg6),
          [arg7] "{a7}" (arg7),
        : "memory"
    );

    return .{ .err = err, .value = value };
}
