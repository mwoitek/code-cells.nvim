rockspec_format = "3.0"
package = "code-cells.nvim"
version = "scm-1"

test_dependencies = {
  "nlua",
}

source = {
  url = "git://github.com/mwoitek/" .. package,
}

build = {
  type = "builtin",
  copy_directories = {
    "plugin",
  },
}
