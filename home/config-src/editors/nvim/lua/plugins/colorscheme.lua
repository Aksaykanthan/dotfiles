-- Catppuccin Mocha with a transparent background, matching Ghostty/Zellij:
-- Ghostty's translucent, blurred window (and the wallpaper) shows through
-- editor, sidebars, and floating windows alike.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      float = { transparent = true, solid = false },
      term_colors = true,
    },
  },
  {
    "LazyVim/LazyVim",
    -- "catppuccin-mocha", not "catppuccin": Neovim 0.12 ships its own
    -- runtime colors/catppuccin.vim, which shadows the plugin and ignores
    -- transparent_background.
    opts = { colorscheme = "catppuccin-mocha" },
  },
}
