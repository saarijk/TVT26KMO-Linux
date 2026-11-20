from flask import Flask, render_template
import pymysql
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

DB_CONFIG = {
    'host': '127.0.0.1',
    'user': 'appuser',
    'password': os.environ.get('DB_PASSWORD', ''),
    'database': 'visitor_counter',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor,
}


def init_db():
    conn = pymysql.connect(**DB_CONFIG)
    try:
        with conn.cursor() as cur:
            cur.execute(
                'CREATE TABLE IF NOT EXISTS counter '
                '(id INT PRIMARY KEY, count INT NOT NULL DEFAULT 0)'
            )
            cur.execute('SELECT count FROM counter WHERE id = 1')
            if cur.fetchone() is None:
                cur.execute('INSERT INTO counter (id, count) VALUES (1, 0)')
        conn.commit()
    finally:
        conn.close()


init_db()


@app.route('/')
def index():
    conn = pymysql.connect(**DB_CONFIG)
    try:
        with conn.cursor() as cur:
            cur.execute('UPDATE counter SET count = count + 1 WHERE id = 1')
        conn.commit()
        with conn.cursor() as cur:
            cur.execute('SELECT count FROM counter WHERE id = 1')
            count = cur.fetchone()['count']
    finally:
        conn.close()
    return render_template('index.html', count=count)


if __name__ == '__main__':
    init_db()
    app.run(host='127.0.0.1', port=5000)