# fakellm.py port log [reply] - an OpenAI-compatible chat endpoint
# that answers every request with one fixed reply, the contents of the
# file reply if given, and logs what it was sent.  A reply file with
# lines of ===== between replies gives them in turn, one a request,
# the last again once they run out.  review_test.sh and
# rewrite_test.sh point llmsrv at it, so wwb/review and wwb/rewrite can
# be tested with no model and no network.
import json, sys
from http.server import BaseHTTPRequestHandler, HTTPServer
log = open(sys.argv[2], 'w')
served = 0
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps({"data":[{"id":"fake-model"}]}).encode()
        self.send_response(200); self.send_header('Content-Type','application/json'); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
    def do_POST(self):
        n = int(self.headers.get('Content-Length', 0)); req = json.loads(self.rfile.read(n))
        # only a chat is a question: llmclient also asks Ollama's
        # /api/show for a model's context length, which spends no reply
        if not self.path.endswith('/chat/completions'):
            body = b'{}'
            self.send_response(404); self.send_header('Content-Type','application/json'); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
            return
        log.write(json.dumps(req, indent=1)+"\n"); log.flush()
        msgs = req.get("messages", [])
        user = [m for m in msgs if m.get("role")=="user"]
        content = user[-1]["content"] if user else ""
        if isinstance(content, list): content = " ".join(c.get("text","") for c in content)
        reply = "data/sample.md:22: the bracket opened here is never closed, so the reasons are not given."
        if len(sys.argv) > 3:
            replies = open(sys.argv[3], encoding='utf-8').read().split("\n=====\n")
            global served
            reply = replies[min(served, len(replies)-1)]
            served += 1
        if req.get("stream"):
            self.send_response(200); self.send_header('Content-Type','text/event-stream'); self.end_headers()
            chunk = {"choices":[{"delta":{"content":reply},"index":0}]}
            self.wfile.write(("data: "+json.dumps(chunk)+"\n\n").encode())
            done = {"choices":[{"delta":{},"finish_reason":"stop","index":0}],"usage":{"prompt_tokens":10,"completion_tokens":5}}
            self.wfile.write(("data: "+json.dumps(done)+"\n\ndata: [DONE]\n\n").encode())
        else:
            body = json.dumps({"choices":[{"message":{"role":"assistant","content":reply},"finish_reason":"stop"}],"usage":{"prompt_tokens":10,"completion_tokens":5}}).encode()
            self.send_response(200); self.send_header('Content-Type','application/json'); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
    def log_message(self, *a): pass
HTTPServer(('127.0.0.1', int(sys.argv[1])), H).serve_forever()
