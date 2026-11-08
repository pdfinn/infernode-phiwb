# ϕwb: the Philosopher's Workbench

A design sketch, before code. Status: step 0 is done, the move and
`read` and `settle`; CORPUS.md's step 1 is built but for what it lists
as left. This is the collection
that `argue`, `prove` and the corpus of [CORPUS.md](CORPUS.md) move
into, what stays behind in the Writer's Workbench, how the two meet,
and the two ways a language model is used in it. [REACH.md](REACH.md)
says what the collection can and cannot do.

## Why a collection of its own

The Writer's Workbench reads prose and reports what an editor would
query. `argue` and `prove` already strain that: they ask a model, take
minutes, and produce readings. The corpus, its cases, ledger, agenda
and contest are not writer's tools at all. Kept in wwb they make its
description false and bury the philosophy under a spelling checker.
So they get a collection, a repository and a name of their own.

## The name

The collection is ϕwb. Inferno's names are UTF-8, as they have been
since Pike and Thompson wrote UTF-8 for Plan 9, so `/dis/ϕwb/prove` is
a legal name and the collection is called what it is called. What one
types is `phil/prove`: `philns` binds the same directory at both names,
`/dis/ϕwb` and `/dis/phil`, because a bind costs nothing. The three
letters `pwb` are not used: they were Bell Labs' Programmer's
Workbench, which the Writer's Workbench was built on.

## What moves, what stays, what mounts

