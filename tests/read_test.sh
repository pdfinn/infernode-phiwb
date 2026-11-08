#!/bin/sh
# tests/read_test.sh - phil/read through a real llmsrv whose model
# (tests/fakellm.py) answers with tests/data/read/replies: a reading
# keeps its header and the model's lines; -k gives several readings,
# each saying who read it, with which settings and instructions, and
# when; a reading the prover still cannot read after asking again is
# kept and read fails; each reader is sent the instructions and the
# question; with nothing at /mnt/llm, read says so.  Needs python3;
# ROOT as for tests/run.sh; WWB, the Writer's Workbench, by default
# beside this tree.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/read_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
if ! command -v python3 >/dev/null; then
	echo 'tests/read_test.sh: SKIP: no python3'
	exit 0
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
tmp=$(mktemp -d)
fake=
trap '[ -n "$fake" ] && kill $fake 2>/dev/null; rm -rf "$tmp"' EXIT
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests" "$here/tests/data/read/replies" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/read.inferno" "#U*$here" "#U*$wwb" "$port" 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out"
fail=0
section() {
	sed -n "/^# $1/,/^status/p" "$tmp/out" > "$tmp/$2"
}
want() {
	if ! grep -qF -- "$1" "$tmp/$3"; then
		echo "FAIL: $2"
		fail=1
	fi
}
section 'one reader' one
want 'status ' 'read runs' one
grep -q '^status $' "$tmp/one" || { echo 'FAIL: a reading succeeds'; fail=1; }
sed -n '/^status $/,/^# three readers$/p' "$tmp/out" > "$tmp/onefile"
want '# a test' 'the header is the first line' onefile
want 'C	S1	p' 'the reading is kept' onefile
want 'confined=namespace net=none' 'the reading says how its reader was confined' onefile
for i in 1 2 3; do
	want "out/read/three.$i has its provenance" "reading $i of 3 says who read it, with what and when" out
done
grep -q 'a fourth reading' "$tmp/out" && { echo 'FAIL: -k 3 gives more than three readings'; fail=1; }
want 'You are helping check the reasoning' 'the reader is sent the instructions' requests
want 'Is it?' 'and the question' requests
section 'a reader that never writes' bad
want 'is asked again' 'an unreadable reading goes back to the reader' bad
want 'status fail:unreadable' 'read fails when a reading still cannot be read' bad
want 'the reading is kept' 'the unreadable reading is kept' out
section 'no model' none
want 'no model at /mnt/llm' 'with nothing at /mnt/llm, read says so' none
grep -q '^status $' "$tmp/none" && { echo 'FAIL: with no model, read succeeds'; fail=1; }
[ $fail = 0 ] && echo 'read: ok'
[ $fail = 0 ] || cat "$tmp/out"
exit $fail
