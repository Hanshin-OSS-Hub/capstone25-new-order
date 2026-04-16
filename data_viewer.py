import sqlite3
import json
import csv

def view_sqlite():
    """SQLite DB 내용 확인"""
    conn = sqlite3.connect('stores.db')
    cursor = conn.cursor()
    
    # 전체 개수
    cursor.execute("SELECT COUNT(*) FROM stores")
    total = cursor.fetchone()[0]
    print(f"\n📊 SQLite DB: 총 {total}개 매장")
    
    # 매장 목록
    cursor.execute("SELECT id, name, address, phone, location_type, distance FROM stores LIMIT 20")
    rows = cursor.fetchall()
    
    print("\n📋 매장 목록 (20개):")
    print("-" * 80)
    for row in rows:
        print(f"  [{row[0]}] {row[1]}")
        print(f"       주소: {row[2]}")
        print(f"       전화: {row[3] if row[3] else '정보없음'}")
        print(f"       위치: {row[4]}, 거리: {row[5]}km")
        print()
    
    conn.close()

def view_json():
    """JSON 파일 내용 확인"""
    with open('stores_data.json', 'r', encoding='utf-8') as f:
        stores = json.load(f)
    
    print(f"\n📊 JSON 파일: 총 {len(stores)}개 매장")
    print("\n📋 매장 목록 (10개):")
    print("-" * 60)
    for store in stores[:10]:
        print(f"  이름: {store['name']}")
        print(f"  주소: {store['address']}")
        print(f"  전화: {store['phone'] if store['phone'] else '정보없음'}")
        print(f"  거리: {store['distance']}km")
        print()

def view_csv():
    """CSV 파일 내용 확인"""
    with open('stores_data.csv', 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        stores = list(reader)
    
    print(f"\n📊 CSV 파일: 총 {len(stores)}개 매장")
    print("\n📋 매장 목록 (10개):")
    print("-" * 60)
    for store in stores[:10]:
        print(f"  이름: {store['name']}")
        print(f"  주소: {store['address']}")
        print(f"  전화: {store['phone'] if store['phone'] else '정보없음'}")
        print(f"  거리: {store['distance']}km")
        print()

def search_stores(keyword):
    """매장 검색"""
    conn = sqlite3.connect('stores.db')
    cursor = conn.cursor()
    
    cursor.execute('''
        SELECT name, address, phone, location_type, distance 
        FROM stores 
        WHERE name LIKE ? OR address LIKE ?
        LIMIT 20
    ''', (f'%{keyword}%', f'%{keyword}%'))
    
    rows = cursor.fetchall()
    conn.close()
    
    print(f"\n🔍 '{keyword}' 검색 결과: {len(rows)}개")
    print("-" * 60)
    for row in rows:
        print(f"  {row[0]} - {row[1]}")
        print(f"    전화: {row[2] if row[2] else '정보없음'}, 위치: {row[3]}, 거리: {row[4]}km")
        print()

if __name__ == "__main__":
    print("="*50)
    print("📁 저장된 데이터 확인")
    print("="*50)
    
    view_sqlite()
    # view_json()
    # view_csv()
    
    # 검색 예시
    search_stores("순대")