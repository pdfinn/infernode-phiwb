# ϕwb, the Philosopher's Workbench for InferNode

Tools that read an argument and decide what follows from it. A language
model writes a text's argument down in logic, one statement to a line,
each pinned to the sentence it came from; a prover decides, by rule,
whether the conclusion follows, and where it does not, says why in the
text's own words: the case that refutes it, the fallacy's name, the
premise missing, the premise never stated, the objection left
unanswered. The model reads; the rules decide.

```
; phil/prove agents-misread.logic agents.md
agents.md:1: argue/converse: P1 (S1): "only" makes what follows it necessary, not sufficient, but P1 has it the other way round: it reads "for every x, if x is rational, then x is a moral agent"
agents.md:3: argue/invalid: C (S3): does not follow: when only "dolphin is a moral agent" is true, every premise holds and the conclusion fails; this is denying the antecedent (P1 and P2)
agents.md:3: argue/countermodel: C (S3): D = {dolphin}; moral = {dolphin}, rational = ∅
agents.md:3: argue/missing: C (S3): it would follow given "¬rational(dolphin) → ¬moral(dolphin)"
agents-misread.logic: argue/valid 0
```

The tools began in the [Writer's Workbench](https://github.com/pdfinn/infernode-wwb)
(wwb), which reads prose and reports what an editor would query. They
outgrew it: they ask a model, take minutes, and produce readings of an
argument rather than queries about its prose, and what is to be built on
them (a field's works read as one, cases as a test suite, a ledger of
what each premise costs) is not a writer's tool at all. So they are a
collection of their own, and wwb is what they read prose through: its
sentence numbering, its markup removal, its way to a model.

Every finding is one line, `file:line: rule: message`, as wwb's are, so
Xenith and acme open it with button 3 and wwb's `gate`, `delta` and
`tally` work on it.

## The tools

| Command | What it does |
|---|---|
| `phil/argue` | a model writes the document's argument down in logic; `phil/prove` decides whether it holds; with `-k`, several readings compared and a question asked where they differ; with `-w`, a whole work read part by part |
| `phil/prove` | whether a conclusion follows: a counterexample, the fallacy's name, the missing premise, a contradiction, circularity, unstated assumptions; objections and replies, and what survives; every coherent position over a family of claims (`-p`) |
| `phil/join` | the logic files of a work's parts as one argument in steps, for `argue -w` |
| `phil/map` | an argument's shape: what each step rests on, as a tree, or in Argdown for argument-mapping tools |
| `phil/tableau` | `prove -P`'s proofs, analytic tableaux, typeset for troff: the tree in pic, the formulas in eqn; countermodels as tables |
| `phil/read` | a reading: a model writes a logic file, its own lines kept, each reader blinded by name space, a file the prover cannot read sent back; each reading says who read it, with which instructions and when |
| `phil/settle` | which of several readings to keep: where they differ, a question yes or no, answered afresh or by a person |
| `phil/readable` | what makes a logic file one the prover cannot read; `read`'s checker for `argue` |
| `phil/corpus` | a field's works read as one, by rule: each work over the shared atoms, the claims and who asserts, denies, assumes or reports each, statement ids that survive a reread, and the secondary literature checked against the primary (a claim given as a work's that its reading denies, or never makes) |
| `phil/tree` | a corpus as files to walk and grep: each work's statements, each claim a directory (its formula, its atoms, who asserts, denies, assumes or reports it), named by a hash of its formula; `notes/` made beside it and left to the researcher |
| `phil/audit` | whether each reading is one a model wrote, as it now stands: its statements against the records `read` and `argue` sealed in the audit log (auditfs); a reading written or changed by another hand is `audit/unbacked` |
| `phil/skeleton` | a reading by rule, with no model: from wwb's parse, the conclusion by its marker, conditionals, disjunctions, denials, necessity and ought, and quantified subjects, an atom to each clause; a reader of another kind to set beside a model's |
| `phil/shape` | the form of each statement, atoms as letters, and its main connective: two readings whose atoms differ compared by sentence |
| `phil/align` | which atoms of two readings of one text are one claim, by rule: paired by the form of their statements at each sentence, and by their meanings' words where the form says nothing; `negates` where one meaning denies; proposals in a corpus's `align` lines |
| `phil/canon` | canonical citations (Stephanus, Bekker, KrV A/B, Akademie, the Summa, Diels-Kranz) resolved against a table of works built from PerseusDL, or refused: no such passage, or an abbreviation it does not know |

