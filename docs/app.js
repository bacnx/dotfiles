// The bindings live in keymaps.toml at the repo root; `dothelp` turns it into
// keymaps.json next to this file (docs/keymaps.py build) before opening the page.
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
    // "L" is the leader only as the first cap: in "L x L" the last one is a key.
    combo.split(" ").forEach((cap, j) => {
      if (cap === "L" && j === 0) box.append(el("kbd", "leader", "Space"));
      else box.append(el("kbd", "", cap));
    });
  });
  return box;
}

const allRows = [];
function render(groups) {
  groups.forEach((group) => {
    const section = el("section");
    section.append(el("h2", "group", group.title));
    const cols = el("div", "cols");
    (group.card || []).forEach((card) => {
      const c = el("article", "card");
      c.id = "s-" + card.id;
      c.append(el("h3", "", card.title));
      if (card.sub) c.append(el("p", "sub", card.sub));
      const rows = el("div", "rows");
      card.rows.forEach(({ keys, desc, mode, note }) => {
        const r = el("div", "row");
        const d = el("div", "desc");
        d.append(document.createTextNode(desc));
        if (mode) mode.split(" ").forEach((m) => d.append(el("span", "mode", m)));
        if (note) d.append(el("small", "", note));
        r.append(keysNode(keys), d);
        const plain = keys.split(" | ").map((k) => k.replace(/^L\b/, "space leader")).join(" ");
        r.dataset.text = [plain, plain.replace(/ /g, ""), desc, note || "", card.title].join(" ").toLowerCase();
        r.dataset.squashed = r.dataset.text.replace(/\s+/g, "");
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
}

fetch("keymaps.json", { cache: "no-store" })
  .then((res) => {
    if (!res.ok) throw new Error(res.status + " " + res.statusText);
    return res.json();
  })
  .then(render)
  .catch((err) => {
    const p = el("p", "empty", "Could not load keymaps.json (" + err.message + "). Open the page with dothelp, which builds it from keymaps.toml.");
    p.style.display = "block";
    main.append(p);
  });

const input = document.getElementById("filter");
const empty = document.getElementById("empty");
function applyFilter() {
  const words = input.value.toLowerCase().trim().split(/\s+/).filter(Boolean);
  let shown = 0;
  allRows.forEach((r) => {
    // Also match with the spaces taken out, so "filepath" finds "file path".
    const ok = words.every((w) => r.dataset.text.includes(w) || r.dataset.squashed.includes(w));
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
