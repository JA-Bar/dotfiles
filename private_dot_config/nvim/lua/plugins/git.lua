return {
  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      watch_gitdir = {
        interval = 2000,
      },
      trouble = true,
      update_debounce = 1000,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']h', function()
          if vim.wo.diff then return ']h' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = "Goto next git hunk" })

        map('n', '[h', function()
          if vim.wo.diff then return '[h' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = "Goto prev git hunk" })

        -- Actions
        map({ 'n', 'v' }, '<leader>ghs', gs.stage_hunk, { desc = "Git hunk stage" })
        map({ 'n', 'v' }, '<leader>ghx', gs.reset_hunk, { desc = "Git hunk reset" })
        map('n', '<leader>ghu', gs.undo_stage_hunk, { desc = "Git hunk undo stage" })
        map('n', '<leader>ghX', gs.reset_buffer, { desc = "Git hunk reset (buffer)" })
        map('n', '<leader>ghp', gs.preview_hunk, { desc = "Git hunk preview" })
        map('n', '<leader>ghh', function()
          gs.toggle_numhl()
          gs.toggle_word_diff()
          gs.toggle_deleted()
        end, { desc = "Git highlight toggle" })
        map('n', '<leader>ghq', function()
          gs.setqflist("attached")
          vim.cmd("copen")
        end, { desc = "Git hunk to quickfix" })
        map('n', '<leader>gbl', function() gs.blame_line { full = true } end, { desc = "Git blame line" })
        map('n', '<leader>gbb', gs.toggle_current_line_blame, { desc = "Git blame line (toggle)" })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end,
    },
  },

  {
    "tpope/vim-fugitive",
    init = function()
      vim.keymap.set("n", "<Leader>gg", "<cmd>Git<CR>", { desc = "Git status" })
      vim.keymap.set("n", "<Leader>gp", "<cmd>Git pull<CR>", { desc = "Git pull" })
      vim.keymap.set("n", "<Leader>gP", function() vim.fn.feedkeys(":Git push ") end, { desc = "Git push" })

      -- override fugitive's buffer local keymaps
      vim.cmd("autocmd User FugitiveIndex nmap <buffer> <Tab> =")
      vim.cmd("autocmd User FugitiveIndex nmap <buffer> q <cmd>q<CR>")
    end
  },
  { "tpope/vim-rhubarb" },
  {
    "rbong/vim-flog",
    cmd = { "Flog" },
    init = function()
      vim.keymap.set("n", "<Leader>gl", "<cmd>Flog -all<CR>", { desc = "Git log" })
    end,
  },
  -- Neogit (fugitive alternative)
  -- {
  --   "TimUntersberger/neogit",
  --   cmd = "Neogit",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {
  --     kind = "split",
  --     disable_context_highlighting = true,
  --     disable_commit_confirmation = false,
  --     disable_insert_on_commit = false,
  --     disable_hint = true,
  --     integrations = {
  --       diffview = true,
  --     },
  --     sections = {
  --       stashes = {
  --         folded = true
  --       },
  --       recent = {
  --         folded = true,
  --       },
  --     }
  --   }
  -- },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>dvo", function() require("plugin_utils").toggle_diff_view("diff") end, mode = { "n", "v" }, desc = "Diffview open" },
      { "<leader>dvf", function() require("plugin_utils").toggle_diff_view("file") end, mode = { "n", "v" }, desc = "Diffview file history" },
    },
    config = function()
      local actions = require("diffview.actions")
      require("diffview").setup({
        view = {
          default = {
            winbar_info = true,
          },
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = true,
          },
          file_history = {
            winbar_info = true,
          },
        },
        diff_binaries = false,
        enhanced_diff_hl = true,
        use_icons = true,
        file_panel = {
          win_config = {
            position = "bottom",
            width = 35,
            height = 10,
          }
        },
        file_history_panel = {
          git = {
            log_options = {
              single_file = {
                follow = true,
                all = false,
              },
              multi_file = {
                all = false,
              },
            },
          },
        },
        key_bindings = {
          view = {
            { "n", "<tab>", actions.select_next_entry, { desc = "Next entry" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Prev entry" } },
            { "n", "<leader>nf", actions.focus_files, { desc = "Focus files" } },
            { "n", "<leader>nn", actions.toggle_files, { desc = "Toggle files" } },
            { "n", "[x", actions.prev_conflict, { desc = "Prev conflict" } },
            { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },
            { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose ours" } },
            { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose theirs" } },
            { "n", "<leader>cb", actions.conflict_choose("all"), { desc = "Choose both" } }, -- choose both
            { "n", "<leader>cB", actions.conflict_choose("base"), { desc = "Choose the base" } },
            { "n", "<leader>cx", actions.conflict_choose("none"), { desc = "Choose none" } },
          },
          file_panel = {
            { "n", "j", actions.next_entry, { desc = "Next entry" }},
            { "n", "<down>", actions.next_entry, { desc = "Next entry" }},
            { "n", "k", actions.prev_entry, { desc = "Prev entry" }},
            { "n", "<up>", actions.prev_entry, { desc = "Prev entry" }},
            { "n", "<cr>", actions.select_entry, { desc = "Select entry" }},
            { "n", "o", actions.select_entry, { desc = "Select entry" }},
            { "n", "R", actions.refresh_files, { desc = "Refresh files" }},
            { "n", "<tab>", actions.select_next_entry, { desc = "Select next entry" }},
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Select prev entry" }},
            { "n", "<leader>nf", actions.focus_files, { desc = "Focus files" }},
            { "n", "<leader>nn", actions.toggle_files, { desc = "Toggle files" }},
          },
        },
        default_args = {
          DiffviewOpen = { "--untracked-files=no" },
          -- DiffviewFileHistory = { "--base=LOCAL" }
        },
        -- TODO: use hooks to add buffers opened during diffview, close them on diffclose
        hooks = {
          diff_buf_read = function(_)
            require("indent_blankline.commands").disable()
          end
        },
      })
    end
  },
}
