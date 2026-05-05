import os
import pymysql
from flask import Flask, request, jsonify, g, url_for
from authlib.integrations.flask_client import OAuth
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)
app.secret_key = os.getenv('JWT_SECRET', 'sungho_secret')

oauth = OAuth(app)
google = oauth.register(
    name='google',
    client_id=os.getenv('GOOGLE_CLIENT_ID'),
    client_secret=os.getenv('GOOGLE_CLIENT_SECRET'),
    access_token_url='https://accounts.google.com/o/oauth2/token',
    authorize_url='https://accounts.google.com/o/oauth2/auth',
    api_base_url='https://www.googleapis.com/oauth2/v1/',
    userinfo_endpoint='https://openidconnect.googleapis.com/v1/userinfo',
    client_kwargs={'scope': 'openid email profile'},
)

def get_db():
    if 'db' not in g:
        g.db = pymysql.connect(
            host='db', user='root', password=os.getenv('DB_PASSWORD'),
            database='auth_db', cursorclass=pymysql.cursors.DictCursor
        )
    return g.db

@app.route('/login/google')
def google_login():
    redirect_uri = url_for('google_callback', _external=True)
    return google.authorize_redirect(redirect_uri)

@app.route('/auth/google/callback')
def google_callback():
    token = google.authorize_access_token()
    user_info = google.get('userinfo').json()
    social_id, email, name = user_info.get('sub'), user_info.get('email'), user_info.get('name')
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE social_id = %s", (social_id,))
    if cursor.fetchone():
        return jsonify({"msg": "로그인 성공"})
    else:
        cursor.execute("INSERT INTO users (email, name, nickname, social_id, provider) VALUES (%s, %s, %s, %s, 'google')", (email, name, name, social_id))
        conn.commit()
        return jsonify({"msg": "가입 성공"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
