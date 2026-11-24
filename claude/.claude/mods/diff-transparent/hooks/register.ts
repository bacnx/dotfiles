import type { Register } from 'claude-code'

// The built-in /diff panel is a plugin pane with this id. Its body is painted
// with the theme's composerSidebarBackground; "transparent" paints nothing, so
// the terminal's own (translucent) background shows through.
const DIFF_PANE = 'diff'

export const register: Register = on => {
  on('ui.open', { id: DIFF_PANE }, ($, e, next) => next({ ...e, backgroundColor: 'transparent' }))
}
