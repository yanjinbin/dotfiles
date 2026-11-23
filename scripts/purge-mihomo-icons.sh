#!/usr/bin/env bash
# Purge jsDelivr caches for every icon URL a mihomo/Clash config references.
#
# jsDelivr resolves branch refs to HEAD and caches them for 12 hours at the
# edge (s-maxage) and 7 days in the browser (max-age). A freshly pushed icon
# therefore keeps returning 404 or an old copy long after the push. Run this
# after pushing icon changes so the dashboard reload picks them up.
set -euo pipefail

usage() {
	echo "usage: ${0##*/} [--ref <branch>] <config.yaml>..." >&2
	exit 2
}

ref=main
if [[ ${1:-} == --ref ]]; then
	(($# >= 2)) || usage
	ref=$2
	shift 2
fi
(($# > 0)) || usage

urls=$(
	grep -hoE "https://[^/]*jsdelivr\.net/gh/[^\"'[:space:]]+" "$@" |
		grep -F "/mihomo/rules/icons/" |
		sed -E \
			-e 's/[?].*$//' \
			-e 's#^https?://[^/]+/#https://purge.jsdelivr.net/#' \
			-e "s#@latest/#@${ref}/#" \
			-e "s#^(/gh/[^/@]+/[^/@]+)(/)#\1@${ref}\2#" |
		awk '!seen[$0]++'
)

if [[ -z $urls ]]; then
	echo "no jsDelivr icon URLs found in $*" >&2
	exit 1
fi

fail=0
while IFS= read -r url; do
	if curl -fsS --max-time 20 "$url" >/dev/null; then
		echo "ok   $url"
	else
		echo "fail $url" >&2
		fail=1
	fi
done <<<"$urls"

exit "$fail"
