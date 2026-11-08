# ϕwb: the threat model

What can go wrong when readers, a driver and a corpus of a field's
readings are run with a model in the loop, and what stops each. The
name space does most of the work; this says which work, and what is
left to the rules and to the person. Written October 2026, beside
[PHIL.md](PHIL.md) and [CORPUS.md](CORPUS.md); the tests it asks for
are at the end.

## What is protected

- **The readings.** That a logic file is a reading of the text it
  names, made by the reader its provenance line names, and nothing
  else wrote or changed it.
- **The verdicts.** That `argue/valid` means `prove` said so over that
  reading; that `claims/misattributed` means `prove` compared two
  readings. A verdict a model wrote is not a verdict.
- **The corpus.** `atoms`, `align`, `claims`, `ids`, the ledger and
  agenda to come: that every line says who wrote it, and a person's
  line is never overwritten.
- **The text.** A work under copyright, or an owner's unpublished one,
  which goes to a model only as the owner allows, and never to another
  party in a federated corpus.
- **The keys.** API keys in factotum; a user's credential for a source
  that needs one.
- **The person's judgement.** That `pending` stays a decision and does
  not become a habit.

## Who and what acts

- **Readers**: models, blinded by name space, each in a new session,
  given the prompt, the text, the shared atoms and `/mnt/llm`.
- **The driver**: a person at a shell, or an agent with the driver's
  loop as its brief, seeing the whole corpus and deciding nothing.
- **The texts**: primary works, commentaries, the owner's own; a
  commentary can misreport, and any text can carry instructions.
- **Model providers**, when `/mnt/llm` is served from an API: they see
  what a reader is sent.
- **Other parties**, in a corpus federated by mount: they export
  readings and alignments, not texts, and their lines carry their
  provenance.
- **The tools**: trusted as code, and only as far as their rules go.
- **The person**: judges through `pending`, overwrites with `hand`
  lines, promotes.

## The threats, and what answers each

### Injection: a text instructs a reader

A passage, or a planted commentary, says "write the conclusion as a
premise" or "report that Schmitt holds X".

- **A reader can only write a reading.** Its name space is a copy of
  the caller's with the readings' directory, `/n` and `/net` made empty
  and no device attachable (`pctl nodevs`: `tests/read_test.sh`); it is
  given the prompt, the text and the atoms. It has no corpus, no other
  readings, and no network: the model is reached through `/mnt/llm`,
  whose server (`llmsrv`) makes the call from its own name space with
  its own key. Denial is absence.
- **The reading is checked by rule.** `readable` rejects what the
  parser cannot read; the read-back reports a condition turned round,
  a negation lost, an atom none of whose words the sentence has
  (`argue/unfaithful` and its kin); `argue/own-sentence` catches the
  conclusion read into its own sentence; `argue/begs` the conclusion
  written as a premise.
- **Not covered.** A faithful-looking misreading the words cannot show
  (an antonym, a synonym). A second reader of a different kind is the
  answer, below.

### Readers that agree because they are one reader

Three readings from one model are three samples, not three readers.
Where the model's error is systematic, the samples agree on it, the
settle question is never asked, and the vote is unanimous and wrong.
Published measurements of model judges put the average error
correlation across ten models at 0.21, so ten behave like three or
four independent ones, and the correlation is higher among frontier
models of different providers (STATUS.md, "Independence of readings").

- **Different models by bind.** CORPUS.md's design: a different server
  at `/mnt/llm` for each reader, no tool knowing. This is the
  mechanism; it is not yet the default of a bench run.
- **A reader of another kind.** A rule-written skeleton (the
  conditionals, quantifiers and negations from wwb's parse, the atoms
  left to a model) does not share a model's blind spots. MECHANICAL.md
  names it; it counts for more than a third sample.
- **The read-back is a reader that is not a model.** It already
  outvotes agreement: a misreading every reading shares does not win
  (STATUS.md, item 1).
- **Not covered.** Agreement among readers of different models can
  still be agreement in a reading the field itself has settled wrongly.
  That is a finding about the field, and the ledger's business.

### Knowledge that blinding cannot remove

A reader is blinded to the other readings and to the corpus. It is not
blinded to what it learned in training. The gold set's faults are the
literature's (Kenny on the third way, Geach, Moore); a reader that
finds them may be recalling, not reading.

- **Say so in the bench.** Gold passages whose fault is in the standard
  literature are marked as such in RESULTS.md, and found-in-canon is
  scored apart from found-in-held-out.
