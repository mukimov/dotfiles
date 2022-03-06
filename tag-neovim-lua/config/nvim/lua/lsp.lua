local lsp_installer = require "nvim-lsp-installer"
local ts_utils = require "nvim-lsp-ts-utils"
local wk = require "which-key"

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
    client.config.flags.debounce_text_changes = 100
  end

  wk.register({
    d = {vim.lsp.buf.definition, "Definition"},
    D = {vim.lsp.buf.declaration, "Declaration"},
    r = {vim.lsp.buf.references, "References"},
    i = {vim.lsp.buf.implementation, "Implementation"}
  }, {prefix = "g"})

  wk.register({
    w = {
      a = {vim.lsp.buf.add_workspace_folder, "Add workspace"},
      r = {vim.lsp.buf.remove_workspace_folder, "Remove workspace"},
      l = {
        "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>",
        "List workspace"
      }
    },
    e = {vim.lsp.diagnostic.show_line_diagnostics, "Show line diagnostics"},
    q = {vim.lsp.diagnostic.set_loclist, "LocList"},
    ["so"] = {
      function() require("telescope.builtin").lsp_document_symbols() end,
      "Show symbols"
    },
    ["ca"] = {vim.lsp.buf.code_action, "Code action"},
    ["rn"] = {vim.lsp.buf.rename, "Rename"}
  }, {prefix = "<leader>"})

  wk.register({
    K = {vim.lsp.buf.hover, "Hover"},
    ["<C-k"] = {vim.lsp.buf.type_definition, "Definition"},
    ["1gd"] = {vim.lsp.buf.document_symbol, "Document symbol"},
    ["1gD"] = {vim.lsp.buf.workspace_symbol, ""},
    ["[d"] = {vim.lsp.diagnostic.goto_prev, ""},
    ["]d"] = {vim.lsp.diagnostic.goto_next, ""},
    ["]D"] = {function() vim.lsp.diagnostic.goto_prev {wrap = false} end, ""},
    ["[D"] = {function() vim.lsp.diagnostic.goto_next {wrap = false} end, ""},
    ["gq"] = {
      function()
        if client.resolved_capabilities.document_formatting then
          vim.lsp.buf.formatting()
        elseif client.resolved_capabilities.document_range_formatting then
          vim.lsp.buf.formatting()
        end
      end
    }
  })

  wk.register({["ca"] = {vim.lsp.buf.range_code_action}},
              {mode = "v", prefix = "<leader>"})

  if client.resolved_capabilities.code_lens then
    wk.register({["gl"] = {vim.lsp.codelens.run, "Code lens"}});
    vim.api
        .nvim_command [[autocmd CursorHold,CursorHoldI,InsertLeave <buffer> lua vim.lsp.codelens.refresh()]]
  end

  if client.name == "tsserver" then
    ts_utils.setup {
      debug = false,
      disable_commands = false,
      enable_import_on_completion = false,

      import_all_timeout = 5000,
      import_all_scan_buffers = 100,
      import_all_select_source = false,
      import_all_priorities = {
        buffers = 4, -- loaded buffer names
        buffer_content = 3, -- loaded buffer content
        local_files = 2, -- git files or files with relative path markers
        same_file = 1 -- add to existing import statement
      },

      eslint_enable_code_actions = true,
      eslint_bin = "eslint",
      eslint_enable_disable_comments = true,
      eslint_enable_diagnostics = true,
      eslint_config_fallback = nil,

      enable_formatting = true,
      formatter = "prettier",
      formatter_config_fallback = nil,

      update_imports_on_move = false,
      require_confirmation_on_move = false,
      watch_dir = nil
    }

    ts_utils.setup_client(client)

    wk.register({
      s = {"<cmd>TSLspOrganize<cr>", "Import sort"},
      r = {"<cmd>TSLspRenameFile<cr>", "Rename file"},
      i = {"<cmd>TSLspImportAll<cr>", "Impoer all"}
    }, {prefix = "g"})
  end

  vim.cmd [[autocmd CursorHold,CursorHoldI <buffer> lua require'nvim-lightbulb'.update_lightbulb()]]
end

local lua_settings = {
  Lua = {
    runtime = {
      -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
      version = "LuaJIT"
      -- Setup your lua path
      -- path = runtime_path,
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      globals = {"vim", "use"}
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = vim.api.nvim_get_runtime_file("", true)
    },
    -- Do not send telemetry data containing a randomized but unique identifier
    telemetry = {enable = false}
  }
}

local function make_config()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {"documentation", "detail", "additionalTextEdits"}
  }

  return {on_attach = on_attach, capabilities = capabilities}
end

lsp_installer.on_server_ready(function(server)
  local opts = make_config()

  -- if server.name == 'rust-analyzer' then end
  if server.name == "sumneko_lua" then opts.settings = lua_settings end
  if server.name == "tsserver" then opts.init_options = ts_utils.init_options end

  server:setup(opts)
end)