The manual is `man 1 phil`. The logic file is described in
[docs/ARGUMENT-FORMAT.md](docs/ARGUMENT-FORMAT.md), and what the tools
showed on real philosophy in [docs/ARGUE-IN-PRACTICE.md](docs/ARGUE-IN-PRACTICE.md).

## What it is for, and what it is not

Validity is the cheap part, and a valid argument is only one whose
conclusion follows from its premises as read. What the tools are for is
the bookkeeping a debate needs and nobody keeps: which premise does the
work, which is never stated, which objection was never answered, which
case a theory fails, which disagreement is in the words.
[docs/REACH.md](docs/REACH.md) goes through philosophical problems one by
one: those within reach now, those at the edge (and the part missed),
and those out of reach by kind. Read it before pointing the tools at a
problem.

## What is to come

Where the tools stand, and what published work says about the hard
parts, is [docs/STATUS.md](docs/STATUS.md). The design for the rest is
in four documents:

- [docs/PHIL.md](docs/PHIL.md): the collection, the two ways it uses a
  model (blinded readings under one protocol; a driver composing the
  investigation), and what done means for the prototype.
- [docs/CORPUS.md](docs/CORPUS.md): a field's works read as one: shared
  claims, who says what, kinds of premise, cases as a test suite, a
  ledger of what each premise costs, an agenda of what is open, and a
  benchmark of settled debates to pass first.
- [docs/REACH.md](docs/REACH.md): the problems the tools can and cannot
  reach.
- [docs/MECHANICAL.md](docs/MECHANICAL.md): each place a model is called,
  and the rule or small trained model that could do it instead, judged
  by the bench.
- [docs/SOURCES.md](docs/SOURCES.md): references resolved against the
  record, canonical citations (Bekker, Stephanus, Akademie-Ausgabe)
  resolved to passages, quotations checked against their edition; what
  `claims/attributed-unread` points at.
- [docs/THREATS.md](docs/THREATS.md): what readers, a driver and a
  corpus must be defended against, what the name space answers, what
  it does not, and the tests that asks for.

What the tools do on primary texts, and what was changed because of it,
is [bench/RESULTS.md](bench/RESULTS.md).

Every change to a prompt in `lib/phil` is checked live before and after,
and recorded in [docs/PROMPT-CHANGES.md](docs/PROMPT-CHANGES.md).

## Installing

You need a built InferNode and a built Writer's Workbench beside this
tree, since `prove` and `map` load wwb's prose library:

```sh
git clone https://github.com/infernode-os/infernode
git clone https://github.com/pdfinn/infernode-wwb
git clone https://github.com/pdfinn/infernode-phiwb
export ROOT=$PWD/infernode
export PATH=$ROOT/MacOSX/arm64/bin:$PATH   # or Linux/amd64, and so on
# build InferNode as its README says, then:
(cd infernode-wwb; mk install)
(cd infernode-phiwb; mk install)
```

This builds into `dis/` inside this tree; nothing is copied into
InferNode or into wwb. `WWB` names wwb's tree if it is not
`../infernode-wwb`. After wwb changes its prose module, build again from
clean: `mk nuke` and `mk install`.

Inside InferNode, bind it in:

```
run /n/local/path/to/infernode-phiwb/philns
```

`philns` binds the commands to `/dis/phil`, run as `phil/prove` and so on,
and the same directory to `/dis/ϕwb`; the prompts to `/lib/phil`; the
manual to `/man/1/phil`. If wwb is not in the name space already, it runs
wwb's `wwbns` first, from `infernode-wwb` beside this tree or the
directory given as its second argument. Nothing of InferNode's is hidden.
In a running Xenith, `Local run /n/local/path/to/infernode-phiwb/philns`
makes the binds in Xenith's own name space.

From the host shell, or for an agent, `./phil` runs a command without
entering InferNode, as wwb's `./wwb` does:

```sh
./phil prove argument.logic argument.md
ANTHROPIC_API_KEY=... ./phil argue -k 3 -m claude-opus-5-5 chapter.md
LLM='openai http://localhost:11434/v1' ./phil argue -k 3 -m llama3.1 chapter.md
```

