-- Parsers beyond what the enabled LazyVim extras pull in: CSS/SCSS for
-- Tailwind work, LaTeX for math in render-markdown and Snacks.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "css", "scss", "latex", "html", "regex" } },
  },
}
