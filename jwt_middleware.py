from functools import wraps
from flask import request, jsonify
import jwt
from jwt_utils import decode_jwt

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None

        if "Authorization" in request.headers:
            parts = request.headers["Authorization"].split(" ")
            if len(parts) == 2 and parts[0] == "Bearer":
                token = parts[1]

        if not token:
            return jsonify({"msg": "Token missing"}), 401

        try:
            data = decode_jwt(token)
            request.user_id = data["user_id"]

        except jwt.ExpiredSignatureError:
            return jsonify({"msg": "Token expired"}), 401

        except jwt.InvalidTokenError:
            return jsonify({"msg": "Invalid token"}), 401

        return f(*args, **kwargs)

    return decorated
