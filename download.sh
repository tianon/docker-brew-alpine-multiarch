#!/usr/bin/env bash
set -Eeuo pipefail

# usage: ./download.sh version
#    ie: ./download.sh 3.6

version="$1"; shift

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

for arch in \
	aarch64 \
	armhf \
	ppc64le \
	s390x \
	x86 \
	x86_64 \
; do
	mkdir -p "$version/$arch"
	if wget -qO "$version/$arch/latest-releases.yaml" "http://dl-cdn.alpinelinux.org/alpine/v${version}/releases/$arch/latest-releases.yaml"; then
		minirootfs="$(grep -E --only-matching "alpine-minirootfs-$version([.][^-]+)?-$arch.tar.gz" "$version/$arch/latest-releases.yaml" | head -1)"
		if [ -n "$minirootfs" ]; then
			if wget -qO "$version/$arch/$minirootfs" "http://dl-cdn.alpinelinux.org/alpine/v${version}/releases/$arch/$minirootfs"; then
				cat > "$version/$arch/Dockerfile" <<-EODF
					FROM scratch
					ADD $minirootfs /

					# ensure UTC instead of the default GMT
					RUN [ ! -e /etc/localtime ] && apk add --no-cache --virtual .tz-utc tzdata && cp -vL /usr/share/zoneinfo/UTC /etc/localtime && apk del .tz-utc

					CMD ["sh"]
				EODF
				continue
			fi
		fi
	fi
	rm -rf "$version/$arch"
done
