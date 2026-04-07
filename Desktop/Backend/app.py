from flask import Flask, request, jsonify, g, url_for
from jwt_utils import create_jwt
from jwt_middleware import token_required
from authlib.integrations.flask_client import OAuth
import pymysql

app = Flask(__name__)
app.secret_key = 'super-secret-key'

db_config = {
    'host': 'db', 
    'user': 'root',
    'password': '1234',
    'db': 'auth_db',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

oauth = OAuth(app)
google = oauth.register(
    name='google',
    client_id='711160363226-7tad2l4ii0064nrluibvl3oe5cp931p4.apps.googleusercontent.com',
    client_secret='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',
    server_metadata_url='https://accounts.google.com/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email profile'},
    id_token_params={'claims_options': {'iss': {'validate': None}}}
)

def get_db():
    if 'db' not in g:
        g.db = pymysql.connect(**db_config)
    return g.db

@app.teardown_appcontext
def close_db(error):
    db = g.pop('db', None)
    if db is not None:
        db.close()

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    if not email or not password:
        return jsonify({"msg": "Missing email or password"}), 400
    conn = get_db()
    cursor = conn.cursor()
    try:
        sql = "INSERT INTO users (email, password) VALUES (%s, %s)"
        cursor.execute(sql, (email, password))
        conn.commit()
        return jsonify({"msg": "user created"}), 201
    except pymysql.err.IntegrityError:
        return jsonify({"msg": "email already exists"}), 400
    except Exception as e:
        return jsonify({"msg": str(e)}), 500

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    conn = get_db()
    cursor = conn.cursor()
    sql = "SELECT * FROM users WHERE email=%s AND password=%s"
    cursor.execute(sql, (email, password))
    user = cursor.fetchone()
    if not user:
        return jsonify({"msg": "invalid credentials"}), 401
    token = create_jwt(user["id"])
    return jsonify({"msg": "login success", "token": token})

@app.route('/login/google')
def google_login():
    redirect_uri = url_for('google_callback', _external=True)
    return google.authorize_redirect(redirect_uri)

@app.route('/login/google/callback')
def google_callback():
    token = google.authorize_access_token()
    user_info = google.get('https://www.googleapis.com/oauth2/v3/userinfo').json()
    email = user_info.get('email')
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()
    if not user:
        cursor.execute("INSERT INTO users (email, password) VALUES (%s, %s)", (email, 'social_login'))
        conn.commit()
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()
    jwt_token = create_jwt(user["id"])
    return jsonify({
        "msg": "google login success",
        "token": jwt_token,
        "email": email
    })

@app.route("/profile", methods=["GET"])
@token_required
def profile():
    return jsonify({
        "msg": "profile data",
        "user_id": g.user_id
    })

@app.route('/')
def home():
    return "<h1>docker is working</h1>"

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True, port=5001)
