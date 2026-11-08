# answer.py [-m model] - phil/settle's yes-or-no questions answered by a
# small natural-language-inference model on the host, not a language
# model: given the instructions, a blank line and the question on its
# standard input, it prints yes or no.  It was run as a command in
# place of a model, a way the tools no longer have (they reach a model
# only through /mnt/llm); bench/nlicmp.py runs it on the host.  To
# settle with it again it would be served as an OpenAI-compatible API
# for llmsrv to use.
#
# A situation question ("Suppose "A" and "B" are true and "C" is false.
# Is S2, "...", true then?") is a pair: what is supposed the premise, the
# sentence the hypothesis; yes if the model finds the premise entails it.
# A question whether the argument takes a claim for granted is the text
# (what the instructions' preamble gives) and the claim: yes unless the
# model finds the text contradicts it.  Any other question is not one it
# can read: it says so on standard error and answers nothing, and settle
# leaves it unanswered.  The model is a cross-encoder trained on NLI
# (cross-encoder/nli-deberta-v3-small by default), fetched once and kept
# by the transformers library.
#
# Measured (bench/RESULTS.md, October 2026): off the shelf it does not
# beat answering every question the same way, and agrees with a large
# model no more than chance.  It is here to be measured and, fine-tuned
# on settle's own questions, measured again; not to be used for settling.
import re, sys

def parse_situation(q):
    m = re.match(r'Suppose (.*?) (?:is|are) true(?: and (.*?) (?:is|are) false)?\. Is (?:.*?), "(.*)", true then\?', q, re.S)
    if not m:
        m2 = re.match(r'Suppose (.*?) (?:is|are) false\. Is (?:.*?), "(.*)", true then\?', q, re.S)
        if not m2:
            return None
        return [], quoted(m2.group(1)), m2.group(2)
    return quoted(m.group(1)), quoted(m.group(2) or ''), m.group(3)

def quoted(s):
    return [x.replace('""', '"') for x in re.findall(r'"((?:[^"]|"")*)"', s)]

def sentence(s):
    s = re.sub(r'^\d+:\s*', '', s.strip())
    return s if s.endswith(('.', '?', '!')) else s + '.'

def main():
    model = 'cross-encoder/nli-deberta-v3-small'
    a = sys.argv[1:]
    if a[:1] == ['-m'] and len(a) > 1:
        model = a[1]
    text = sys.stdin.read()
    # the instructions, a blank line, then what settle sent: a preamble
    # (the document's sentences) and the question, its last paragraph
    paras = [p.strip() for p in re.split(r'\n\s*\n', text) if p.strip()]
    q = paras[-1] if paras else ''
    pre = '\n'.join(paras[1:-1])
    import torch
    from transformers import AutoTokenizer, AutoModelForSequenceClassification
    tok = AutoTokenizer.from_pretrained(model)
    nli = AutoModelForSequenceClassification.from_pretrained(model)
    labels = {v.lower(): k for k, v in nli.config.id2label.items()}
    def probs(p, h):
        x = tok(p, h, return_tensors='pt', truncation=True, max_length=512)
        with torch.no_grad():
            return torch.softmax(nli(**x).logits[0], -1).tolist()
    s = parse_situation(q)
    if s is not None:
        true, false, hyp = s
        premise = ' '.join(sentence(t) for t in true) + ' ' + ' '.join('It is not the case that ' + sentence(f) for f in false)
        pr = probs(premise.strip(), sentence(hyp))
        print('yes' if pr[labels['entailment']] == max(pr) else 'no')
        return
    m = re.search(r'take this for granted, whether or not it says so: "(.*)"\?', q, re.S)
    if m:
        claim = sentence(m.group(1))
        body = re.sub(r'^\s*S?\d+:\s*', '', pre, flags=re.M)
        pr = probs(body[-2000:], claim)
        print('no' if pr[labels['contradiction']] == max(pr) else 'yes')
        return
    sys.stderr.write('answer.py: not a question it can read\n')

if __name__ == '__main__':
    main()
