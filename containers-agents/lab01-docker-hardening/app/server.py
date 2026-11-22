from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def home():
    return jsonify(message="lab01-ok", module="containers-k8s-ia")


@app.get("/healthz")
def healthz():
    return jsonify(status="ok")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
