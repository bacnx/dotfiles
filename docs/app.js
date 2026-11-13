// Row: [keys, description, mode?, note?]
// keys: caps separated by spaces, alternatives separated by " | ". "L" = leader.
const GROUPS = [
  { title: "Neovim", cards: [
    { id: "basics", title: "Basics", rows: [
      ["L w", "Save file"],
      ["L q", "Quit window"],
      ["Esc", "Clear search highlight"],
      ["C-d | C-u", "Half page down / up, cursor stays centered"],
      ["Down | Up", "Move by screen line", "n v", "With a count (5 Down) it moves real lines"],
      ["g <", "Show the last messages again", "", "Messages pop up bottom-right and fade"],
      ["y | p", "Yank and paste use the system clipboard", "n v", "Through bin/clip"],
    ]},
    { id: "edit", title: "Editing", rows: [
      ["A-Down | A-Up", "Move line down / up", "n v"],
      ["J | K", "Move selection down / up", "v"],
      ["g q", "Format a motion with conform", "n v"],
      ["( [ { \" '", "Closing pair is typed for you", "i", "autoclose.nvim"],
    ]},
    { id: "buffers", title: "Buffers", rows: [
      ["Tab | S-Tab", "Next / previous buffer"],
      ["L Space", "Jump back to the last buffer"],
      ["L c", "Close buffer"],
      ["L C", "Close all buffers"],
    ]},
    { id: "windows", title: "Windows and panes", sub: "The same keys cross between nvim splits and tmux panes.", rows: [
      ["C-Left | C-Down | C-Up | C-Right", "Go to the split or tmux pane in that direction"],
      ["C-h | C-j | C-k | C-l", "Same, on the home row"],
      ["C-S-Left | C-S-Right", "Make window narrower / wider"],
      ["C-S-Up | C-S-Down", "Make window taller / shorter"],
      ["g t | g T", "Next / previous tab", "", "The tabline is hidden"],
    ]},
    { id: "find", title: "Find (Telescope)", rows: [
      ["L f f", "Find files"],
      ["L f g", "Live grep"],
      ["L f w", "Grep the word under the cursor"],
      ["L f b", "Open buffers"],
      ["L f o", "Recent files in this folder"],
      ["L f r", "Reopen the last picker", "", "Keeps the query and the selection"],
      ["L f /", "Fuzzy search in this buffer"],
      ["L f S", "Symbols in this file"],
      ["L f k", "Search all keymaps"],
      ["L f s", "File browser, at the current file"],
      ["L f a", "Find files, also git-ignored ones"],
      ["L f G", "Live grep, also git-ignored files"],
      ["L g s", "Git status picker"],
      ["L d", "Diagnostics picker"],
    ]},
    { id: "picker", title: "Inside a picker", rows: [
      ["C-j | C-k", "Next / previous result", "i"],
      ["Esc", "Close", "i"],
      ["' word", "Exact match"],
      ["^ word", "Starts with"],
      ["word $", "Ends with"],
      ["! word", "Exclude"],
    ]},
    { id: "lsp", title: "LSP", sub: "Servers: lua_ls, ts_ls, gopls, sqls, eslint.", rows: [
      ["K", "Hover documentation"],
      ["g d", "Go to definition"],
      ["g D", "Go to declaration"],
      ["g i", "Go to implementation"],
      ["g r", "References", "", "Many results open in the quickfix list"],
      ["C-t", "Jump back from gd / gi / gr"],
      ["C-o | C-i", "Older / newer jump position", "", "built-in"],
      ["A-s", "Signature help", "i"],
      ["g r n", "Rename symbol", "", "built-in"],
      ["g r a", "Code action", "n v", "built-in"],
      ["L c e", "ESLint: fix all", "", "Only where eslint is attached"],
    ]},
    { id: "complete", title: "Completion", sub: "The menu opens by itself while you type.", rows: [
      ["C-n | C-p", "Next / previous item", "i", "built-in"],
      ["C-y", "Accept the selected item", "i", "built-in"],
      ["C-e", "Close the menu", "i", "built-in"],
      ["Tab", "Pick a match on the command line", "c"],
      ["Up | Down", "Walk command history", "c", "Closes the menu first"],
    ]},
    { id: "diag", title: "Diagnostics", rows: [
      ["] d | [ d", "Next / previous diagnostic"],
      ["L e", "Show the diagnostic on this line"],
      ["L d", "All diagnostics in Telescope"],
      ["L D", "Put diagnostics in the location list"],
      ["L x x", "Trouble: all diagnostics"],
      ["L x X", "Trouble: this buffer only"],
      ["L x s", "Trouble: symbols"],
      ["L x l", "Trouble: LSP references, on the right"],
      ["L x L", "Trouble: location list"],
      ["L x Q", "Trouble: quickfix list"],
      ["Down | Up", "Next / previous item inside Trouble"],
    ]},
    { id: "hunks", title: "Git hunks (gitsigns)", sub: "A hunk is one block of changed lines.", rows: [
      ["] h | [ h", "Next / previous hunk"],
      ["] H | [ H", "Last / first hunk"],
      ["L g h s", "Stage hunk", "n v"],
      ["L g h r", "Reset hunk", "n v"],
      ["L g h u", "Undo the last staged hunk"],
      ["L g h S", "Stage the whole buffer"],
      ["L g h R", "Reset the whole buffer"],
      ["L g h p", "Preview hunk in a popup"],
      ["L g h i", "Preview hunk inline"],
      ["L g h b", "Blame this line, full commit"],
      ["L g h B", "Blame the whole buffer"],
      ["L g h d", "Diff this file"],
      ["i h", "The hunk as a text object", "o x", "For example v i h or d i h"],
    ]},
    { id: "diff", title: "Git diff (codediff)", rows: [
      ["L g d", "Diff the working tree"],
      ["L g D", "Diff this branch against main"],
      ["L g t", "Diff this file against HEAD, or close the diff"],
      ["L g f", "History of this file"],
      ["L g f", "History of the selected lines", "x"],
      ["L g H", "History of the repo"],
      ["L g h s", "In a diff: stage hunk"],
      ["L g h u", "In a diff: unstage hunk"],
      ["L g h r", "In a diff: discard hunk"],
      ["L g e", "In a diff: focus the file explorer"],
      ["t", "In a diff: switch side-by-side / inline"],
      ["Down | Up", "Explorer: open the next / previous file"],
      ["S-Down | S-Up", "Explorer: scroll the diff 3 lines"],
      ["C-d | C-u", "Explorer: scroll the diff half a page"],
      ["PageDown | PageUp", "Explorer: scroll the diff one page"],
    ]},
    { id: "lazygit", title: "Lazygit", rows: [
      ["L g g", "Open lazygit in a float"],
      ["e", "In lazygit: open the file in this nvim", "", "No nested nvim"],
      ["c", "In lazygit files: commit with commitizen", "", "Runs git cz"],
    ]},
    { id: "format", title: "Format (conform)", sub: "Files are formatted on save.", rows: [
      ["L c f", "Format the buffer or the selection", "n v"],
      ["L u f", "Turn format on save on / off"],
      ["L u F", "Same, for this buffer only"],
      ["L c i", "Show which formatters are active"],
      ["lua", "stylua"],
      ["go", "goimports, then gofmt"],
      ["python", "ruff, else black"],
      ["js ts json", "biome, else prettier", "", "Only when the repo has their config file"],
      ["css html md yaml", "prettier"],
      ["sh | toml", "shfmt | taplo"],
    ]},
    { id: "test", title: "Test and run", sub: "Output goes to a tmux pane (vimux).", rows: [
      ["L t t", "Run the nearest test"],
      ["L t f", "Run the tests in this file", "", "Go: only the tests declared in the file"],
      ["L t a", "Run the whole suite"],
      ["L t l", "Run the last test again"],
      ["L t g", "Go to the last test file"],
      ["L r", "Run this file", "", "TypeScript, Go, Zig"],
    ]},
    { id: "start", title: "Start page and sessions", rows: [
      ["f", "Start page: find file"],
      ["g", "Start page: grep"],
      ["e", "Start page: file browser"],
      ["r", "Start page: restore the last buffers"],
      ["1 … 9 | 0", "Start page: open that recent file"],
      ["Enter", "Start page: open the file under the cursor"],
      ["q", "Start page: close"],
      ["L s s", "Save session"],
      ["L s r", "Restore session"],
    ]},
    { id: "toggles", title: "Toggles", sub: "Everything under Space u switches a view on or off.", rows: [
      ["L u m", "Markdown rendering"],
      ["L u b", "Blame at the end of the line"],
      ["L u D", "Show deleted lines"],
      ["L u f", "Format on save"],
      ["L u F", "Format on save, this buffer"],
    ]},
    { id: "commands", title: "Commands", rows: [
      [":Mason", "Install LSP servers and formatters"],
      [":TSInstall", "Install a treesitter parser"],
      [":CodeDiff install!", "Reinstall the diff library"],
      [":lua vim.pack.update()", "Update plugins", "", "Versions are pinned in nvim-pack-lock.json"],
    ]},
  ]},
  { title: "Other tools", cards: [
    { id: "tmux", title: "tmux", sub: "Prefix is C-s.", rows: [
      ["C-Left | C-Down | C-Up | C-Right", "Go to the pane or nvim split in that direction", "", "No prefix"],
      ["C-s Left | Down | Up | Right", "Select pane"],
      ["C-s C-Left | C-Right | C-Up | C-Down", "Resize pane by 5", "", "Repeatable"],
      ["C-s s", "Split: new pane below"],
      ["C-s v", "Split: new pane on the right"],
      ["C-s c", "New window, same folder"],
      ["C-s l", "Last window"],
      ["C-s Space", "Session picker"],
      ["C-s w", "Session picker with windows"],
      ["C-s y", "Launch Claude (claude-hatch)"],
      ["C-s r", "Reload the config"],
      ["C-s I", "Install plugins (TPM)"],
      ["y | Enter", "Copy mode: copy to the system clipboard"],
    ]},
    { id: "zsh", title: "zsh", sub: "The command line uses vi keys.", rows: [
      ["j k", "Leave insert mode", "ins"],
      ["v", "Edit the command in nvim", "cmd"],
      ["y | Y | d | c", "Copy / cut to the system clipboard", "cmd"],
      ["p | P", "Paste from the system clipboard", "cmd"],
      ["v", "nvim"],
      ["lg", "lazygit"],
      ["ls | la", "eza with icons, folders first"],
      ["ll | lla", "eza long list with git status"],
      ["z dir", "Jump to a folder (zoxide)"],
      ["cmd | clip", "Copy any command output"],
      ["dothelp", "Open this cheatsheet"],
      ["dothelp stop", "Stop the cheatsheet server"],
    ]},
    { id: "stow", title: "Stow", sub: "Run inside ~/.dotfiles.", rows: [
      ["stow nvim", "Link a package into $HOME"],
      ["stow -n -v nvim", "Dry run"],
      ["stow -R nvim", "Link again after adding or removing files"],
      ["stow -D nvim", "Remove the links"],
    ]},
  ]},
];

