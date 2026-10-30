#!/bin/sh

[ ! -d "$HOME/.local/share/pipewire/" ] && mkdir -p "$HOME/.local/share/pipewire/"
[ -z "$PIPEWIRE_LOG" ] && export PIPEWIRE_LOG="$HOME/.local/share/pipewire/pipewire.log"
[ -e "$PIPEWIRE_LOG" ] && mv "$PIPEWIRE_LOG" "$PIPEWIRE_LOG.old"

[ -z "$WIREPLUMBER_LOG" ] && export WIREPLUMBER_LOG="$HOME/.local/share/pipewire/wireplumber.log"
[ -e "$WIREPLUMBER_LOG" ] && mv "$WIREPLUMBER_LOG" "$WIREPLUMBER_LOG.old"

set -- pipewire pipewire-pulse
for i in "$@"; do
	"$i" &
done

while ! pgrep -f "pipewire" >/dev/null || ! pgrep -f "pipewire-pulse" >/dev/null; do
	sleep 0.5
done

while ! pgrep -f "wireplumber" >/dev/null; do
	wireplumber >"$WIREPLUMBER_LOG" 2>&1 &
	sleep 0.5
done
