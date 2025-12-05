import jwt
import datetime
from jwt_config import SECRET_KEY, ACCESS_TOKEN_EXPIRE_HOURS, ALGORITHM

def create_jwt(user_id):
    payload = {
        "user_id": user_id,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=ACCESS_TOKEN_EXPIRE_HOURS)
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    return token


def decode_jwt(token):
    return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
