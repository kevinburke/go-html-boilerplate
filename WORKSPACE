git_repository(
    name = "io_bazel_rules_go",
    remote = "https://github.com/bazelbuild/rules_go.git",
    tag = "0.5.1",
)
load("@io_bazel_rules_go//go:def.bzl", "go_repositories", "go_repository")

go_repository(
    name = "com_github_kisielk_gotool", 
    importpath = "github.com/kisielk/gotool",
    commit = "0de1eaf82fa3f583ce21fde859f1e7e0c5e9b220",
)

go_repository(
    name = "megacheck", 
    importpath = "honnef.co/go/tools",
    commit = "f583b587b6ff1149f9a9b0c16ebdda74da44e1a2",
)

go_repositories()
