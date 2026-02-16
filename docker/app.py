from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def hello():
    return {
        "message": "Hello from Docker!",
        "user": os.getenv("USER", "unknown")
    }

@app.route("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
