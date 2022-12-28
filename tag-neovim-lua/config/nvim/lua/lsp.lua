local wk = require "which-key"
local typescript = require "typescript"
local null_ls = require "null-ls"
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return client.name == "null-ls" or client.name == "sumneko_lua" or client.name == "tsserver"
    end,
    bufnr
  })
end
local on_attach = function(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function() lsp_formatting(bufnr) end
    })
  end
end

require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require("mason-lspconfig").setup()
require("lspconfig").flow.setup { capabilities = capabilities }
require("lspconfig").sumneko_lua.setup {
  capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
  end,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim", "use" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false }
    }
  }
}

require("rust-tools").setup {
  capabilities,
  server = {
    -- disable inlayHints until resolved https://github.com/simrat39/rust-tools.nvim/issues/300
    settings = { ["rust-analyzer"] = { inlayHints = { locationLinks = false } } }
  }
}

null_ls.setup({
  debug = true,
  on_attach = function(client, bufnr) on_attach(client, bufnr) end,
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.diagnostics.actionlint,
    null_ls.builtins.diagnostics.eslint, null_ls.builtins.code_actions.eslint,
    require("typescript.extensions.null-ls.code-actions")
  }
})

typescript.setup({
  disable_commands = false,
  server = {
    root_dir = require("lspconfig.util").root_pattern("tsconfig.json"),
    settings = {
      typescript = {
        format = {
          -- indentSize = 2
        },
      },
    },
    capabilities,
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
    end,
  }
})

wk.register({
  ["<space>f"] = { vim.lsp.buf.format, "Format with lsp" },
  ["<space>e"] = { vim.diagnostic.open_float, "Open float" },
  ["<space>q"] = { vim.diagnostic.setloclist, "Set loc list" },
  ["[d"] = { vim.diagnostic.goto_prev, "" },
  ["]d"] = { vim.diagnostic.goto_next, "" },
  ["]D"] = { function() vim.diagnostic.goto_prev { wrap = false } end, "" },
  ["[D"] = { function() vim.diagnostic.goto_next { wrap = false } end, "" }
})

wk.register({
  ["gd"] = { vim.lsp.buf.definition, "Definition" },
  ["gD"] = { vim.lsp.buf.declaration, "Declaration" },
  ["gr"] = { vim.lsp.buf.references, "References" },
  ["gi"] = { vim.lsp.buf.implementation, "Implementation" },
  ["gq"] = { vim.lsp.buf.formatting, "Format" }
})

wk.register({
  w = {
    a = { vim.lsp.buf.add_workspace_folder, "Add workspace" },
    r = { vim.lsp.buf.remove_workspace_folder, "Remove workspace" },
    l = {
      "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>",
      "List workspace"
    }
  },
  ["so"] = {
    function() require("telescope.builtin").lsp_document_symbols() end,
    "Show symbols"
  },
  ["ca"] = { vim.lsp.buf.code_action, "Code action" },
  ["rn"] = { vim.lsp.buf.rename, "Rename" }
}, { prefix = "<leader>" })

wk.register({
  K = { vim.lsp.buf.hover, "Hover" },
  ["<C-k>"] = { vim.lsp.buf.type_definition, "Definition" },
  ["1gd"] = { vim.lsp.buf.document_symbol, "Document symbol" },
  ["1gD"] = { vim.lsp.buf.workspace_symbol, "" }
})

wk.register({
  ["ca"] = { vim.lsp.buf.range_code_action, "Code action on selected lines" }
}, { mode = "v", prefix = "<leader>" })

wk.register({
  s = { "<cmd>TypescriptOrganizeImports<cr>", "TS Import sort" },
  S = { "<cmd>TypescriptRemoveUnused<cr>", "TS Remove unused vars" },
  F = { "<cmd>TypescriptFixAll<cr>", "TS Fix all" },
  R = { "<cmd>TypescriptRenameFile<cr>", "TS Rename file" },
  I = { "<cmd>TypescriptAddMissingImports<cr>", "TS Import all" },
  G = { "<cmd>TypescriptGoToSourceDefinition<cr>", "TS Go to source definition" }
}, { prefix = "g" })