`argue`, `senses`, `claims`, `read` and `settle` reach a model only
through the files at `/mnt/llm` (`llmsrv(4)`, or a model mounted from
another machine): each opens a session there, writes the instructions to
its `system` and the text to its `ask`, reads the answer back from
`ask`, and closes it (`lib/phil/llm` holds the few lines that open one).
From the host, `LLM` (`WWBMODEL` is its old name) names the backend
`./phil` has `llmsrv` serve: `anthropic`, the default, `anthropic url`,
or `openai url`. A reader never has the network or the key: the server
does. With a Claude subscription and no API key, InferNode's claude-gate
(`tools/claude-gate/`) puts the Claude CLI behind an OpenAI-compatible
API for llmsrv to use. The whole
document goes to the model; for one that must not leave the machine, use
a local model.

## Trying it

From the host shell, in `demo/`, after installing. These need no model:

```sh
cd demo
../phil prove agents-misread.logic agents.md   # a misreading caught by rule
../phil scope necessity.logic necessity.md     # an argument that turns on where "necessarily" goes
../phil says reports.md                        # who the text gives its claims to
```

These read a text with a model (`ANTHROPIC_API_KEY` set, or `LLM`
naming another backend), each writing a file the next reads:

```sh
../phil argue -k 3 -o cosmos.logic cosmos.md   # read the argument three times, settle, prove
../phil senses -d cosmos.md cosmos.logic       # one word in two senses?
../phil scope cosmos.logic cosmos.md           # turns on the scope of a necessity?
../phil claims reports.md                      # everything a source claims, for a corpus
```

The tools compose: each reads files and writes one, and none runs
another under a flag. `demo/guide` is the same tour, clicked through in
Xenith; `bench/` is the tools run on primary texts, with what they found
in `bench/RESULTS.md`.

## Arguments


`phil/argue` has a model write a document's argument down as a logic file, one
statement to a line, each with the sentence it came from. `phil/prove` then
decides it by trying every case. The model only reads; it can't vouch for the
reasoning. The file stays behind, so a person or an agent can correct how the
model read the text and prove it again:

```
atom	patched(x)	x is patched
atom	secure(x)	x is secure
P1	S1	∀x (patched(x) → secure(x))
P2	S2	secure(web1)
C	S3	patched(web1)
```

```
; phil/prove server.logic server.md
server.md:2: argue/invalid: C (S3): does not follow: when "web1 is secure" is true, "web1 is patched" is false, every premise holds and the conclusion fails; this is affirming the consequent (P1 and P2)
server.md:2: argue/countermodel: C (S3): D = {web1}; patched = ∅, secure = {web1}
server.md:2: argue/missing: C (S3): it would follow given "secure(web1) → patched(web1)"
server.logic: argue/valid 0
```

Formulas are shown in logic's own symbols: ¬ ∧ ∨ → ↔ ∀ ∃, □ ◇ for
necessity and possibility, O and P for obligation and permission. A file
may be written in them or in ASCII (`!`, `&`, `|`, `->`, `all x:`,
`[]`, `ought`, ...); `phil/prove -f` writes one in the symbols, and `-A`
shows everything in ASCII for a tool that can't take UTF-8. TPTP (`-t`) is
ASCII, as the provers that read it want.

It also finds premises that contradict each other, a conclusion that restates
a premise, premises the conclusion doesn't need, a generalization from named
cases to every case, and a valid argument that rests on something the text
never states. It can say whether an argument is valid, never whether its
premises are true.

With `-P`, a valid conclusion comes with its proof, an analytic tableau
(a truth tree, as in Smullyan and, for the modal logics, Priest), every
line numbered with what it came from:

```
# C (S4), proved by a tableau: every branch closes (×)
#	1. rain → wet   P1
#	2. rain         P2
#	3. ¬wet         C denied
#	├─ 4. ¬rain     1 →
#	│  × 2, 4
#	└─ 5. wet       1 →
#	   × 3, 5
```

An invalid conclusion gets its countermodel (`argue/countermodel`), and with
`-P` its tree too: a branch that stays open, marked ↑, the case it describes
read off it.

