#!/usr/bin/env bash
# Waybar network modules (custom, return-type json).
#
#   network.sh phys   the physical card carrying traffic now. With wifi and LAN
#                     both up, that is the one whose default route has the
#                     lowest metric; the other is ignored.
#   network.sh vpn    every VPN tunnel that is up, with its IP. The tooltip
#                     lists the subnets each one routes, for split tunnels.
#                     Prints nothing (module hidden) when no tunnel is up.
#   network.sh toggle  switch both modules between compact (icon, VPN name)
#                     and showing the IPs, then refresh them (signal 8).
set -u

mode=${1:-phys}
state_dir="${XDG_RUNTIME_DIR:-/tmp}/waybar-network"
mkdir -p "$state_dir"

esc() { jq -Rr @html <<<"$1"; }

# Compact unless the toggle file exists. Lives in $XDG_RUNTIME_DIR, so each
# login starts compact.
show_ip_flag="$state_dir/show-ip"
show_ip() { [[ -e $show_ip_flag ]]; }

emit() { # text tooltip class
    jq -cn --arg t "$1" --arg tt "$2" --arg c "$3" '{text:$t, tooltip:$tt, class:$c}'
}

human_rate() { # bytes/s -> short string
    awk -v b="$1" 'BEGIN {
        split("B KB MB GB", u); i = 1
        while (b >= 1024 && i < 4) { b /= 1024; i++ }
        printf (i == 1 ? "%d %s/s" : "%.1f %s/s"), b, u[i]
    }'
}

# Down/up rate since the previous call, from the kernel counters.
rates() { # ifname -> "down up"
    local ifn=$1 rx tx now f="$state_dir/$1"
    rx=$(<"/sys/class/net/$ifn/statistics/rx_bytes")
    tx=$(<"/sys/class/net/$ifn/statistics/tx_bytes")
    now=$(date +%s)
    local drx=0 dtx=0
    if [[ -r $f ]]; then
        read -r prx ptx pnow <"$f"
        local dt=$((now - pnow))
        if ((dt > 0 && rx >= prx && tx >= ptx)); then
            drx=$(((rx - prx) / dt))
            dtx=$(((tx - ptx) / dt))
        fi
    fi
    echo "$rx $tx $now" >"$f"
    echo "$(human_rate "$drx") $(human_rate "$dtx")"
}

ipv4_of() { # ifname -> "addr/cidr" (first one)
    ip -j -4 addr show dev "$1" 2>/dev/null |
        jq -r '[.[].addr_info[]? | "\(.local)/\(.prefixlen)"][0] // empty'
}

# NetworkManager's connection name for a device, if NM manages it.
conn_name() {
    command -v nmcli >/dev/null || return
    nmcli -t -f DEVICE,CONNECTION dev 2>/dev/null |
        awk -F: -v d="$1" '$1 == d { sub(/^[^:]*:/, ""); print; exit }'
}

