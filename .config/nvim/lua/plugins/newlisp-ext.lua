return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, _)
      vim.filetype.add({
        extension = { lsp = "newlisp" },
      })
    end,
  },
}
