from flask import Flask, render_template
import sqlite3
import os

app = Flask(__name__)
DB_PATH = os.path.join(os.path.dirname(__file__), 'visitors.db')

def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute('CREATE TABLE IF NOT EXISTS counter (id INTEGER PRIMARY KEY, count INTEGER)')
    cur = conn.execute('SELECT count FROM counter WHERE id = 1')
    if cur.fetchone() is None:
        conn.execute('INSERT INTO counter (id, count) VALUES (1, 0)')
    conn.commit()
    conn.close()

init_db()

@app.route('/')
def index():
    conn = sqlite3.connect(DB_PATH)
    conn.execute('UPDATE counter SET count = count + 1 WHERE id = 1')
    conn.commit()
    count = conn.execute('SELECT count FROM counter WHERE id = 1').fetchone()[0]
    conn.close()
    return render_template('index.html', count=count)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)