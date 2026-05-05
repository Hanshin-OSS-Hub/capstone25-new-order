from flask import Flask, render_template, jsonify, request
import os
import sqlite3
from dotenv import load_dotenv
from flask_cors import CORS

load_dotenv()

app = Flask(__name__)
CORS(app)

def get_stores_from_db(limit=50, offset=0, location_type=None):
    """DB에서 매장 조회 (페이지네이션 지원)"""
    conn = sqlite3.connect('stores.db')
    cursor = conn.cursor()
    
    if location_type:
        cursor.execute('''
            SELECT name, address, phone, category, lat, lng, distance
            FROM stores 
            WHERE location_type = ?
            ORDER BY distance 
            LIMIT ? OFFSET ?
        ''', (location_type, limit, offset))
    else:
        cursor.execute('''
            SELECT name, address, phone, category, lat, lng, distance
            FROM stores 
            ORDER BY distance 
            LIMIT ? OFFSET ?
        ''', (limit, offset))
    
    rows = cursor.fetchall()
    
    # 전체 개수 조회
    if location_type:
        cursor.execute("SELECT COUNT(*) FROM stores WHERE location_type = ?", (location_type,))
    else:
        cursor.execute("SELECT COUNT(*) FROM stores")
    total_count = cursor.fetchone()[0]
    
    conn.close()
    
    stores = []
    for row in rows:
        stores.append({
            "name": row[0],
            "address": row[1] if row[1] else "주소 정보 없음",
            "phone": row[2] if row[2] else "",
            "category": row[3] if row[3] else "일반",
            "lat": row[4],
            "lng": row[5],
            "distance": round(row[6], 2) if row[6] else 0
        })
    
    return stores, total_count

@app.route("/")
def home():
    return render_template("memo.html")

@app.route("/api/stores")
def get_stores():
    """DB에서 매장 정보 반환 (기본 50개)"""
    sort = request.args.get("sort", "sim")
    limit = int(request.args.get("limit", 50))
    location = request.args.get("location", None)
    
    stores, total_count = get_stores_from_db(limit=limit, location_type=location)
    
    # 정렬
    if sort == "distance":
        stores.sort(key=lambda x: x["distance"])
    elif sort == "name":
        stores.sort(key=lambda x: x["name"])
    
    return jsonify({
        "status": "success",
        "count": len(stores),
        "total": total_count,
        "stores": stores
    })

@app.route("/api/stores/all", methods=["GET"])
def get_all_stores():
    """전체 매장 정보 (페이지네이션)"""
    page = int(request.args.get("page", 1))
    limit = int(request.args.get("limit", 100))
    offset = (page - 1) * limit
    
    conn = sqlite3.connect('stores.db')
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM stores")
    total = cursor.fetchone()[0]
    
    cursor.execute('''
        SELECT name, address, phone, category, lat, lng, distance, location_type
        FROM stores 
        ORDER BY distance 
        LIMIT ? OFFSET ?
    ''', (limit, offset))
    
    rows = cursor.fetchall()
    conn.close()
    
    stores = []
    for row in rows:
        stores.append({
            "name": row[0],
            "address": row[1],
            "phone": row[2],
            "category": row[3],
            "lat": row[4],
            "lng": row[5],
            "distance": row[6],
            "location_type": row[7]
        })
    
    return jsonify({
        "status": "success",
        "total": total,
        "page": page,
        "limit": limit,
        "stores": stores
    })

if __name__ == "__main__":
    if os.path.exists('stores.db'):
        conn = sqlite3.connect('stores.db')
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM stores")
        count = cursor.fetchone()[0]
        conn.close()
        print(f"✅ DB 연결 성공 (저장된 매장: {count}개)")
    else:
        print("⚠️ 경고: stores.db 파일이 없습니다. python crawler.py를 실행하세요.")
    
    print("🚀 서버 주소: http://localhost:5000")
    app.run(debug=True)