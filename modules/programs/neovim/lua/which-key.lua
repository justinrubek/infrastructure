local setup = function()
    local plugin = require("which-key")

    local opts = {
        mode = "n",
        prefix = "<leader>",
        buffer = nil;
        silent = true,
        noremap = true,
        nowait = true,
    }

    local vopts = {
        mode = "v",
        prefix = "<leader>",
        buffer = nil;
        silent = true,
        noremap = true,
        nowait = true,
    }

    -- Mappings: object keys become labeled option prompts to run the given functions
    local mappings = {
        ["f"] = { require("telescope.builtin").find_files, "find file" },

        b = {
            name = "buffers",
            f = { "<cmd>Telescope buffers<cr>", "find" },
        },
        g = {
            name = "git",
            o = { "<cmd>Telescope git_status<cr>", "find changed files" },
            b = { "<cmd>Telescope git_branches<cr>", "checkout branch" },
            c = { "<cmd>Telescope git_commits<cr>", "checkout commits" },
        },
        l = {
            name = "lsp",
            p = {
                name = "peek",
                d = { "", "TODO" },
            },
        },
    }

    local vmappings = {
    }

    plugin.register(mappings, opts)
    plugin.register(vmappings, vopts)
end

setup()