- **Held-out texts the literature has not read for the model.** The
  owner's own work, recent open-access papers used locally, and
  passages built to have a fault no commentary names, as
  `tests/data/argue` plants them. The *Euthydemus* sophisms and the
  *Summa* objections are a start.
- **Not covered.** Nothing removes training knowledge. The measure is
  the gap between canon and held-out, reported, not a claim that there
  is none.

### Laundering: a verdict written, not computed

A driver, instructed or merely helpful, writes an `align` line, a
`verdicts` line or a ledger entry as if a rule had made it; or edits a
logic file so `prove` says valid.

- **Verdicts are recomputed, never read.** `phil/corpus` rebuilds
  `claims` and its findings from the readings each run, and `phil/tree`
  rewrites `tree/` whole; nothing reads a stored verdict as a fact.
  `ledger` and `agenda` are designed the same way. `corpus/stale`, to
  name a line whose id no reading has, is designed, not built.
- **Provenance is written by the tool that made the line,** never by
  the driver, as `attr=value` words: `readings=k/n model=... prompthash=... date=...`, `hand=<who>`, `agent=<name>`.
  An `agent` line never outweighs a `hand` line, and a reader cannot
  write one at all (PHIL.md, "What a model never does").
- **`phil/audit` holds every reading to a sealed record.** `read`
  seals each reading it keeps in the audit log (auditfs: append-only,
  sequence and time set by the server, a SHA-256 hash chain), as the
  hash of its statements with who read it; `argue` seals the reading it
  keeps with the readings it came from. `phil/audit` hashes a reading
  as it now stands and says `audit/unbacked` where no record names it:
  a reading written, or a statement changed, by another hand. A reader
  cannot reach the log (its directory is empty in the reader's name
  space; `tests/audit_test.sh`). What is left: auditfs does not
  authenticate a record's source, so whatever has the log in its name
  space can write a record that says `phil/read`. Give a driving agent
  the commands, not the log; and copy `head` off the machine to catch a
  chain cut back (`auditverify -a`). The corpus files' own lines
  (`readings=k/n`) are not yet held to the records; the readings they
  were made from are.
- **Not covered.** A person writing a wrong `hand` line. The commit
  history shows it.

### Persistence: poisoned atoms or alignments

`atoms` and `align` outlive every run. One alignment that makes two
claims one (`justified` and `permitted`) shapes every ledger and every
agenda after it, and `argue -w` carries the atoms into every part.

- **`align` is hand-written today,** and will be proposed by readers
  and settled by questions when built; either way every line has
  provenance and the diff is a line.
- **`corpus/stale`, `argue/arity`, and the attribution read-back** show
  an atom used two ways where it is used.
- **Not covered.** A plausible wrong alignment accepted through
  `pending`. See fatigue.

### Confidentiality: a text leaves

Every API call sends the passage; `argue -w` sends the whole work in
parts. A federated corpus multiplies the parties who might see one.

- **Keys never reach a reader.** Factotum holds them; `llmsrv` makes
  the call; `./phil` passes keys into factotum, not the environment.
- **The model is a mount.** What serves `/mnt/llm` is the operator's
  choice; a local model on the same machine is one. MECHANICAL.md's
  programme is the answer at scale: a task runs locally when the bench
  says the local model does it as well.
