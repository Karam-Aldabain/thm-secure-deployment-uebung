from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    with open("/data/app.txt", "r") as file:
        content = file.read()
    return f"<p>{content}</p>"


def main():
    app.run(debug=False, use_reloader=False, host="0.0.0.0")


if __name__ == '__main__':
    main()
