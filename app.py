from flask import Flask, request, jsonify
from jwt_utils import create_jwt
from jwt_middleware import token_required

app = Flask(__name__)

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    user_id = data.get("user_id")

    token = create_jwt(user_id)
    return jsonify({"token": token})


@app.route("/profile", methods=["GET"])
@token_required
def profile():
    return jsonify({"msg": f"hello user {request.user_id}"})


if __name__ == "__main__":
    app.run(debug=True)
