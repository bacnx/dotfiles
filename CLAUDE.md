# Dotfiles

## Key bindings and the cheatsheet

`keymaps.toml` is the single source of the `dothelp` cheatsheet (`docs/`).
Whenever you add, change or remove a key binding in any config — nvim
(`vim.keymap.set`, plugin `keymaps`/`keys` tables), tmux `bind`, zsh `bindkey`
or `alias`, sway `bindsym`, lazygit `key:` — update `keymaps.toml` in the same
change, following the format in its header. Then run `dothelp check`, which
validates the file and lists nvim leader maps it lacks.

The pre-commit hook (`.githooks/pre-commit`) blocks a commit that changes
binding lines without staging `keymaps.toml`. Do not bypass it with
`--no-verify` unless the user says the binding should stay off the cheatsheet.