phys() {
    # Real cards have a backing device in sysfs; tunnels, bridges, veth don't.
    local cards=() ifn
    for ifn in /sys/class/net/*; do
        [[ -e $ifn/device ]] && cards+=("${ifn##*/}")
    done

    # Lowest-metric default route on a real card = the card in use. VPNs that
    # take the default route (or use policy tables) are skipped by this filter.
    local active
    active=$(ip -j route show default 2>/dev/null | jq -r --args '
        [.[] | select(.dev as $d | $ARGS.positional | index($d))]
        | sort_by(.metric // 0) | .[0].dev // empty' "${cards[@]}")

    if [[ -z $active ]]; then
        # No route: report a card that is at least linked, else offline.
        for ifn in "${cards[@]}"; do
            if [[ $(<"/sys/class/net/$ifn/operstate") == up ]]; then
                emit "󰈀  no IP" "$ifn: link up, no route" linked
                return
            fi
        done
        emit "󰤮  offline" "No network card connected" disconnected
        return
    fi

    local addr ip down up
    addr=$(ipv4_of "$active")
    ip=${addr%/*}
    [[ -z $ip ]] && ip="no IPv4"
    read -r down_n down_u up_n up_u <<<"$(rates "$active")"
    down="$down_n $down_u" up="$up_n $up_u"
    local gw
    gw=$(ip -j route show default dev "$active" | jq -r '.[0].gateway // "-"')

    if [[ -d /sys/class/net/$active/wireless ]]; then
        local link ssid dbm pct icon
        link=$(iw dev "$active" link 2>/dev/null)
        ssid=$(sed -n 's/^\s*SSID: //p' <<<"$link")
        dbm=$(sed -n 's/^\s*signal: \(-\?[0-9]*\).*/\1/p' <<<"$link")
        pct=$(( dbm ? 2 * (dbm + 100) : 0 ))
        ((pct > 100)) && pct=100
        ((pct < 0)) && pct=0
        local icons=(󰤟 󰤢 󰤥 󰤨)
        icon=${icons[$((pct >= 100 ? 3 : pct / 25))]}
        local text=$icon
        show_ip && text="$icon  $(esc "$ip")"
        emit "$text" \
            "$(esc "$ssid") ($pct%)  ·  $active
IP       $addr
Gateway  $gw
󰇚 $down   󰕒 $up" wifi
    else
        local speed
        speed=$(cat "/sys/class/net/$active/speed" 2>/dev/null)
        [[ -n $speed && $speed -gt 0 ]] && speed="$speed Mb/s" || speed="?"
        local text=󰈀
        show_ip && text="󰈀  $ip"
        emit "$text" \
            "$(esc "$(conn_name "$active")")  ·  $active ($speed)
IP       $addr
Gateway  $gw
󰇚 $down   󰕒 $up" ethernet
    fi
}

vpn() {
    # Tunnel links that are not down and hold an IPv4 address.
    local tunnels
    mapfile -t tunnels < <(ip -j -d link show 2>/dev/null | jq -r '
        .[] | select(.operstate != "DOWN")
        | select((.linkinfo.info_kind // "") as $k
                 | (["wireguard", "tun", "xfrm", "vti", "ipip", "gre", "ip6tnl"] | index($k))
                   or .link_type == "ppp" or .link_type == "none")
        | .ifname')

    local parts=() tips=() ifn addr name routes
    for ifn in "${tunnels[@]}"; do
        addr=$(ipv4_of "$ifn")
        [[ -z $addr ]] && continue
        name=$(conn_name "$ifn")
        # NM names a tun device's own connection after the device; a device
        # named "tun-<vpn>" (OpenVPN dev=tun-<vpn>) is shown as "<vpn>".
        [[ -z $name || $name == "$ifn" ]] && name=${ifn#tun-}
        if show_ip; then
            parts+=("$(esc "$name") ${addr%/*}")
        else
            parts+=("$(esc "$name")")
        fi
        routes=$(ip -4 route show dev "$ifn" 2>/dev/null |
            awk '$1 != "default" && $0 !~ /proto kernel/ { print "  " $1 }' | head -n 12)
        ip -4 route show default dev "$ifn" 2>/dev/null | grep -q . && routes="  default (full tunnel)
$routes"
        tips+=("󰖂 $(esc "$name")  ·  $ifn
IP  $addr
Routes:
${routes:-  (none in main table)}")
    done

    if ((${#parts[@]} == 0)); then
        echo '{"text":"","class":"none"}'
        return
    fi
    local text tip
    text="󰖂  $(printf '%s  ' "${parts[@]}")"
    tip=$(printf '%s\n\n' "${tips[@]}")
    emit "${text%  }" "${tip%$'\n\n'}" connected
}

case $mode in
    phys) phys ;;
    vpn) vpn ;;
    toggle)
        if show_ip; then rm -f "$show_ip_flag"; else : >"$show_ip_flag"; fi
        pkill -RTMIN+8 -x waybar
        ;;
    *) echo "usage: $0 phys|vpn|toggle" >&2; exit 2 ;;
esac
