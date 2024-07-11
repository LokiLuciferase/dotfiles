-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "
local mopts = { noremap = true, silent = true }
local is_large_file = function()
    return vim.fn.getfsize(vim.fn.expand("%")) > 512 * 1024
end

-- define plugin spec
local plugin_spec = {
    {
        -- Onedark color scheme
        "navarasu/onedark.nvim",
        lazy = false,
        config = function()
            require("onedark").setup({
                colors = {
                    bg0 = "#232323"
                },
                highlights = {
                    Title = { fg = "$green" },
                    TabLine = { fg = "$grey" },
                    TabLineSel = { bg = "$bg3", fg = "$fg" },
                    CocInlayHint = { fg = "#56b6c2" }
                }
            })
            vim.cmd("colorscheme onedark")
        end,
        priority = 1000
    },
    {
        -- Syntax highlighting for NF
        "LokiLuciferase/nextflow-vim",
        lazy = true,
        init = function()
            vim.api.nvim_create_autocmd(
                { "BufNewFile", "BufRead" },
                { pattern = { "*.nf", "*.config" }, command = "set filetype=nextflow" }
            )
        end,
        ft = { "nextflow" },
    },
    {
        -- replace with register
        "vim-scripts/ReplaceWithRegister",
    },
    {
        -- Indent guides
        "lukas-reineke/indent-blankline.nvim",
        version = "2.x"

    },
    {
        "ntpeters/vim-better-whitespace",
        init = function()
            vim.g.current_line_whitespace_disabled_hard = true
            vim.api.nvim_set_keymap("n", "<leader>xdw", ":StripWhitespace<CR>", mopts)
        end
    },
    {
        -- Line and block commenting
        'numToStr/Comment.nvim',
        lazy = true,
        config = function()
            require('Comment').setup({
                toggler = {
                    line = "<leader>cl",
                    block = "<leader>cb",
                },
                opleader = {
                    line = "<leader>cl",
                    block = "<leader>cb",
                }
            })
        end,
        keys = {
            { "<leader>cl" },
            { "<leader>cb" },
            { "<leader>cl", mode = "v" },
            { "<leader>cb", mode = "v" },
        }
    },
    {
        -- Surrounding handling
        "tpope/vim-surround"
    },
    {
        -- More powerful substitution
        "tpope/vim-abolish",
    },
    {
        -- easymotion
        "easymotion/vim-easymotion",
    },
    {
        -- Git integration
        "tpope/vim-fugitive",
        lazy = true,
        init = function()
            vim.api.nvim_set_keymap("n", "<leader>gd", ":Gdiffsplit<CR>", mopts)
            vim.api.nvim_set_keymap("n", "<leader>gs", ":Git<CR>", mopts)
            vim.api.nvim_set_keymap("n", "<leader>gc", ":Git commit<CR>", mopts)
            vim.api.nvim_set_keymap("n", "<leader>gca", ":Git commit --amend<CR>", mopts)
            vim.api.nvim_set_keymap("n", "<leader>gps", ":Git push<CR>", mopts)
            vim.api.nvim_set_keymap("n", "<leader>gpl", ":Git pull<CR>", mopts)
            vim.api.nvim_set_keymap("n", "<leader>ga", ":Git add %<CR>", mopts)
            vim.api.nvim_set_keymap("n", "<leader>gA", ":Git add .<CR>", mopts)
            vim.api.nvim_set_keymap("n", "<leader>gb", ":Git blame<CR>", mopts)
            vim.api.nvim_set_keymap("n", "<leader>gr", ":Git restore %<CR>", mopts)
        end,
        cmd = { "Git", "Gdiffsplit" }
    },
    {
        -- Git diff signs in signcolumn
        "mhinz/vim-signify",
    },
    {
        -- TSV/CSV highlighting
        "mechatroner/rainbow_csv",
        lazy = true,
        init = function()
            vim.g.rbql_with_headers = true
            vim.g.rb_storage_dir = vim.fn.stdpath("cache") .. "/rbql"
            vim.g.table_names_settings = vim.fn.stdpath("cache") .. "/rbql/table_names"
            vim.g.rainbow_table_index = vim.fn.stdpath("cache") .. "/rbql/table_index"
            vim.api.nvim_set_keymap("n", "<leader>rq", ":RainbowQuery<CR>", mopts)
        end,
        ft = { "csv", "tsv" },
    },
    {
        -- Relational database support
        "kristijanhusak/vim-dadbod-ui",
        lazy = true,
        dependencies = {
            { "tpope/vim-dadbod", lazy = true },
        },
        init = function()
            vim.g.db_ui_auto_execute_table_helpers = true
            vim.api.nvim_set_keymap("n", "<F4>", ":DBUIToggle<CR>", mopts)
            vim.api.nvim_create_autocmd({ "FileType" },
                { pattern = "dbout", command = "wincmd T | setlocal nofoldenable" })
        end,
        cmd = { "DB", "DBUI", "DBUIToggle" },
        ft = { "sql" },
    },
    {
        -- fzf and rg bindings
        "junegunn/fzf.vim",
        lazy = true,
        dependencies = {
            { "junegunn/fzf", lazy = true }
        },
        init = function()
            vim.api.nvim_set_keymap("n", "<leader>ff", ":Files!<CR>", { noremap = true, desc = "Find files" })
            vim.api.nvim_set_keymap("n", "<leader>fc", ":Commits!<CR>", { noremap = true, desc = "Find commits" })
            vim.api.nvim_set_keymap("n", "<leader>fr", ":Rg!<CR>", { noremap = true, desc = "Find file contents" })
            vim.api.nvim_set_keymap("n", "<leader>gl", ":Commits!<CR>", { noremap = true, desc = "Git log" })
            vim.api.nvim_set_keymap("n", "<leader>rg", ":Rg!<CR>", { noremap = true, desc = "Ripgrep" })
            vim.cmd("let g:fzf_colors ={'hl+': ['fg', 'Statement'], 'hl': ['fg', 'Statement']}")
        end,
        cmd = { "Files", "Buffers", "History", "BLines", "Rg", "Lines", "BCommits", "Commits", "Tags" },
    },
    {
        -- File explorer
        "nvim-tree/nvim-tree.lua",
        lazy = true,
        init = function()
            vim.api.nvim_set_keymap("n", "<F3>", ":NvimTreeToggle<CR>", mopts)
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
        end,
        config = function()
            require("nvim-tree").setup()
        end,
        cmd = { "NvimTreeToggle" },
    },
    {
        -- LaTeX support
        "lervag/vimtex",
        lazy = true,
        init = function()
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_quickfix_mode = 2
            vim.g.vimtex_quickfix_autoclose_after_keystrokes = true
            vim.g.vimtex_quickfix_open_on_warning = 0
            vim.g.vimtex_compiler_latexmk = { build_dir = "build", out_dir = "build" }
        end,
        ft = { "tex" },
    },
    {
        "voldikss/vim-floaterm",
        lazy = true,
        init = function()
            vim.api.nvim_set_keymap(
                "n", "<leader>tt", ":FloatermToggle<CR>", { noremap = true, desc = "Open terminal" }
            )
            vim.g.floaterm_autoclose = 2
        end,
        cmd = { "FloatermNew", "FloatermToggle", "FloatermNext", "FloatermPrev" },
    },
    {
        -- Better git diff
        "sindrets/diffview.nvim",
        lazy = true,
        dependencies = {
            { "nvim-lua/plenary.nvim", lazy = true }
        },
        init = function()
            vim.api.nvim_set_keymap("n", "<leader>gvo", ":DiffviewOpen<CR>",
                { noremap = true, desc = "Open repo diff" })
            vim.api.nvim_set_keymap("n", "<leader>gvc", ":DiffviewClose<CR>",
                { noremap = true, desc = "Close repo diff" })
            vim.api.nvim_set_keymap("n", "<leader>dv", ":DiffviewOpen<CR>",
                { noremap = true, desc = "Open repo diff" })
            vim.api.nvim_set_keymap("n", "<leader>dc", ":DiffviewClose<CR>",
                { noremap = true, desc = "Close repo diff" })
        end,
        config = function()
            require("diffview").setup({ enhanced_diff_hl = true, use_icons = false })
        end,
        cmd = { "DiffviewOpen", "DiffviewClose" },
    },
    {
        -- Undotree visualizer
        "mbbill/undotree",
        lazy = true,
        init = function()
            vim.api.nvim_set_keymap("n", "<F6>", ":UndotreeToggle<CR>", mopts)
        end,
        cmd = { "UndotreeToggle" },
    },
    {
        "Eandrju/cellular-automaton.nvim",
        lazy = true,
        init = function()
            vim.api.nvim_set_keymap("n", "<leader>xcr", ":CellularAutomaton make_it_rain<CR>",
                { noremap = true, desc = "Make it rain" })
            vim.api.nvim_set_keymap("n", "<leader>xcg", ":CellularAutomaton game_of_life<CR>",
                { noremap = true, desc = "Game of life" })
            vim.api.nvim_set_keymap("n", "<leader>xcs", ":CellularAutomaton scramble<CR>",
                { noremap = true, desc = "Scramble" })
        end,
        cmd = { "CellularAutomaton" },
    },
    {
        "nvim-neotest/neotest",
        lazy = true,
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-neotest/neotest-python", lazy = false }
        },
        cond = function()
            local osrelease = vim.loop.os_uname().release
            return not (string.find(osrelease, "android") ~= nil) and not is_large_file()
        end,
        init = function()
            vim.api.nvim_set_keymap("n", "<leader>nr", ":Neotest run<CR>", { noremap = true, desc = "Run tests" })
            vim.api.nvim_set_keymap("n", "<leader>ns", ":Neotest stop<CR>", { noremap = true, desc = "Stop tests" })
            vim.keymap.set("n", "<leader>nt",
                function()
                    require('neotest').summary.toggle()
                    require('neotest').output_panel.toggle()
                end,
                { noremap = true, desc = "Toggle test summary" }
            )
        end,
        config = function()
            require('neotest').setup({
                adapters = {
                    require('neotest-python')({
                        dap = { justMyCode = false },
                    })
                }
            })
        end,

        cmd = { "Neotest", "NeotestSummary", "NeotestOutput" },
    },
    {
        -- Treesitter integration
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        cond = function() return not is_large_file() end,
        init = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "c", "cpp", "rust", "go",
                    "javascript", "python", "bash",
                    "latex", "toml", "json", "yaml", "sql",
                    "dockerfile",
                    "lua", "vim"
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
    {
        -- Github Copilot integration
        "github/copilot.vim",
        -- tag = "v1.10.3", -- TODO: revisit later or not, v1.11.* slows down entry
        lazy = false,
        cond = function() return vim.fn.executable("node") == 1 and not is_large_file() end,
        init = function()
            local opts = { silent = true, script = true, expr = true, noremap = true }
            for i = 9, 11 do
                vim.api.nvim_set_keymap("i", "<F" .. i .. ">", "copilot#Accept('')", opts)
                vim.api.nvim_set_keymap("i", "<C-F" .. i .. ">", "copilot#Next('')", opts)
            end
            vim.g.copilot_no_tab_map = 1
        end
    },
    {
        -- LSP integration
        "neoclide/coc.nvim",
        lazy = false,
        dependencies = {
            "honza/vim-snippets"
        },
        cond = function() return vim.fn.executable("node") == 1 and not is_large_file() end,
        init = function()
            vim.opt.updatetime = 100
            vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")
            vim.g.coc_data_home = vim.fn.stdpath("data") .. "/coc"
            local keyset = vim.keymap.set
            local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
            function _G.check_back_space()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            keyset("i", "<TAB>",
                'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
            keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
            keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
                opts)
            if vim.fn.executable("npm") then
                vim.g.coc_global_extensions = {
                    'coc-diagnostic',
                    'coc-json',
                    'coc-yaml',
                    'coc-pairs',
                    'coc-pyright',
                    'coc-clangd',
                    'coc-lua',
                    'coc-db',
                    'coc-snippets'
                }
            end

            vim.api.nvim_exec([[
                function! ShowDocumentation()
                  if CocAction('hasProvider', 'hover')
                    call CocActionAsync('doHover')
                  else
                    call feedkeys('K', 'in')
                  endif
                endfunction
            ]], false)

            -- define commonly used shortcuts
            vim.api.nvim_set_keymap("n", "K", ":call ShowDocumentation()<CR>",
                { noremap = true, desc = "Show documentation" })
            vim.api.nvim_set_keymap("n", "<leader>ld", "<Plug>(coc-definition)",
                { noremap = false, desc = "Go to definition" })
            vim.api.nvim_set_keymap("n", "<leader>lr", "<Plug>(coc-rename)", { noremap = false, desc = "Rename symbol" })
            vim.api.nvim_set_keymap("n", "<leader>lf", "<Plug>(coc-format)",
                { noremap = false, desc = "Format document" })
            vim.api.nvim_set_keymap("n", "<leader>lzi", ":call CocAction('fold', 'imports')<CR>",
                { noremap = false, desc = "Fold imports" })
            vim.api.nvim_set_keymap("n", "<leader>lza", ":call CocAction('fold', 'region')<CR>",
                { noremap = false, desc = "Fold all regions" })
            vim.api.nvim_set_keymap("n", "<leader>lzr", "zR", { noremap = false, desc = "Unfold all" })
            vim.api.nvim_set_keymap("n", "<leader>lzA", "zA", { noremap = false, desc = "Unfold region" })
            vim.api.nvim_set_keymap("n", "<leader>lso", ":call CocAction('showOutline')<CR>",
                { noremap = false, desc = "Show outline" })
            vim.api.nvim_set_keymap("n", "<leader>ln", ":call CocAction('diagnosticNext')<CR>",
                { noremap = false, desc = "Go to next diagnostic" })
            vim.api.nvim_set_keymap("n", "<leader>lp", ":call CocAction('diagnosticPrevious')<CR>",
                { noremap = false, desc = "Go to previous diagnostic" })
            vim.api.nvim_set_keymap("n", "<leader>lsi", ":CocCommand python.sortImports<CR>",
                { noremap = false, desc = "Sort imports" })

            -- Snippets
            vim.api.nvim_set_keymap("i", "<C-l>", "<Plug>(coc-snippets-expand-jump)", { noremap = false })

            -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
            vim.api.nvim_create_augroup("CocGroup", {})
            vim.api.nvim_create_autocmd("CursorHold", {
                group = "CocGroup",
                command = "silent call CocActionAsync('highlight')",
                desc = "Highlight symbol under cursor on CursorHold"
            })

            -- Remap <C-f> and <C-b> to scroll float windows/popups
            ---@diagnostic disable-next-line: redefined-local
            local opts = { silent = true, nowait = true, expr = true }
            keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
            keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
            keyset("i", "<C-f>",
                'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
            keyset("i", "<C-b>",
                'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
            keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
            keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
        end,
        branch = "release",
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        config = function()
            local wk = require("which-key")
            wk.register({
                ["<leader>"] = {
                    name = "+tools",
                    c = {
                        name = "+comment",
                        l = { name = "Line comment" },
                        b = { name = "Block comment" },
                    },
                    d = "which_key_ignore",
                    f = { name = "+find", },
                    g = {
                        name = "+git",
                        p = { name = "+pull/push" },
                        v = { name = "+diffview" },
                    },
                    l = {
                        name = "+language",
                        s = { name = "+sort/+show" },
                        z = { name = "+fold" }
                    },
                    n = { name = "+neotest" },
                    r = "which_key_ignore",
                    s = {
                        name = "+session/+spell",
                        s = { name = "Save session" },
                        r = { name = "Restore session" },
                    },
                    t = {
                        name = "+terminal",
                        n = "which_key_ignore",
                        N = "which_key_ignore"
                    },
                    x = {
                        name = "+misc",
                        c = "+CellularAutomaton"
                    },
                    y = "which_key_ignore",
                    ['<space>'] = 'which_key_ignore',
                    ["1"] = "which_key_ignore",
                    ["2"] = "which_key_ignore",
                    ["3"] = "which_key_ignore",
                    ["4"] = "which_key_ignore",
                    ["5"] = "which_key_ignore",
                    ["6"] = "which_key_ignore",
                    ["7"] = "which_key_ignore",
                    ["8"] = "which_key_ignore",
                    ["9"] = "which_key_ignore",
                    ["0"] = "which_key_ignore",
                },
            })
            wk.setup()
        end,
    },
}

-- load plugins
require("lazy").setup(plugin_spec)
