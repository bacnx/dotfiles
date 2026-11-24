#!/bin/sh
# Claude Code status line: model │ context │ session (5h) limit │ weekly (7d) limit.
# Claude Code pipes a JSON object on stdin; see `statusLine` in
# ~/.claude/settings.json. rate_limits is missing until the first API reply
# of a session (and for API-key users), so those parts are then skipped.
#
#   Opus 5.5 │ ctx 11% 112k/1M │ session █░░░░░░░░░ 13% ↻18:00 │ week 51% ↻Wed 02:20

jq -r '
  def color(p): if p >= 80 then "\u001b[31m" elif p >= 50 then "\u001b[33m" else "\u001b[32m" end;
  # Full-height blocks, 10 cells of 10% each.
  def meter(p): ([range(0; 10)] | map(if . < ((p + 5) / 10 | floor) then "█" else "░" end) | join(""));
  def limit(name; l; fmt; bar):
    if l.used_percentage == null then empty else
      (l.used_percentage | floor) as $p
      | "\(name) \(color($p))" + (if bar then meter($p) + " " else "" end) + "\($p)%\u001b[0m"
        + (if l.resets_at then " \u001b[2m↻" + (l.resets_at | localtime | strftime(fmt)) + "\u001b[0m" else "" end)
    end;
  def tokens(n): if n >= 1000000 then "\(n / 100000 | floor / 10)M" | sub("\\.0M"; "M")
                 elif n >= 1000 then "\(n / 1000 | floor)k" else "\(n)" end;
  def context(c):
    if c.used_percentage == null then empty else
      (c.used_percentage | floor) as $p
      | "ctx \(color($p))\($p)%\u001b[0m"
        + (if c.context_window_size then " \u001b[2m\(tokens(c.total_input_tokens // 0))/\(tokens(c.context_window_size))\u001b[0m" else "" end)
    end;
  [ "\u001b[1m\(.model.display_name // .model.id // "?")\u001b[0m",
    context(.context_window // {}),
    limit("session"; .rate_limits.five_hour // {}; "%H:%M"; true),
    limit("week";    .rate_limits.seven_day // {}; "%a %H:%M"; false)
  ] | join(" \u001b[2m│\u001b[0m ")
'
