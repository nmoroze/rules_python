""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# Avoid a load from @bazel_skylib repository as users don't necessarily have it installed
load("//third_party/github.com/bazelbuild/bazel-skylib/lib:versions.bzl", "versions")

_RULE_DEPS = [
    (
        "pypi__click",
        "https://files.pythonhosted.org/packages/76/0a/b6c5f311e32aeb3b406e03c079ade51e905ea630fc19d1262a46249c1c86/click-8.0.1-py3-none-any.whl",
        "fba402a4a47334742d782209a7c79bc448911afe1149d07bdabdf480b3e2f4b6",
    ),
    (
        "pypi__colorama",
        "https://files.pythonhosted.org/packages/44/98/5b86278fbbf250d239ae0ecb724f8572af1c91f4a11edf4d36a206189440/colorama-0.4.4-py2.py3-none-any.whl",
        "9f47eda37229f68eee03b24b9748937c7dc3868f906e8ba69fbcbdd3bc5dc3e2",
    ),
    (
        "pypi__pip",
        "https://files.pythonhosted.org/packages/4d/16/0a14ca596f30316efd412a60bdfac02a7259bf8673d4d917dc60b9a21812/pip-22.0.4-py3-none-any.whl",
        "c6aca0f2f081363f689f041d90dab2a07a9a07fb840284db2218117a52da800b",
    ),
    (
        "pypi__pip_tools",
        "https://files.pythonhosted.org/packages/6d/16/75d65bdccd48bb59a08e2bf167b01d8532f65604270d0a292f0f16b7b022/pip_tools-5.5.0-py2.py3-none-any.whl",
        "10841c1e56c234d610d0466447685b9ea4ee4a2c274f858c0ef3c33d9bd0d985",
    ),
    (
        "pypi__pkginfo",
        "https://files.pythonhosted.org/packages/fa/3d/f4f2ba829efb54b6cd2d91349c7463316a9cc55a43fc980447416c88540f/pkginfo-1.12.1.2-py3-none-any.whl",
        "c783ac885519cab2c34927ccfa6bf64b5a704d7c69afaea583dd9b7afe969343",
    ),
    (
        "pypi__setuptools",
        "https://files.pythonhosted.org/packages/7c/5b/3d92b9f0f7ca1645cba48c080b54fe7d8b1033a4e5720091d1631c4266db/setuptools-60.10.0-py3-none-any.whl",
        "782ef48d58982ddb49920c11a0c5c9c0b02e7d7d1c2ad0aa44e1a1e133051c96",
    ),
    (
        "pypi__wheel",
        "https://files.pythonhosted.org/packages/27/d6/003e593296a85fd6ed616ed962795b2f87709c3eee2bca4f6d0fe55c6d00/wheel-0.37.1-py2.py3-none-any.whl",
        "4bdcd7d840138086126cd09254dc6195fb4fc6f01c050a1d7236f2630db1d22a",
    ),
]

_GENERIC_WHEEL = """\
package(default_visibility = ["//visibility:public"])

load("@rules_python//python:defs.bzl", "py_library")

py_library(
    name = "lib",
    srcs = glob(["**/*.py"]),
    data = glob(["**/*"], exclude=["**/*.py", "**/* *", "BUILD", "WORKSPACE"]),
    # This makes this directory a top-level in the python import
    # search path for anything that depends on this.
    imports = ["."],
)
"""

# Collate all the repository names so they can be easily consumed
all_requirements = [name for (name, _, _) in _RULE_DEPS]

def requirement(pkg):
    return "@pypi__" + pkg + "//:lib"

def pip_install_dependencies():
    """
    Fetch dependencies these rules depend on. Workspaces that use the pip_install rule can call this.

    (However we call it from pip_install, making it optional for users to do so.)
    """

    # We only support Bazel LTS and rolling releases.
    # Give the user an obvious error to upgrade rather than some obscure missing symbol later.
    # It's not guaranteed that users call this function, but it's used by all the pip fetch
    # repository rules so it's likely that most users get the right error.
    versions.check("4.0.0")

    for (name, url, sha256) in _RULE_DEPS:
        maybe(
            http_archive,
            name,
            url = url,
            sha256 = sha256,
            type = "zip",
            build_file_content = _GENERIC_WHEEL,
        )
