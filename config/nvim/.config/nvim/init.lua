local vim = vim
local o = vim.opt
local g = vim.g
local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup("user.cfg", { clear = true })

-- options --

g.mapleader = " "
g.maplocalleader = " "
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

o.relativenumber = false
o.number = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true
o.wrap = false
o.signcolumn = "yes"
o.completeopt = { "menuone", "noselect", "popup" }
o.pumheight = 15
o.winborder = "rounded"
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.swapfile = false
o.termguicolors = true
o.splitbelow = true
o.splitright = true
o.cursorline = true
o.scrolloff = 8
o.clipboard = "unnamedplus"
o.foldmethod = "indent"
o.foldlevelstart = 99

-- hooks --

autocmd("PackChanged", {
  group = augroup,
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

-- plugins --

vim.pack.add({
  "https://github.com/EdenEast/nightfox.nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/folke/flash.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/sphamba/smear-cursor.nvim",
})

-- colorscheme --

vim.cmd.colorscheme("nordfox")

-- treesitter --

autocmd("FileType", {
  group = augroup,
  callback = function(ev)
    if pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },
  move = { set_jumps = true },
})

local ts_select = require("nvim-treesitter-textobjects.select").select_textobject
map({ "x", "o" }, "af", function()
  ts_select("@function.outer", "textobjects")
end)
map({ "x", "o" }, "if", function()
  ts_select("@function.inner", "textobjects")
end)
map({ "x", "o" }, "ac", function()
  ts_select("@class.outer", "textobjects")
end)
map({ "x", "o" }, "ic", function()
  ts_select("@class.inner", "textobjects")
end)
map({ "x", "o" }, "aa", function()
  ts_select("@parameter.outer", "textobjects")
end)
map({ "x", "o" }, "ia", function()
  ts_select("@parameter.inner", "textobjects")
end)

local ts_move = require("nvim-treesitter-textobjects.move")
map({ "n", "x", "o" }, "]f", function()
  ts_move.goto_next_start("@function.outer", "textobjects")
end)
map({ "n", "x", "o" }, "]c", function()
  ts_move.goto_next_start("@class.outer", "textobjects")
end)
map({ "n", "x", "o" }, "[f", function()
  ts_move.goto_previous_start("@function.outer", "textobjects")
end)
map({ "n", "x", "o" }, "[c", function()
  ts_move.goto_previous_start("@class.outer", "textobjects")
end)

require("nvim-ts-autotag").setup()

-- lsp --

require("mason").setup()

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({ -- :MasonInstall gopls vtsls svelte-language-server tailwindcss-language-server
  "gopls", --   terraform-ls dockerfile-language-server json-lsp yaml-language-server
  "vtsls", --   lua-language-server prettierd goimports stylua
  "svelte",
  "tailwindcss",
  "terraformls",
  "dockerls",
  "jsonls",
  "yamlls",
  "lua_ls",
})

autocmd("LspAttach", {
  group = augroup,
  callback = function(ev)
    local bufopts = { buffer = ev.buf, silent = true }
    map("n", "gd", vim.lsp.buf.definition, bufopts)
    map("n", "gD", vim.lsp.buf.declaration, bufopts)
    map("n", "gI", vim.lsp.buf.implementation, bufopts)
    map("n", "gy", vim.lsp.buf.type_definition, bufopts)
    map("i", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code action" })
    map("n", "<leader>cr", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename" })

    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

-- formatting --

require("conform").setup({
  formatters_by_ft = {
    go = { "gofmt", "goimports" },
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    svelte = { "prettierd" },
    json = { "prettierd" },
    yaml = { "prettierd" },
    markdown = { "prettierd" },
    css = { "prettierd" },
    html = { "prettierd" },
    lua = { "stylua" },
    terraform = { "terraform_fmt" },
  },
  format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
})

-- plugin setup --

require("flash").setup()

require("fzf-lua").setup({
  "default-title",
  winopts = { preview = { layout = "vertical" } },
})

require("mini.ai").setup()
require("mini.surround").setup({
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    update_n_lines = "gsn",
  },
})
require("mini.pairs").setup()
require("mini.icons").setup()
require("mini.files").setup()
require("mini.statusline").setup()
require("mini.notify").setup()
require("mini.diff").setup()
require("mini.bracketed").setup()
require("mini.move").setup()
require("mini.cursorword").setup()
require("mini.splitjoin").setup()
require("mini.indentscope").setup()
require("mini.trailspace").setup()
require("mini.hipatterns").setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
  },
})
require("mini.operators").setup({
  sort = { prefix = "go" },
})
require("mini.git").setup()
require("mini.comment").setup()
require("mini.sessions").setup()
require("mini.tabline").setup()
require("mini.bufremove").setup()

local starter = require("mini.starter")
starter.setup({
  header = table.concat({
    "          ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
    "          ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
    "          ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
    "          ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "          ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "          ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
  }, "\n"),
  items = {
    { name = "Find File", action = "FzfLua files", section = "Actions" },
    { name = "New File", action = "enew | startinsert", section = "Actions" },
    { name = "Find Text", action = "FzfLua live_grep", section = "Actions" },
    { name = "Recent Files", action = "FzfLua oldfiles", section = "Actions" },
    { name = "Config", action = "FzfLua files cwd=" .. vim.fn.stdpath("config"), section = "Actions" },
    { name = "Mason", action = "Mason", section = "Actions" },
    { name = "Quit", action = "qa", section = "Actions" },
    starter.sections.recent_files(5, false, false, function(path)
      return vim.fn.fnamemodify(path, ":~:.")
    end),
  },
  footer = "",
})

require("mini.clue").setup({
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "x", keys = "[" },
    { mode = "x", keys = "]" },
  },
  clues = {
    { mode = "n", keys = "<Leader>f", desc = "+find" },
    { mode = "n", keys = "<Leader>g", desc = "+git" },
    { mode = "n", keys = "<Leader>r", desc = "+remove" },
    { mode = "n", keys = "<Leader>c", desc = "+code" },
    { mode = "n", keys = "<Leader>b", desc = "+buffer" },
    { mode = "n", keys = "<Leader>w", desc = "+window" },
    { mode = "n", keys = "<Leader>q", desc = "+quit" },
    { mode = "n", keys = "<Leader>u", desc = "+ui/toggle" },
    require("mini.clue").gen_clues.builtin_completion(),
    require("mini.clue").gen_clues.g(),
    require("mini.clue").gen_clues.marks(),
    require("mini.clue").gen_clues.registers(),
    require("mini.clue").gen_clues.windows(),
    require("mini.clue").gen_clues.z(),
  },
})

