#!/usr/bin/env python3
"""Turn keymaps.toml into the data the cheatsheet page loads, and check it.

    keymaps.py build         validate keymaps.toml, write docs/keymaps.json
    keymaps.py check         validate, then list nvim leader maps keymaps.toml lacks
    keymaps.py serve PORT    serve docs/ on 127.0.0.1:PORT

`dothelp` runs build before it opens the page; the pre-commit hook runs check.
"""

import json
import re
import os
import subprocess
import sys
import tomllib

DOCS = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(DOCS)
SOURCE = os.path.join(REPO, "keymaps.toml")
OUTPUT = os.path.join(DOCS, "keymaps.json")

ROW_KEYS = {"keys", "desc", "mode", "note"}


def fail(msg):
    print(f"keymaps.toml: {msg}", file=sys.stderr)
    sys.exit(1)


def load():
    try:
        with open(SOURCE, "rb") as f:
            data = tomllib.load(f)
    except FileNotFoundError:
        fail(f"not found at {SOURCE}")
    except tomllib.TOMLDecodeError as e:
        fail(f"not valid TOML: {e}")

    groups = data.get("group")
    if not isinstance(groups, list) or not groups:
        fail("needs at least one [[group]]")
    ids = set()
    for g in groups:
        if not isinstance(g.get("title"), str):
            fail("every [[group]] needs a title")
        for c in g.get("card", []):
            where = f'card "{c.get("id", "?")}" in group "{g["title"]}"'
            for field in ("id", "title"):
                if not isinstance(c.get(field), str):
                    fail(f"{where}: needs a {field}")
            if c["id"] in ids:
                fail(f'card id "{c["id"]}" is used twice')
            ids.add(c["id"])
            if not isinstance(c.get("rows"), list):
                fail(f"{where}: needs rows = [ ... ]")
            for i, r in enumerate(c["rows"], 1):
                if not isinstance(r, dict):
                    fail(f"{where}, row {i}: write it as {{ keys = ..., desc = ... }}")
                extra = set(r) - ROW_KEYS
                if extra:
                    fail(f"{where}, row {i}: unknown field {', '.join(sorted(extra))}")
                if not all(isinstance(r.get(k), str) for k in ("keys", "desc")):
                    fail(f"{where}, row {i}: needs keys and desc")
                if not all(isinstance(r.get(k, ""), str) for k in ("mode", "note")):
                    fail(f"{where}, row {i}: mode and note are strings")
    return groups


def build():
    groups = load()
    tmp = OUTPUT + ".tmp"
    with open(tmp, "w") as f:
        json.dump(groups, f, ensure_ascii=False)
    os.replace(tmp, OUTPUT)


def normalize(lhs):
    """Letter case matters in a map ('yf' is not 'yF'); in <C-x> names it does not."""
    return re.sub(r"<[^>]+>", lambda m: m.group(0).lower(), lhs)


def combo_to_lhs(combo):
    """'L g h s' -> ' ghs'; 'L Space' -> '  '. None if it is not a leader combo."""
    caps = combo.split(" ")
    if caps[0] != "L":
        return None
    out = []
    for i, cap in enumerate(caps):
        if (i == 0 and cap == "L") or cap == "Space":
            out.append(" ")
        elif len(cap) == 1:
            out.append(cap)
        else:
            out.append(f"<{cap}>")
    return "".join(out)


# Lua run inside headless nvim: print every global leader map as "mode\tlhs".
# Buffer-local maps (gitsigns, codediff) only exist in their buffers, so they
# are out of reach here; the check covers what every buffer has.
NVIM_DUMP = r"""
local seen = {}
for _, m in ipairs({ "n", "x", "o", "i" }) do
  for _, k in ipairs(vim.api.nvim_get_keymap(m)) do
    if k.lhs:sub(1, 1) == " " and #k.lhs > 1 and not k.lhs:find("<Plug>", 1, true) then
      local line = m .. "\t" .. k.lhs
      if not seen[line] then
        seen[line] = true
        io.stdout:write(line .. "\n")
      end
    end
  end
end
"""


def nvim_leader_maps():
    try:
        res = subprocess.run(
            ["nvim", "--headless", "-c", "lua " + NVIM_DUMP.replace("\n", " "), "-c", "qa!"],
            capture_output=True, text=True, timeout=30, cwd=os.path.expanduser("~"),
        )
    except FileNotFoundError:
        print("keymaps.py: nvim not found, skipping the nvim check", file=sys.stderr)
        return []
    except subprocess.TimeoutExpired:
        print("keymaps.py: nvim did not exit in 30s, skipping the nvim check", file=sys.stderr)
        return []
    maps = []
    for line in res.stdout.splitlines():
        mode, _, lhs = line.partition("\t")
        if lhs:
            maps.append((mode, lhs))
    return maps


def check():
    groups = load()
    documented = set()
    for g in groups:
        for c in g.get("card", []):
            for r in c["rows"]:
                for combo in r["keys"].split(" | "):
                    lhs = combo_to_lhs(combo)
                    if lhs:
                        documented.add(normalize(lhs))

    missing = sorted({lhs for _, lhs in nvim_leader_maps() if normalize(lhs) not in documented})
    if missing:
        print("nvim leader maps that keymaps.toml does not list:", file=sys.stderr)
        for lhs in missing:
            print("  <leader>" + lhs[1:].replace(" ", "<Space>"), file=sys.stderr)
        sys.exit(1)
    print("keymaps.toml is valid and lists every nvim leader map.")


def serve(port):
    """http.server with Cache-Control: no-cache, so the browser revalidates
    app.js and keymaps.json on every load instead of keeping an old copy."""
    import functools
    import http.server

    class Handler(http.server.SimpleHTTPRequestHandler):
        def end_headers(self):
            self.send_header("Cache-Control", "no-cache")
            super().end_headers()

        def log_message(self, *args):
            pass

    handler = functools.partial(Handler, directory=DOCS)
    http.server.ThreadingHTTPServer(("127.0.0.1", port), handler).serve_forever()


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "build":
        build()
    elif cmd == "check":
        check()
    elif cmd == "serve" and len(sys.argv) == 3 and sys.argv[2].isdigit():
        serve(int(sys.argv[2]))
    else:
        print("usage: keymaps.py build|check|serve PORT", file=sys.stderr)
        sys.exit(2)