const main = document.getElementById("main");
const nav = document.getElementById("nav");
const el = (tag, cls, text) => {
  const n = document.createElement(tag);
  if (cls) n.className = cls;
  if (text != null) n.textContent = text;
  return n;
};

function keysNode(spec) {
  const box = el("div", "keys");
  spec.split(" | ").forEach((combo, i) => {
    if (i) box.append(el("span", "or", "/"));
    // Shell commands and :commands read better as one piece of code.
    if (/^(:|stow|dothelp|cmd \||z dir)/.test(combo) || /^(lua|go|python|js ts json|css html md yaml|sh|toml)$/.test(combo)) {
      box.append(el("code", "", combo));
      return;
    }
    combo.split(" ").forEach((cap) => {
      if (cap === "L") box.append(el("kbd", "leader", "Space"));
      else box.append(el("kbd", "", cap));
    });
  });
  return box;
}

const allRows = [];
GROUPS.forEach((group) => {
  const section = el("section");
  section.append(el("h2", "group", group.title));
  const cols = el("div", "cols");
  group.cards.forEach((card) => {
    const c = el("article", "card");
    c.id = "s-" + card.id;
    c.append(el("h3", "", card.title));
    if (card.sub) c.append(el("p", "sub", card.sub));
    const rows = el("div", "rows");
    card.rows.forEach(([keys, desc, mode, note]) => {
      const r = el("div", "row");
      const d = el("div", "desc");
      d.append(document.createTextNode(desc));
      if (mode) mode.split(" ").forEach((m) => d.append(el("span", "mode", m)));
      if (note) d.append(el("small", "", note));
      r.append(keysNode(keys), d);
      const plain = keys.replace(/\bL\b/g, "space leader").replace(/ \| /g, " ");
      r.dataset.text = [plain, plain.replace(/ /g, ""), desc, note || "", card.title].join(" ").toLowerCase();
      rows.append(r);
      allRows.push(r);
    });
    c.append(rows);
    cols.append(c);

    const a = el("a", "", card.title.replace(/ \(.*\)/, ""));
    a.href = "#s-" + card.id;
    a.addEventListener("click", (e) => {
      e.preventDefault();
      c.scrollIntoView({ block: "start" });
    });
    nav.append(a);
  });
  section.append(cols);
  main.append(section);
});

