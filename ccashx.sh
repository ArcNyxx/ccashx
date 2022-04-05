#!/bin/sh
# ccashx - ccash command client
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

error() {
	echo "$1" >&2; exit 1
}

upper() {
	echo "$1" | tr '[:lower:]' '[:upper:]'
}

name() {
	[ "${#1}" -lt 3 -o "${#1}" -gt 16 ] && error \
		"ccashx: invalid name length: ${#1}"
	[ -n "$(echo "$1" | tr -d '[:alnum:]_')" ] && error \
		"ccashx: invalid name chars: $1"
}

number() {
	[ -z "$1" -o -n "$(echo "$1" | tr -d '[:digit:]')" ] && error \
		"ccashx: invalid number chars: $1"
}

auth() {
	[ -z "$1" -o "${1%:*}" = "$1" ] && error \
		"ccashx: invalid auth delim: $1"
	name "${1%:*}"
}

[ $# -lt 3 ] && error 'usage: ccashx [command] [args...]'

CMD="$(grep "^$1  " cmd.conf | tr -s ' ')"
[ -z "$CMD" ] && error "ccashx: invalid command: $1"

shift # command was first
while [ -n "$2" ]; do
	GREP="$(grep "  $1  " arg.conf)"
	[ -z "$GREP" ] && error "ccashx: invalid argument: $1"

	eval "${GREP##* } \"\$2\"" # verify restrictions met
	eval "$(upper ${GREP%%\ *})=\"\$2\"" # assign variable
	shift 2
done

[ -z "$SERVER" ] && error 'ccashx: missing required argument: --server'
BODY=''; ENDP="$(echo "$SERVER$(echo "$CMD" | cut '-d ' -f2)" | tr -s '/')"
for ARG in $(echo "${CMD##* }" | tr , ' '); do
	[ -z "$(echo "$ARG" | tr -d '[:upper:]')" ] && break # no arguments

	[ "$ARG" = 'time' -a -z "$TIME" ] && continue # time blank acceptable
	eval "[ -z \"\$$(upper "$ARG")\" ]" && error \
		"ccashx: missing required argument: $(grep "$ARG" arg.conf |
		cut '-d ' -f3)"

	if [ "$ARG" = 'name' -a "${ENDP%?}=" = "$ENDP" ]; then
		ENDP="$ENDP$NAME"
	elif [ "$ARG" != 'auth' ]; then
		eval "TMP=\"\$$(upper "$ARG")\""
		BODY="$BODY\"$ARG\":\"$TMP\","
	fi
done

RESP="$(curl -s -v -k ${AUTH:+-u "$AUTH"} ${BODY:+--json "{${BODY%?}}"} \
	-X "$(echo "$CMD" | cut '-d ' -f3)" "$ENDP")"
echo "$RESP"
