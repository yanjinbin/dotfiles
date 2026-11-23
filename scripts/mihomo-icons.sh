#!/usr/bin/env bash
# Point a mihomo/Clash config at jsDelivr icon URLs, and refresh their caches.
#
# jsDelivr resolves a branch ref to HEAD once and reuses that resolution for up
# to 12 hours. Purging a file does not drop the resolution, so a freshly pushed
# icon keeps returning 404 or stale bytes no matter how often it is purged.
# Pinning the URL to a commit instead makes it immutable: new bytes mean a new
# URL, so the dashboard never serves a stale copy.
#
#   mihomo-icons.sh pin   <config.yaml>... [--ref <tag|commit|branch>] [--check]
#   mihomo-icons.sh purge <config.yaml>...
#
# pin rewrites every gh/yanjinbin/dotfiles.../mihomo/rules/icons URL to the
# given ref (default: the current commit). purge asks jsDelivr to refetch
# those URLs and is only useful for configs still on a branch ref.
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
icons='gh/yanjinbin/dotfiles(@[^/]+)?/mihomo/rules/icons'

usage() {
	echo "usage: ${0##*/} pin   <config.yaml>... [--ref <tag|commit|branch>] [--check]" >&2
	echo "       ${0##*/} purge <config.yaml>..." >&2
	exit 2
}

cmd=${1:-}
shift || true
[[ $cmd == pin || $cmd == purge ]] || usage

ref=""
check=0
configs=()
while (($# > 0)); do
	case $1 in
	--ref)
		(($# >= 2)) || usage
		ref=$2
		shift 2
		;;
	--check)
		check=1
		shift
		;;
	-*)
		usage
		;;
	*)
		configs+=("$1")
		shift
		;;
	esac
done
((${#configs[@]} > 0)) || usage

urls() {
	grep -hoE "https://[^/]*jsdelivr\.net/gh/[^\"'[:space:]]+" "$@" |
		grep -F "/mihomo/rules/icons/" |
		sed -E 's/[?].*$//' |
		awk '!seen[$0]++'
}

if [[ $cmd == pin ]]; then
	if [[ -z $ref ]]; then
		ref=$(git -C "$repo" rev-parse --short=12 HEAD)
	fi
	for file in "${configs[@]}"; do
		tmp=$(mktemp)
		sed -E "s#${icons}/#gh/yanjinbin/dotfiles@${ref}/mihomo/rules/icons/#g" "$file" >"$tmp"
		moved=$(diff -u "$file" "$tmp" | grep -c '^+[^+]' || true)
		cat "$tmp" >"$file"
		rm -f "$tmp"
		echo "pinned $moved icon URL(s) in $file to @${ref}"
	done
fi

if [[ $cmd == purge ]]; then
	fail=0
	while IFS= read -r url; do
		purge=${url/#https:\/\/[^\/]*jsdelivr.net/https:\/\/purge.jsdelivr.net}
		if curl -fsS --max-time 20 "$purge" >/dev/null; then
			echo "ok   $purge"
		else
			echo "fail $purge" >&2
			fail=1
		fi
	done < <(urls "${configs[@]}" | sed -E "s#@latest/#@${ref:-main}/#")
	((fail == 0)) || exit 1
fi

if ((check)); then
	fail=0
	while IFS= read -r url; do
		res=$(curl -s -o /dev/null -w '%{http_code} %{size_download}' --max-time 20 "$url")
		code=${res%% *}
		printf '%s %8s B  %s\n' "$code" "${res#* }" "$url"
		[[ $code == 200 ]] || fail=1
	done < <(urls "${configs[@]}")
	((fail == 0)) || exit 1
fi
