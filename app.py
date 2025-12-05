# app.py
from flask import Flask, jsonify, render_template
from models import db, Store
from config import Config
import os

app = Flask(__name__)
app.config.from_object(Config)

# DB 초기화
db.init_app(app)
os.makedirs(app.instance_path, exist_ok=True)

# -----------------------------------------
# 1) index.html 렌더링
# -----------------------------------------
@app.route('/')
def home():
    return render_template('index.html')

# -----------------------------------------
# 2) API – 매장 목록 (이것을 index.html에서 호출)
# -----------------------------------------
@app.route('/api/stores', methods=['GET'])
def get_stores():
    stores = Store.query.all()
    return jsonify([store.to_dict() for store in stores])

# -----------------------------------------
# 3) DB 초기화 커맨드
# -----------------------------------------
@app.cli.command("init-db")
def init_db_command():
    with app.app_context():
        db.drop_all()
        db.create_all()

       # -----------------------------------------
# 3) DB 초기화 커맨드
# -----------------------------------------
@app.cli.command("init-db")
def init_db_command():
    with app.app_context():
        db.drop_all()
        db.create_all()

        stores = [
            Store(
                name="맥도날드 병점역점",
                address="경기도 화성시 병점로 123",
                phone="031-123-4567",
                description="병점역 인근 맥도날드 매장",
                latitude=37.2074,
                longitude=127.0337
            ),
            Store(
                name="스타벅스 병점역점",
                address="경기도 화성시 병점역로 32",
                phone="031-234-5678",
                description="병점역 근처 스타벅스",
                latitude=37.2072,
                longitude=127.0341
            ),
            Store(
                name="이디야 병점점",
                address="경기도 화성시 병점로 45",
                phone="031-345-6789",
                description="병점역 근처 이디야 매장",
                latitude=37.2070,
                longitude=127.0335
            ),
            Store(
                name="투썸플레이스 병점점",
                address="경기도 화성시 병점로 67",
                phone="031-456-7890",
                description="병점역 근처 투썸플레이스",
                latitude=37.2068,
                longitude=127.0340
            ),
            Store(
                name="버거킹 병점점",
                address="경기도 화성시 병점로 89",
                phone="031-567-8901",
                description="병점역 근처 버거킹 매장",
                latitude=37.2066,
                longitude=127.0338
            ),
        ]

        db.session.add_all(stores)
        db.session.commit()
        print("DB 초기화 완료")


# -----------------------------------------
# 4) 실행
# -----------------------------------------
if __name__ == "__main__":
    app.run(debug=True)