const input = document.getElementById("filter");
const empty = document.getElementById("empty");
function applyFilter() {
  const words = input.value.toLowerCase().trim().split(/\s+/).filter(Boolean);
  let shown = 0;
  allRows.forEach((r) => {
    const ok = words.every((w) => r.dataset.text.includes(w));
    r.hidden = !ok;
    r.style.display = ok ? "" : "none";
    r.classList.toggle("hit", ok && words.length > 0);
    if (ok) shown++;
  });
  document.querySelectorAll(".card").forEach((c) => {
    c.style.display = c.querySelector(".row:not([hidden])") ? "" : "none";
  });
  document.querySelectorAll("main section").forEach((s) => {
    s.style.display = s.querySelector(".row:not([hidden])") ? "" : "none";
  });
  empty.style.display = shown ? "none" : "block";
}
input.addEventListener("input", applyFilter);
document.addEventListener("keydown", (e) => {
  if (e.key === "/" && document.activeElement !== input) {
    e.preventDefault();
    input.focus();
    input.select();
  } else if (e.key === "Escape" && document.activeElement === input) {
    input.value = "";
    applyFilter();
    input.blur();
  }
});

// Catppuccin flavour switcher. The choice is kept in localStorage; with no
// saved choice the page follows the system: Latte in light, Mocha in dark.
const FLAVORS = ["latte", "frappe", "macchiato", "mocha"];
const flavorButtons = document.querySelectorAll(".flavors button");
const systemDark = window.matchMedia("(prefers-color-scheme: dark)");
function currentFlavor() {
  const set = document.documentElement.dataset.flavor;
  return FLAVORS.includes(set) ? set : systemDark.matches ? "mocha" : "latte";
}
function markFlavor() {
  const now = currentFlavor();
  flavorButtons.forEach((b) => b.setAttribute("aria-pressed", String(b.dataset.flavor === now)));
}
flavorButtons.forEach((b) => {
  b.addEventListener("click", () => {
    document.documentElement.dataset.flavor = b.dataset.flavor;
    try { localStorage.setItem("flavor", b.dataset.flavor); } catch (e) {}
    markFlavor();
  });
});
systemDark.addEventListener("change", markFlavor);
markFlavor();
