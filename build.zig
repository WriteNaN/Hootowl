const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // w
    _ = b.addModule("webview", .{ .root_source_file = .{ .path = "src/webview/webview.zig" }, .optimize = optimize, .target = target });

    const sharedLib = b.addSharedLibrary(.{
        .name = "webviewShared",
        .optimize = optimize,
        .target = target,
    });
    sharedLib.defineCMacro("WEBVIEW_BUILD_SHARED", null);
    sharedLib.linkLibCpp();

    switch (target.query.os_tag orelse @import("builtin").os.tag) {
        .windows => {
            sharedLib.addCSourceFile(.{ .file = .{ .path = "src/webview/lib/webview/webview.cc" }, .flags = &.{"-std=c++14"} });
            sharedLib.addIncludePath(std.Build.LazyPath.relative("src/webview/lib/WebView2/"));
            sharedLib.linkSystemLibrary("ole32");
            sharedLib.linkSystemLibrary("shlwapi");
            sharedLib.linkSystemLibrary("version");
            sharedLib.linkSystemLibrary("advapi32");
            sharedLib.linkSystemLibrary("shell32");
            sharedLib.linkSystemLibrary("user32");
        },
        .macos => {
            sharedLib.addCSourceFile(.{ .file = .{ .path = "src/webview/lib/webview/webview.cc" }, .flags = &.{"-std=c++11"} });
            sharedLib.linkFramework("WebKit");
        },
        else => {
            sharedLib.addCSourceFile(.{ .file = .{ .path = "src/webview/lib/webview/webview.cc" }, .flags = &.{"-std=c++11"} });
            sharedLib.linkSystemLibrary("gtk+-3.0");
            sharedLib.linkSystemLibrary("webkit2gtk-4.0");
        },
    }
    b.installArtifact(sharedLib);

    // end w

    const exe = b.addExecutable(.{
        .name = "hootowl",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();
    exe.linkLibrary(sharedLib); 

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the program");
    run_step.dependOn(&run_cmd.step);
}