#!/usr/bin/env bash
# Keep jsDelivr icon URLs in mihomo/Clash configs on one explicit ref, and
# refresh the CDN after pushing new icon bytes.
#
# jsDelivr resolves a ref to a commit and caches the result. Purging a file
# drops the file cache only for URLs that name the ref explicitly
# (`.../dotfiles@main/...`); an unversioned URL resolves through HEAD, keeps
# the stale commit for up to 12 hours and cannot be purged. Measured on
# 2026-11-23: after purge `@main` served the new 126 B icon immediately while
# the unversioned URL kept serving the old 1610 B copy.
#
#   mihomo-icons.sh sync <config.yaml>... [--ref <ref>] [--check]
#   mihomo-icons.sh pin  <config.yaml>... [--ref <ref>] [--check]
#
# sync rewrites every gh/yanjinbin/dotfiles.../mihomo/rules/icons URL to the
# given ref (default: main), then purges each URL. Run it after pushing icons.
# pin rewrites to an immutable commit instead (default: the current commit) and
# skips the purge; the new URL simply misses the cache.
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
icons='gh/yanjinbin/dotfiles(@[^/]+)?/mihomo/rules/icons'
purge_base='https://purge.jsdelivr.net'

usage() {
	echo "usage: ${0##*/} sync <config.yaml>... [--ref <ref>] [--check]" >&2
	echo "       ${0##*/} pin  <config.yaml>... [--ref <ref>] [--check]" >&2
	exit 2
}

cmd=${1:-}
shift || true
[[ $cmd == sync || $cmd == pin ]] || usage

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

if [[ -z $ref ]]; then
	if [[ $cmd == sync ]]; then
		ref=main
	else
		ref=$(git -C "$repo" rev-parse --short=12 HEAD)
	fi
fi

for file in "${configs[@]}"; do
	tmp=$(mktemp)
	sed -E "s#${icons}/#gh/yanjinbin/dotfiles@${ref}/mihomo/rules/icons/#g" "$file" >"$tmp"
	moved=$(diff -u "$file" "$tmp" | grep -c '^+[^+]' || true)
	cat "$tmp" >"$file"
	rm -f "$tmp"
	echo "rewrote $moved icon URL(s) in $file to @${ref}"
done

urls() {
	grep -hoE "https://[^/]*jsdelivr\.net/gh/[^\"'[:space:]]+" "$@" |
		grep -F "/mihomo/rules/icons/" |
		sed -E 's/[?].*$//' |
		awk '!seen[$0]++'
}

if [[ $cmd == sync ]]; then
	fail=0
	while IFS= read -r url; do
		purge=${url/#https:\/\/[^\/]*jsdelivr.net/$purge_base}
		if curl -fsS --max-time 20 "$purge" >/dev/null; then
			echo "purged $purge"
		else
			echo "purge failed $purge" >&2
			fail=1
		fi
	done < <(urls "${configs[@]}")
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
