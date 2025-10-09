rockspec_format = "3.0"
package = "code-cells.nvim"
version = "scm-1"

test_dependencies = {
  "lua >= 5.1",
  "nlua",
}

source = {
  url = "git://github.com/mwoitek/" .. package,
}

build = {
  type = "builtin",
}
