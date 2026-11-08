#!/bin/sh
# tests/runner_test.sh - ./phil, the workbench run from the host: output,
# exit status, arguments with blanks and quotes passed as they are,
# absolute host paths, and a model reached for argue.  ROOT as for
# tests/run.sh; WWB, the Writer's Workbench, by default beside this tree.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/runner_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
cd "$here/tests"
fail=0
no() { echo "runner: FAIL: $*"; fail=1; }
out=$(../phil prove data/argue/steps/kalam.logic data/argue/steps/kalam.md) || no 'a valid argument exited non-zero'
echo "$out" | grep -q 'kalam.logic: argue/valid 1' || no "no verdict: $out"
../phil prove data/argue/steps/bad.logic > /dev/null && no 'a syntax error exited 0'
out=$(../phil prove "$here/tests/data/argue/steps/kalam.logic") || no 'an absolute path failed'
echo "$out" | grep -q 'argue/valid 1' || no "an absolute path: $out"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp data/argue/steps/kalam.logic "$tmp/it's a b.logic"
out=$(cd "$tmp" && "$here/phil" map "it's a b.logic") || no 'a name with a blank and a quote failed'
echo "$out" | grep -q 'C (S5)' || no "a name with a blank and a quote: $out"
# argue reaches a model: llmsrv for the backend LLM names, and the
# model's file is proved; LLM naming no backend is refused
out=$(LLM='os claude -p' "$here/phil" argue data/argue/sample.md 2>&1) && no 'LLM naming no backend succeeded'
echo "$out" | grep -q 'LLM is anthropic' || no "LLM naming no backend: $out"
if command -v python3 > /dev/null; then
	port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
	python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests" "$here/tests/data/argue/reply" &
	fake=$!
	sleep 1
	cp data/argue/sample.md "$tmp/sample.md"
	out=$(cd "$tmp" && LLM="openai http://127.0.0.1:$port/v1" "$here/phil" argue -m fake-model sample.md 2>&1) || no "argue through a fake API failed: $out"
	kill $fake 2>/dev/null
	echo "$out" | grep -q 'affirming the consequent' || no "argue through a fake API: $out"
	grep -q 'You are helping check the reasoning' "$tmp/requests" || no 'the fake API was not sent /lib/phil/argue'
	[ -f "$tmp/sample.md.logic" ] || no 'the logic file was not kept'
fi
[ $fail = 0 ] && echo 'runner: ok'
exit $fail