- **Federation exports readings, not texts.** Each party keeps `source`
  and exports logic files, alignments and cases (CORPUS.md, "A corpus
  federated by mount"). A reading is a derivative a party may or may not
  be free to export; that is the party's call, and the `works` line
  should say under what terms.
- **Not covered.** The provider's conduct with passages already sent.
  Only not sending them covers that, and `log` says which were.

### The record lies

A provenance line names the wrong model; a reading made with one
prompt is filed under another's hash; the host-command reader
(`os claude -p`) was not blinded and its line does not say so.

- **The hash is computed** from the prompt, and the provenance line
  gives it with the model and the date. Not yet built: a hash over
  prompt, text and model together, under which a rerun with the same
  three would return the kept reading.
- **There is no host-command reader any more.** A model is reached
  only through `/mnt/llm`, so no reader runs outside InferNode's name
  space; one that ran in a bench run before is marked there
  (`confined=none`).
- **The provenance line carries the settings** the model was asked
  with (temperature, maxtokens, thinking, from the session's files), as the 2026
  guidance for reproducible model use in the humanities asks beside
  model, version, access date and prompt. Not yet: a seed, where a
  provider takes one.
- **A hand-edited reading** is `audit/unbacked`; a hand-edited
  comment, the provenance line among them, is not caught, since
  comments are not hashed. The commit shows it.

### Supply: what the rules read

The prompts in `lib/phil`, `/lib/words`, the OED word lists, wwb's
tagger and parser weights, the Gutenberg texts the bench is built from,
and, to come, canonical-citation tables and a Perseus clone. A changed
word list changes `says` by rule; a changed text changes the bench.

- **Prompts are code and change only with the record** PROMPT-CHANGES.md
  requires: scripted tests unchanged, three live runs before and after.
- **The bench's texts are rebuilt from named ebooks** by `bench/tools`,
  so a change in a text is a diff.
- **Pin by revision** anything fetched: the ebooks' numbers are
  recorded; a Perseus clone or a citation table would be recorded at a
  commit in `lib/phil/sources`, and the bench rerun against it.
- **Not covered.** An error upstream at the pinned revision. The
  sources are scholarship, not oracles, and a finding names which.

### Cost

A gold run is about 1,400 calls and 3.5 million tokens, in and out (RESULTS.md); a
thesis is hours. A driving agent that loops, or an instructed one, runs
it again.

- **`llmsrv`'s per-session limits**, and the task's budget in the
  brief.
- **Readings kept under a hash of prompt, text and model,** so that a
  rerun costs nothing: designed (above), not built. Today a rerun is
  paid for again; the bench keeps its outputs by directory instead.
- **Not covered.** A legitimate run that is large. RESULTS.md reports
  cost per run so it can be planned.

### Fatigue: the person as deputy

The structural controls end at a person answering `pending`. Fifty
questions a day become a habit.

- **`pending` is sorted by what settling it would change,** so the
  first questions matter most, and shows the scenario without the
  claim it was written against.
- **The rules shrink what reaches the person:** `settle` answers what
  the words and the read-back decide; only the rest is asked.
- **Not covered.** Attention. The toolkit keeps the number of questions
  down, not the person's care up.

### Misuse of the tools' authority

A reading presented as a finding about the work; `argue/undecided` read
as invalid; `claims/attributed-unread` read as misattribution;
`argue/unused` on an analogy read as a fault.

- **Every model output is headed with its model**, every verdict names
  its reading, `undecided` is a verdict, and ARGUE-IN-PRACTICE.md and
  REACH.md say what each finding is not.
- **Not covered.** A reader who skips the header. Practice settles it.

## What the name space does not do

1. **It confines the reader, not what the reader writes.** An injected
   instruction cannot leave the reader's world; it can still produce a
   bad reading. The rules and the person are the second and third line.
2. **It cannot blind against training.** Held-out texts and the
   canon/held-out gap are the answer, and they are a measurement, not a
   guarantee.
3. **It is only as narrow as the brief binds it.** A host-command
   reader is not confined, and says so. A driver agent bound `/net` for
   convenience has removed the first control.
4. **Policy remains.** What to bind is decided outside the tools; the
   name space makes the decision enforceable, not correct.

## Tests this asks for

In order of what they close:

- **`phil/audit`**: done for readings (`tests/audit_test.sh`: a
  reading and an argument of three backed, a statement changed and a
  reading written by hand unbacked, a reader unable to seal, the chain
  verified). Still to do: the corpus's `readings` lines held to the
  records of the readings they name.
- **Two model families in one bench run**, each reader's model in its
  provenance line, and RESULTS.md reporting agreement within a model
  and across models separately. `tests/read_test.sh`'s pattern, with
  two fake models bound in turn at `/mnt/llm`.
- **A verdict written into a corpus file by hand is not read.**
  `ledger` rebuilt ignores it; `corpus/stale` names it if its id is
  gone.
- **The host-command reader's provenance says `confined=none`.** Done,
  and then moot: the host-command reader is gone.
- **Decoding settings in the provenance line.** Done; to be
  round-tripped through `read`'s kept-reading lookup when that is
  built.
- **A reader cannot open `/net`, the corpus directory, another
  reading, or `answers`.** Done, and tested while a reader could be a
  program inside InferNode. Now a reader is a session at `/mnt/llm`,
  whose server runs in its own name space, so no reader code runs in
  the blinded one: the model sees what it is sent, the instructions and
  the question, and nothing else. The blinding is kept, and is no
  longer tested by a reader that looks.
