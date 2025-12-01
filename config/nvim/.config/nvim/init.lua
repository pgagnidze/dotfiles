-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Open explorer and terminal when opening a project
local project_opened = false
local function open_project_layout()
  if not project_opened and Snacks and Snacks.explorer then
    project_opened = true
    Snacks.explorer.open({ hidden = true, ignored = true })
    Snacks.terminal.toggle(nil, { win = { position = "bottom" } })
  end
end

-- When selecting a project from dashboard
vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    vim.schedule(open_project_layout)
  end,
})

-- When starting nvim with a directory (nvim .)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if vim.fn.argc() == 1 and vim.fn.isdirectory(arg) == 1 then
      -- Delay to let netrw replacement open explorer first, then close and reopen with hidden files
      vim.defer_fn(function()
        if Snacks and Snacks.explorer and not project_opened then
          project_opened = true
          -- Close the auto-opened explorer, then reopen with our settings
          Snacks.explorer.open() -- toggle close
          Snacks.explorer.open({ hidden = true, ignored = true }) -- open with hidden
          Snacks.terminal.toggle(nil, { win = { position = "bottom" } })
        end
      end, 100)
    end
  end,
})
