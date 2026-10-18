-- markdownlint is for real docs, not scratch text. Claude Code / omp / Codex
-- open the prompt being edited (Ctrl+G) as a .md file in a temp dir, and
-- MD012 & friends then flag ordinary prompt writing as errors.
local function is_temp(path)
  local tmp = vim.uv.os_tmpdir() or "/tmp"
  for _, dir in ipairs({ tmp, vim.fn.resolve(tmp), "/tmp/", "/private/tmp/", "/var/folders/", "/private/var/folders/" }) do
    if path:sub(1, #dir) == dir then
      return true
    end
  end
  return false
end

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          condition = function(ctx)
            return not is_temp(ctx.filename)
          end,
        },
      },
    },
  },
}