| Moves to ϕwb | Stays in wwb | ϕwb reaches through a bind |
|---|---|---|
| `argue`, `prove`, `join`, `map`, `tableau` | every prose check; `claims`, `facts`, `bib` | `sentences`, `deroff`: the exact addresses that make a finding clickable |
| `corpus`, `read`, `settle`, `readable` (built); `align`, `cases`, `ledger`, `agenda`, `schemes`, `contest`, `split` (to come) | `review`, `rewrite`, `vet`, `judge`, `gate`, `delta`, `tally`, `grade` | (`ask`, once the one way to a model, is gone: the tools use `/mnt/llm`'s files themselves) |
| the logic file, its manual, `lib/argue*`, `lib/settle`, `tests/cases/argue-*`, `prove-*`, `tests/prove-bench` | the rule packs, the OED, the tagger and parser, `wwbfs` | `gate` and `delta`, which read ϕwb's findings unchanged |

The dependency is a mount, not a copy. `philns` binds `wwb/` into the
name space for sentence numbering, markup removal and the model, and
there is one implementation of each. A finding from ϕwb is
`file:line: rule: message`, as wwb's, so wwb's policy tools work on it
and Xenith opens it. `wwb/argue`, `wwb/prove`, `wwb/join`, `wwb/map`
and `wwb/tableau` are kept for a release as scripts that run the
`phil/` commands and say so, then removed.

At build time the dependency is wwb's tree: `prove` and `map` are
compiled against its `prose.m`, and `map` and `tableau` include its
`findings.b`. `WWB` names the tree, by default `infernode-wwb` beside
this one. A change to `prose.m` in wwb stales phil's bytecode as it
stales wwb's own, and both are rebuilt.

## Two uses of a model, kept apart

The question a builder asks first is how much of this is model calls
on the pattern of `argue`, and the answer is: all of the model's
contact with the corpus's state, and none of the driving. There are
two uses, and the design keeps them visibly distinct.

### Reading: the protocol

A **reading** is a model translating one thing into a declared tab
format: a text into a logic file, two sentences into a yes or no, a
scenario into a valuation, a step into a scheme. `argue` is the
pattern, and every tool that touches corpus state uses it through two
commands extracted from `argue`:

	phil/read [-k n] [-m model] prompt vocab text > readings
	phil/settle [-a answers] readings ... > kept

- **Blinded.** Each reader runs in a name space holding the prompt,
  the text or fragment, the shared atoms, and `/mnt/llm`. Not the
  other readings, not the answers, not the claim a case was written
  to refute, not the rest of the corpus. On InferNode the driver
  builds that name space (`pctl newns`, bind) before each reader
  starts, so the blinding is structural; on a host without one it is a
  directory and a prompt that says not to look, and the provenance
  line says which.
- **Several, and not all one model.** `-k` readers, each a new
  session; different models by binding a different server at
  `/mnt/llm` for each. Samples of one model are not independent
  readers: where its error is systematic they agree on it, and the
  question `settle` would ask is never asked (STATUS.md, "Independence
  of readings"). So where a verdict matters, the readers are of at least
  two models, the provenance line says which, and agreement is reported
  within a model and across models apart; and a reader that is not a
  model at all, the skeleton written by rule from the parse
  (MECHANICAL.md), is a reader of another kind and counts for more than
  a third sample.
- **Declared format, parsed by rule.** A reading the parser cannot
  read goes back once with the reason; a second failure is a reading
  lost, reported.
- **Compared by rule; a question where they differ.** `settle` finds
  where the readings disagree, writes each difference as a yes or no
  question in the text's own words, asks it of fresh blinded readers,
  and keeps the reading the answers and the words favour. The
  faithfulness read-back (`prove -e`) vetoes a reading whatever the
  answers say.
- **Recorded with provenance.** Every line a reading produces ends
  in a field of `attr=value` words (ndb(6)'s form, as InferNode's
  9p-data-conventions ask for records whose fields may grow): who
  decided, the model, the prompt's hash and the date,
  `readings=3/3 model=claude-opus-5-5 prompthash=7f3a9c1e date=2026-10-19`,
  or `answers=2/3 ...`. A person's line, `hand=<who>`, outweighs it; a
  driving agent's line, `agent=<name>`, is a proposal with that
  provenance and never outweighs a person's. A reading's own line
  (`# read model=...`) also gives the settings it was asked with
  (`temperature=`, `maxtokens=`, `thinking=`, read from the session's
  files at `/mnt/llm`), which the 2026 guidance for reproducible model
  use in the humanities asks for beside model, version, date and
  prompt, and how it was confined: `confined=namespace net=none`.
  Still to add: a seed, where a provider takes one.
- **Blinded to the corpus, not to its training.** A reader cannot see
  the other readings or the answers. It can recall what it read in
  training, and the faults of the gold set are the literature's. So
  the bench scores canon passages apart from held-out ones, and the gap
  between them is reported as the measure of what blinding cannot
  remove ([THREATS.md](THREATS.md)).
- **Kept, and reproducible as far as a model allows.** A live reading
  cannot be rerun and get the same answer, so it is never thrown
  away: `read` keeps every reading under the hash of its prompt, text
  and model, and a rerun with the same three returns the kept one.
  A changed prompt or model is a new hash and a new reading; the old
  keeps its provenance, and a corpus can say which of its lines came
  from which prompt.

Every reading-shaped tool is then a prompt file, a parser and a
checker: `align` is a prompt asking whether A entails B, a parser for
yes or no, and the faithfulness check; `cases` is a prompt asking for
a valuation, a parser for atom lines, and `prove`; `schemes` is a
prompt naming a scheme and a parser for one word. The model calls are
many (readers times parts times works) but there is one shape, and
the shape is tested once.

### Driving: the investigation

The **driver** composes ideas. It is a philosopher at a shell, or an
agent on their behalf, with the whole corpus visible, choosing what to
look at and what to try. It is not blinded, because its job is to see
everything. It decides nothing: its proposals enter the corpus only
through the reading protocol, or by hand with `hand` or `agent`
provenance. The rules and the person decide what stands.

The driver's loop:

1. Read `agenda`, sorted by `agenda/value`: what is open, and what
   closing it would change.
2. Choose an item and make a move. The moves are few and each has a
   tool:
   - **Write a case** against a claim (`cases`): a situation in which
     it fails.
   - **State a bridge** the field assumes (`agenda/field-assumes`) as
     a premise, and ask who would grant it.
   - **Draw a distinction** (`split`): one atom into two, where a set
     is inconsistent or a dispute is verbal.
   - **Occupy a position** nobody holds (`agenda/unoccupied`) and read
     its ledger: what it costs.
   - **Answer an objection** nobody answered, or **raise one**
     (`contest`).
   - **Restate a question** (`questions`): what is being asked, in
     atoms, and whether two works ask the same.
3. The rules check the move: `prove` says whether the attack is one,
   whether the case refutes, what the premise commits its holders to;
   `ledger` says whether the corpus is cheaper or dearer for it.
4. Record, with provenance, and go to 1.

This is the shape of the mathematics work, propose and verify, with
the agenda as the search frontier and the ledger as the score. The
toolkit is built so that a person at a shell is a sufficient driver,
which is what makes it buildable now; an autonomous driver is a
Veltro agent given this loop as its prompt and `phil/` as its tools,
and `contest` is the first piece of it.

### The person

"A person at every judgement" needs a way for the person to judge.
The judgements are files (`answers`, `verdicts`, the `hand` lines in
`align` and `atoms`), and two things present them:

- `phil/pending` lists what waits for a person: each question the
  readers split on, each case verdict, each proposed alignment or
  split, with what settling it would change (the positions it decides,
  the works that rest on it), sorted by that. `pending -a` records an
  answer as a `hand` line with the person's name.
- In Xenith, every finding is an address, so a question opens at its
  sentence; the logic file's lines are addresses too (`logic:/^C12/`),
  so the reading sits beside the text and is corrected in place.

The person is not blinded as a driver, but is as a judge of a case:
`pending` shows the scenario and asks whether it is possible and what
holds in it, and does not show the claim it was written to refute,
for the same reason a reader is not shown it.

### What a model never does

It never decides validity (`prove` does), never decides what a line's
provenance is (the tool that wrote it does), never overwrites a
person's line, and never sees, as a reader, what it was not given.

## The repository

Mirrors wwb's, so that what moves keeps its shape:

	ϕwb/
		README.md
		mkfile			as wwb's: appl/lib, appl/cmd, sh
		philns			binds dis (as /dis/phil and /dis/ϕwb), lib, man; runs wwb's wwbns if wwb is not bound
		phil			runs a command from the host, as wwb's ./wwb does
		appl/cmd/		prove.b, join.b, map.b, tableau.b; ledger.b, agenda.b, split.b (rules; join keeps ids)
		appl/lib/		what prove and ledger share: the logic file's reader
		sh/			argue, read, settle, align, cases, schemes, contest, pending, report (shell: they drive readers or present to a person)
		lib/phil/		the prompts: argue, argue-work, settle, align, align-elim, cases, cases-valuate, schemes, contest-attack, contest-reply, questions
		lib/phil/schemes/	the critical questions, one file per scheme
		man/1/phil		the manual
		tests/cases/		golden files, as wwb's tests/cases
		tests/fakemodel		scripted readers, as wwb's, so every reading-shaped tool is tested without a model
		tests/corpus/		the benchmark of CORPUS.md: a corpus directory each, with its golden ledger and agenda
		tests/run.sh		runs them in an emulator, as wwb's

Rules in Limbo, drivers of readers in the shell, as now. A tool that
calls no model is a Limbo command with a golden test; a tool that does
is a shell script over `read` and `settle` with a scripted-model test
and, for the benchmarks, a live run recorded.

## How a prompt change is checked

The prompts in `lib/phil` are the code of every reading-shaped tool,
and a word changed in one changes what the corpus says. A prompt is
held to the rule PROVE-PERFORMANCE.md holds `prove` to, with the
allowance that a model varies:

1. The scripted-reader tests must give the same findings before and
   after; a prompt change that changes a parser's input is a format
   change and is made with the parser.
   `ARGUE_REQUESTS=dir tests/argue_test.sh` keeps every request a
   scripted run sends, so that a change meant to send the same requests
   can be shown to.
2. The live benchmarks are run three times before and three times
   after, with the same model, and the report says for each finding
   whether it was found in every run before, in every run after, or
   moved (`argue -n` does this for one text; the benchmark runner does
   it for a corpus).
3. A change is taken only if nothing the benchmarks expect is lost in
   any run after, and the gain is named: a fault found that was not,
   fewer splits, fewer mismatches.
4. The old prompt's hash stays valid: readings made with it keep their
   provenance and are not remade unless asked.

A prompt change without this record is not made.

## Buildable from this

The order of work in CORPUS.md stands. Before it, the move:

0. **The move.** The repository, `philns`, the files in the table above
   moved with their tests, `wwb/argue` and `wwb/prove` left as
   forwarding scripts. `tests/run.sh` passes as before. Done: every
   golden case gives what it gave in wwb, but for the program's name in
   one heading, and every host test is as it was. Then `read` and
   `settle` extracted from `argue`, with `argue` a client of them and
   its tests unchanged. This is a refactor with a golden test on every
   side of it, and it is the step that makes every later tool a prompt
   and a checker. Done, and held to more than the tests: every request
   argue's test sends the model (fourteen scenarios, 182,069 bytes) is
   byte for byte what it sent before (`ARGUE_REQUESTS=dir
   tests/argue_test.sh` keeps them). `phil/readable` is the checker for
   a logic file. What step 0 leaves:
   - `settle` compares logic files only (through `prove -c`); a reading
     of another form (an alignment's yes or no, a case's valuation) will
     want a comparer of its own, and `settle` a way to name it, when
     `align` and `cases` are built.
   - `argue -w` still asks the model directly to join a work's parts
     (`/lib/phil/argue-work`), since that reading is checked and retried
     in its own way; it moves onto `read` when `read` can take that
     check.
   - A reader that is a host command (`os claude -p ...`) is not
     confined by InferNode's name space, and its readings say so. Only
     the API, `/mnt/llm`, or a reader inside InferNode is blinded by
     construction.

Then CORPUS.md's steps 1 to 8, with `questions` at step 4 beside
`align` (the same protocol) and `split` at step 6 beside `schemes`.

**Done, for the prototype,** means:

- The benchmark corpora pass with scripted readers: the golden ledger
  and agenda come out of the texts and the scripted readings by rule.
- Gettier, Mackie and Chisholm pass with a live model in two runs of
  three: the known fault is found from the texts alone, with readers of
  two model families, and found by both.
- The corpus owner's own work with Gross and Dyzenhaus yields a ledger and an
  agenda a person has read and found to be about the texts.
- Every line of every corpus file says who wrote it, with the model,
  the prompt's hash and the date where a model did, and every
  `readings` line matches a model call in the audit log (`phil/audit`
  checks each reading against the records `read` and `argue` seal;
  holding the corpus's own lines to them is still to do).
- A reader that tries to read another reading, the answers, or the
  corpus gets "file does not exist": a host test, after
  `veltro_security_test`'s pattern, starts a reader and has it try.
- That work's attributions to Gross, Dyzenhaus and Schmitt are
  checked against their texts and the findings read by a person.
- The work edited and reread: every corpus file still names its
  statements, and `corpus/stale` names exactly the lines that changed.
