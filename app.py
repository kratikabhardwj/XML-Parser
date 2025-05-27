from flask import Flask, request, render_template
import subprocess
import os

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/", methods=["GET", "POST"])
def index():
    result = ""
    if request.method == "POST":
        file = request.files["xmlfile"]
        if file:
            print(f"Received file: {file.filename}")
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
            file.save(filepath)
            print(f"Saved to: {filepath}")

            try:
                output = subprocess.check_output(
                    ["./run_parser.sh", file.filename],
                    stderr=subprocess.STDOUT
                )
                result = output.decode()
                print("Parser output:\n", result)
            except subprocess.CalledProcessError as e:
                result = "Error:\n" + e.output.decode()
                print("Parser error:\n", result)

    return render_template("webpage.html", output=result)


if __name__ == "__main__":
    app.run(debug=True)
