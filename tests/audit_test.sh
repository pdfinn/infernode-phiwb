#!/bin/sh
# tests/audit_test.sh - phil/audit against a live audit log (auditfs):
# a reading phil/read kept, and the reading phil/argue kept from three,
# are backed by their sealed records; a comment added changes nothing;
# a statement changed, or a reading written by hand under a provenance
# line, is unbacked, and audit fails; the chain verifies.  The readings
# come from a real llmsrv whose model (tests/fakellm.py) answers with
# tests/data/audit/reply.  Needs python3; ROOT as for tests/run.sh; WWB,
# the Writer's Workbench, by default beside this tree.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/audit_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
case $(uname -s) in
Darwin)	host=MacOSX;;
*)	host=$(uname -s);;
esac
emu=$ROOT/emu/$host/o.emu
wwb=${WWB:-$(cd "$here/.." && pwd)/infernode-wwb}
if [ ! -f "$wwb/dis/wwb/lib/prose.dis" ]; then
	echo "$0: no built Writer's Workbench at $wwb: set WWB" >&2
	exit 1
fi
if ! command -v python3 >/dev/null; then
	echo 'tests/audit_test.sh: SKIP: no python3'
	exit 0
fi
tmp=$(mktemp -d)
fake=
trap '[ -n "$fake" ] && kill $fake 2>/dev/null; rm -rf "$tmp"' EXIT
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests" "$here/tests/data/audit/reply" &
fake=$!
sleep 1
timeout 180 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/audit.inferno" "#U*$here" "#U*$wwb" "$port" 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out"
fail=0
section() {
	sed -n "/^# $1/,/^status/p" "$tmp/out"
}
want() {
	if ! section "$3" | grep -qE -- "$1"; then
		echo "FAIL: $2"
		fail=1
	fi
}
want 'audit/backed: record=[0-9]+ source=phil/read time=[0-9-]+T[0-9:]+Z' 'a reading phil/read kept is backed' 'a reading, sealed'
want '^status $' 'audit succeeds on it' 'a reading, sealed'
want 'audit/backed: record=[0-9]+ source=phil/argue' 'the reading argue kept from three is backed' 'an argument of three'
want 'audit/backed' 'a comment added changes nothing' 'a comment added'
want 'changed:[0-9]+: audit/unbacked: no sealed record' 'a statement changed is unbacked' 'a statement changed'
want '^status (fail:)?unbacked' 'audit fails on it' 'a statement changed'
want 'forged:3: audit/unbacked' 'a reading written by hand is unbacked' 'written by hand'
grep -q 'hand: audit/unread: no provenance line' "$tmp/out" || { echo 'FAIL: a file with no provenance is not a reading'; fail=1; }
sed -n '/^# the chain$/,$p' "$tmp/out" > "$tmp/chain"
grep -q '^ok: ' "$tmp/chain" || { echo 'FAIL: the chain verifies'; fail=1; }
[ $fail = 0 ] && echo 'audit: ok'
[ $fail = 0 ] || cat "$tmp/out"
exit $fail
