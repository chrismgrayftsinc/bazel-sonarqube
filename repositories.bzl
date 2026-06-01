load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def bazel_sonarqube_repositories(
        bazel_version_repository_name = "bazel_version",
        sonar_scanner_cli_version = "8.1.0.6389",
        sonar_scanner_cli_sha256 = "ab76ab3c360025e9108be5b55be066f304a164f8b2850d2f2f333915db51bc1b",
        bazel_skylib_version = "1.6.1",
        bazel_skylib_sha256 = "9f38886a40548c6e96c106b752f242130ee11aaa068a56ba7e56f4511f33e4f2"):
    http_archive(
        name = "org_sonarsource_scanner_cli_sonar_scanner_cli",
        build_file = "@bazel_sonarqube//:BUILD.sonar_scanner",
        sha256 = sonar_scanner_cli_sha256,
        strip_prefix = "sonar-scanner-" + sonar_scanner_cli_version,
        urls = [
            "https://repo1.maven.org/maven2/org/sonarsource/scanner/cli/sonar-scanner-cli/%s/sonar-scanner-cli-%s.zip" % (sonar_scanner_cli_version, sonar_scanner_cli_version),
            "https://jcenter.bintray.com/org/sonarsource/scanner/cli/sonar-scanner-cli/%s/sonar-scanner-cli-%s.zip" % (sonar_scanner_cli_version, sonar_scanner_cli_version),
        ],
    )

    if not native.existing_rule("bazel_skylib"):
        http_archive(
            name = "bazel_skylib",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/%s/bazel-skylib-%s.tar.gz" % (bazel_skylib_version, bazel_skylib_version),
                "https://github.com/bazelbuild/bazel-skylib/releases/download/%s/bazel-skylib-%s.tar.gz" % (bazel_skylib_version, bazel_skylib_version),
            ],
            sha256 = bazel_skylib_sha256,
        )

    bazel_version_repository(name = bazel_version_repository_name)

# A hacky way to work around the fact that native.bazel_version is only
# available from WORKSPACE macros, not BUILD.bazel macros or rules.
#
# Hopefully we can remove this if/when this is fixed:
#   https://github.com/bazelbuild/bazel/issues/8305
def _bazel_version_repository_impl(repository_ctx):
    s = "bazel_version = \"" + native.bazel_version + "\""
    repository_ctx.file("bazel_version.bzl", s)
    repository_ctx.file("BUILD.bazel", """
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "bazel_version",
    srcs = ["bazel_version.bzl"],
    visibility = ["//visibility:public"],
)
""")

bazel_version_repository = repository_rule(
    implementation = _bazel_version_repository_impl,
    local = True,
)
