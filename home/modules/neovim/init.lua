vim.g.mapleader = ' '

vim.o.number = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }

local map = vim.keymap.set

-- Tabs
map('n', '<leader>tn', '<cmd>tabnew<cr>')
map('n', '<leader>tc', '<cmd>tabclose<cr>')

-- Panes
map('n', '<leader>v', '<cmd>vsplit<cr>')
map('n', '<leader>s', '<cmd>split<cr>')
map('n', '<leader>x', '<C-w>c')
for _, d in ipairs({ 'h', 'j', 'k', 'l' }) do
  map({ 'n', 't' }, '<A-' .. d .. '>', '<C-\\><C-n><C-w>' .. d)
  map('n', '<A-' .. d:upper() .. '>', '<C-w>' .. d:upper())
end
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>')
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>')
map('n', '<C-Down>', '<cmd>resize -2<cr>')
map('n', '<C-Up>', '<cmd>resize +2<cr>')

-- File search
map('n', '<C-p>', function() require('telescope.builtin').find_files() end)

-- File tree (replaces netrw)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require('nvim-tree').setup()
local tree = require('nvim-tree.api').tree
map('n', '<leader>e', function()
  if vim.bo.filetype == 'NvimTree' then vim.cmd.wincmd('p') else tree.focus() end
end)
map('n', '<leader>E', function() tree.toggle() end)

-- Surround / motion
require('nvim-surround').setup()
require('flash').setup()
map({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end)

-- Terminal panel: one bottom split per tabpage; every panel cycles through the same shell buffers.
local term = { bufs = {} }

local function term_bufs()
  term.bufs = vim.tbl_filter(vim.api.nvim_buf_is_valid, term.bufs)
  return term.bufs
end

local function panel_win()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.w[w].term_panel then return w end
  end
end

local function show(buf)
  local new = not buf
  buf = buf or vim.api.nvim_create_buf(true, false)
  local w = panel_win()
  if w then
    vim.api.nvim_win_set_buf(w, buf)
    vim.api.nvim_set_current_win(w)
  else
    w = vim.api.nvim_open_win(buf, true, { split = 'below', win = -1, height = 15 })
    vim.w[w].term_panel = true
    vim.wo[w].winfixheight = true
  end
  if new then
    vim.fn.jobstart(vim.o.shell, { term = true })
    table.insert(term.bufs, buf)
  end
  term.cur = buf
  local labels = {}
  for i, b in ipairs(term_bufs()) do
    labels[i] = b == buf and ('[' .. i .. ']') or (' ' .. i .. ' ')
  end
  vim.wo[w].winbar = table.concat(labels)
  vim.cmd.startinsert()
end

local function toggle()
  local w = panel_win()
  if w then return vim.api.nvim_win_hide(w) end
  local bufs = term_bufs()
  show(vim.tbl_contains(bufs, term.cur) and term.cur or bufs[#bufs])
end

local function cycle(step)
  local bufs = term_bufs()
  if #bufs > 0 then
    show(bufs[(vim.fn.index(bufs, vim.api.nvim_get_current_buf()) + step) % #bufs + 1])
  end
end

local function close()
  local buf = vim.api.nvim_get_current_buf()
  local i = vim.fn.index(term_bufs(), buf) + 1
  vim.api.nvim_buf_delete(buf, { force = true })
  local bufs = term_bufs()
  if i > 0 and #bufs > 0 then show(bufs[math.min(i, #bufs)]) end
end

map({ 'n', 't' }, '<A-t>', toggle)
map({ 'n', 't' }, '<A-c>', function() show() end)
map('t', '<A-n>', function() cycle(1) end)
map('t', '<A-p>', function() cycle(-1) end)
map('t', '<A-x>', close)
vim.api.nvim_create_autocmd('BufEnter', { pattern = 'term://*', command = 'startinsert' })

-- Python
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function(args) vim.treesitter.start(args.buf) end,
})

vim.diagnostic.config({ virtual_text = true })

-- The default, 'recommended', buries untyped libraries under reportUnknown* warnings.
-- torch builds most of __all__ in a runtime loop, so reportPrivateImportUsage flags public APIs like torch.tensor.
-- A project's own pyrightconfig.json or [tool.basedpyright] section takes precedence over these.
vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = 'standard',
        diagnosticSeverityOverrides = { reportPrivateImportUsage = 'none' },
      },
    },
  },
})
vim.lsp.enable('basedpyright')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.lsp.completion.enable(true, args.data.client_id, args.buf, { autotrigger = true })
    map('n', 'gd', vim.lsp.buf.definition, { buffer = args.buf })
  end,
})
