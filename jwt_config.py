import os

SECRET_KEY = os.getenv("JWT_SECRET_KEY", "your_secret_key")
ACCESS_TOKEN_EXPIRE_HOURS = 2
ALGORITHM = "HS256"
