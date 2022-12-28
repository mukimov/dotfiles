local wk = require "which-key"
local escape = vim.fn.fnameescape
local buf_name = vim.api.nvim_buf_get_name

local prettier = function()
  local exe = "prettier"

  return {
    exe = exe,
    args = { "--stdin-filepath", escape(buf_name(0)), "" },
    stdin = true
  }
end

local lua = function()
  return {
    exe = "lua-format",
    args = {
      "--tab-width", 2, "--indent-width", 2, "--single-quote-to-double-quote"
    },
    stdin = true
  }
end

local rust = function()
  return {
    exe = "rustfmt",
    args = { "--emit=stdout", "--edition=2021" },
    stdin = true
  }
end

local terraform = function()
  return { exe = "terraform", args = { "fmt", "-" }, stdin = true }
end

local go = function() return { exe = "gofmt", args = { "-w" }, stdin = true } end

local shfmt = function()
  return { exe = "shfmt", args = { "-w" }, stdin = false }
end

require("formatter").setup({
  filetype = {
    javascript = { prettier },
    json = { prettier },
    typescript = { prettier },
    typescriptreact = { prettier },
    css = { prettier },
    html = { prettier },
    terraform = { terraform },
    go = { go },
    lua = { lua },
    rust = { rust },
    sh = { shfmt }
  }
})

wk.register({ F = { "<cmd>Format<cr>", "Format" } }, { prefix = "<leader>" })