```
# C (S3), not proved by a tableau: a branch stays open (↑)
#	1. patched → secure   P1
#	2. secure             P2
#	3. ¬patched           C denied
#	├─ 4. ¬patched        1 →
#	│  ↑ patched = F, secure = T
#	└─ 5. secure          1 →
#	   ↑ patched = F, secure = T
```

`phil/tableau` typesets them for troff, as the textbooks set them: each tree
in pic, each formula in eqn, an open one titled not valid, laid out from the widths troff gives them; each
countermodel a table (tbl), what is true where, a row to each claim and a
column to each world, the worlds each sees its last row. In InferNode, with
the [troff package](https://github.com/pdfinn/infernode-troff):
`phil/prove -P f.logic | phil/tableau | pic | tbl | eqn /lib/troff/eqnrc - |
troff | tr2pdf`; in a book, `book(1)` sets them, tagged for a PDF/UA-1 PDF.

With `-v`, a valid argument is explained as an invalid one is: what the
conclusion follows from, and for each premise it needs, the case in which it
fails without it. With `-p`, the premises are taken as a family of claims and
every subset is checked: each smallest set that cannot all be true (an
impossibility result, at its sentence) and each coherent position, told as
what it gives up, with the plainest case in which the rest hold. On the
eleven axioms of a deterrence model over four periods it finds the same
three impossibilities and fourteen positions as an exhaustive z3 search,
in the same order (`tests/data/argue/positions/deterrence.logic`).

Where trying cases can't decide (*some* inside *all*, over relations), it
looks for a proof by Herbrand's theorem, and says `argue/undecided` only
when it finds neither a case nor a proof. With `-k 3`, `phil/argue` has the
model read the text three times. Where the readings disagree, the prover
builds a situation that tells them apart and asks a yes-or-no question
about it:

```
# question S1: Suppose "the server is secure" is true and "the server is patched" is false. Is S1, "If the server is patched, it is secure.", true then?
# if yes: server.logic server.logic.3
# if no: server.logic.2
```

The model answers it afresh, or a person does (`-q`, then `phil/prove -c -a`),
and the answer rules out the readings that disagree with it.

A model's readings vary from one run to the next, so one run is not the
last word. `-n 2` does the whole twice, afresh, and gives the first run's
findings, each that a later run did not make marked `[in 1 of 2 runs]`;
`argue/runs-agree 0` says the runs' verdicts differ, and that the verdict
rests on how the text is read.

## Trying it

`demo/guide` is a guide to read in Xenith, every command in it run by a
click: a model's misreading caught by rule, necessity and obligation, an
argument's shape, objections and replies, correcting the logic, and a
model reading a text.

## Tests

```sh
ROOT=/path/to/infernode tests/run.sh             # the golden cases, in an emulator
ROOT=/path/to/infernode tests/argue_test.sh      # phil/argue calling a fake model's API directly
ROOT=/path/to/infernode tests/read_test.sh       # phil/read's readers blinded: what they cannot see, by name or device
ROOT=/path/to/infernode tests/format_test.sh     # every logic file rewritten and proved the same; countermodels checked; tableaux close
ROOT=/path/to/infernode tests/prove_z3_test.sh   # prove's verdicts against Z3 (pip install z3-solver)
ROOT=/path/to/infernode tests/typeset_test.sh    # tableau set by the troff package (infernode-troff beside this tree)
ROOT=/path/to/infernode tests/runner_test.sh     # ./phil from the host
EMU=/path/to/sdl/o.emu ROOT=... tests/demo_test.sh  # the guide clicked through in Xenith (SDL emulator)
```

`mk test` runs them all. `tools/prove-bench` holds the prover's benchmark
against Z3, E and Vampire, and [docs/PROVE-PERFORMANCE.md](docs/PROVE-PERFORMANCE.md)
the rule a change to `prove` is held to.

## Layout

```
appl/cmd/          prove, join, map, tableau, corpus, says, kind (Limbo)
sh/                argue, read, settle, readable, claims, senses, scope, tree (Inferno shell)
lib/phil/          the instructions argue gives a model
man/1/phil         the manual
demo/              the guide and its files
docs/              the logic file, the design, what the tools can reach
tests/             golden cases, data, host tests
tools/prove-bench/ the prover's benchmark
philns             binds the workbench into a name space
phil               runs a command from the host
```