require("smear_cursor").setup()

autocmd("InsertEnter", {
  group = augroup,
  once = true,
  callback = function()
    vim.pack.add({ "https://github.com/zbirenbaum/copilot.lua" })
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          accept_word = "<C-Right>",
          accept_line = "<C-End>",
          next = "<A-]>",
          prev = "<A-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        markdown = true,
        yaml = true,
      },
    })
  end,
})

-- keymaps --

local opts = { silent = true }

map("n", "Q", "<nop>", opts)
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map({ "i", "n" }, "<Esc>", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })
map("n", "<leader>y", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
end, { desc = "Copy filepath" })
map("n", "<leader>Y", "<cmd>%y+<cr>", { desc = "Copy entire file" })

map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader><leader>", "<cmd>FzfLua files<cr>", { desc = "Find files" })
map("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent files" })
map("n", "<leader>fw", "<cmd>FzfLua grep_cword<cr>", { desc = "Grep word" })
map("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Diagnostics" })
map("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "Symbols" })
map("n", "<leader>fh", "<cmd>FzfLua helptags<cr>", { desc = "Help" })
map("n", "<leader>fk", "<cmd>FzfLua keymaps<cr>", { desc = "Keymaps" })
map("n", "<leader>fg", "<cmd>FzfLua git_status<cr>", { desc = "Git status" })

map("n", "<leader>e", function()
  require("mini.files").open()
end, { desc = "File browser" })

map({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash" })
map({ "n", "x", "o" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash treesitter" })

map("n", "<C-h>", "<cmd>wincmd h<cr>", opts)
map("n", "<C-j>", "<cmd>wincmd j<cr>", opts)
map("n", "<C-k>", "<cmd>wincmd k<cr>", opts)
map("n", "<C-l>", "<cmd>wincmd l<cr>", opts)
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split below" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "<leader>wd", "<cmd>close<cr>", { desc = "Close window" })

map("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Delete buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Alternate buffer" })
map("n", "<S-h>", "<cmd>bprev<cr>", opts)
map("n", "<S-l>", "<cmd>bnext<cr>", opts)

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

map("t", "<Esc><Esc>", [[<C-\><C-n>]], opts)

-- ui toggles --

map("n", "<leader>uw", function()
  vim.o.wrap = not vim.o.wrap
end, { desc = "Toggle word wrap" })
map("n", "<leader>ul", function()
  vim.o.number = not vim.o.number
end, { desc = "Toggle line numbers" })
map("n", "<leader>uL", function()
  vim.o.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle relative numbers" })
map("n", "<leader>us", function()
  vim.o.spell = not vim.o.spell
end, { desc = "Toggle spelling" })
map("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- autocmds --

autocmd("BufEnter", {
  group = augroup,
  callback = function()
    o.formatoptions:remove({ "c", "r", "o" })
  end,
})

autocmd("FileType", {
  group = augroup,
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- extui --

pcall(function()
  require("vim._extui").enable({})
end)

-- utilities --

require("remove-comments")
