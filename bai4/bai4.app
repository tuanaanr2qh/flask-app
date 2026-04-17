import os
from flask import Flask, render_template_string, request, redirect, url_for
from werkzeug.utils import secure_filename

app = Flask(__name__)
UPLOAD_FOLDER = "static/uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

students = []

template = """
<!DOCTYPE html>
<html>
<head>
    <title>Quản lý sinh viên</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        table { border-collapse: collapse; width: 80%; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
        img { width: 60px; height: 60px; object-fit: cover; border-radius: 50%; }
    </style>
</head>
<body>
    <h1>Quản lý sinh viên</h1>
    <form method="POST" action="{{ url_for('add_student') }}" enctype="multipart/form-data">
        <input type="text" name="name" placeholder="Tên sinh viên" required>
        <input type="number" name="score" placeholder="Điểm số" required>
        <input type="file" name="photo" accept="image/*" required>
        <button type="submit">Thêm</button>
    </form>
    <br>
    <table>
        <tr>
            <th>ID</th><th>Ảnh</th><th>Tên</th><th>Điểm</th><th>Hành động</th>
        </tr>
        {% for s in students %}
        <tr>
            <td>{{ loop.index }}</td>
            <td><img src="{{ url_for('static', filename='uploads/' + s['photo']) }}"></td>
            <td>{{ s['name'] }}</td>
            <td>{{ s['score'] }}</td>
            <td>
                <a href="{{ url_for('edit_student', idx=loop.index0) }}">Sửa</a> |
                <a href="{{ url_for('delete_student', idx=loop.index0) }}">Xóa</a>
            </td>
        </tr>
        {% endfor %}
    </table>
</body>
</html>
"""

@app.route("/")
def index():
    return render_template_string(template, students=students)

@app.route("/add", methods=["POST"])
def add_student():
    name = request.form["name"]
    score = request.form["score"]
    photo_file = request.files["photo"]
    filename = secure_filename(photo_file.filename)
    photo_file.save(os.path.join(app.config["UPLOAD_FOLDER"], filename))
    students.append({"name": name, "score": score, "photo": filename})
    return redirect(url_for("index"))

@app.route("/delete/<int:idx>")
def delete_student(idx):
    if 0 <= idx < len(students):
        students.pop(idx)
    return redirect(url_for("index"))

@app.route("/edit/<int:idx>", methods=["GET", "POST"])
def edit_student(idx):
    if request.method == "POST":
        students[idx]["name"] = request.form["name"]
        students[idx]["score"] = request.form["score"]
        photo_file = request.files.get("photo")
        if photo_file and photo_file.filename:
            filename = secure_filename(photo_file.filename)
            photo_file.save(os.path.join(app.config["UPLOAD_FOLDER"], filename))
            students[idx]["photo"] = filename
        return redirect(url_for("index"))
    else:
        s = students[idx]
        return f"""
        <h2>Sửa sinh viên</h2>
        <form method="POST" enctype="multipart/form-data">
            <input type="text" name="name" value="{s['name']}" required>
            <input type="number" name="score" value="{s['score']}" required>
            <input type="file" name="photo" accept="image/*">
            <button type="submit">Cập nhật</button>
        </form>
        """

if __name__ == "__main__":
    app.run(debug=True)


