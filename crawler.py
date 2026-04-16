import os
import requests
import sqlite3
import math
import re
import time
import json
import csv
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

NAVER_CLIENT_ID = os.getenv("NAVER_CLIENT_ID")
NAVER_CLIENT_SECRET = os.getenv("NAVER_CLIENT_SECRET")

# ============================================
# 다양한 검색어 조합 (최대한 많은 매장 수집)
# ============================================
SEARCH_QUERIES = [
    # 병점역 관련
    {"name": "병점역", "lat": 37.2075, "lng": 127.0336, "queries": [
        "병점역 맛집", "병점역 음식점", "병점역 식당", "병점역 회식", "병점역 데이트",
        "병점동 맛집", "병점동 음식점", "병점 맛집", "병점 음식점", "병점 식당",
        "병점역 한식", "병점역 일식", "병점역 중식", "병점역 양식", "병점역 카페",
        "병점역 치킨", "병점역 피자", "병점역 족발", "병점역 보쌈", "병점역 회",
        "병점역 분식", "병점역 고기집", "병점역 해산물", "병점역 짜장면", "병점역 냉면",
        "병점역 김밥", "병점역 떡볶이", "병점역 순대국", "병점역 갈비", "병점역 삼겹살"
    ]},
    # 수원역 관련
    {"name": "수원역", "lat": 37.2668, "lng": 126.9995, "queries": [
        "수원역 맛집", "수원역 음식점", "수원역 식당", "수원역 회식", "수원역 데이트",
        "수원역 한식", "수원역 일식", "수원역 중식", "수원역 양식", "수원역 카페",
        "수원역 치킨", "수원역 피자", "수원역 족발", "수원 갈비", "수원 맛집",
        "수원역 야시장", "수원역 먹자골목", "수원역 맥주", "수원역 혼밥", "수원역 분식",
        "수원역 고기집", "수원역 해산물", "수원역 짜장면", "수원역 냉면", "수원역 김밥",
        "수원역 떡볶이", "수원역 순대국", "수원역 삼겹살", "수원역 보쌈", "수원역 회"
    ]},
    # 한신대/오산 관련
    {"name": "한신대", "lat": 37.1536, "lng": 127.0452, "queries": [
        "오산 맛집", "오산 음식점", "오산 식당", "오산시 맛집", "오산대 맛집",
        "오산 맛집 추천", "오산 맛집 베스트", "오산 데이트 맛집", "오산 회식 장소",
        "한신대학교 맛집", "한신대 앞 맛집", "세마역 맛집", "오산역 맛집",
        "오산 카페", "오산 한식", "오산 일식", "오산 중식", "오산 양식",
        "오산 분식", "오산 고기집", "오산 치킨", "오산 피자", "오산 족발", "오산 냉면"
    ]}
]

def calculate_distance(lat1, lng1, lat2, lng2):
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlng = math.radians(lng2 - lng1)
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlng/2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    return R * c

def normalize_name(name):
    name = re.sub(r'<[^>]+>', '', name)
    name = re.sub(r'\([^)]*\)', '', name)
    name = re.sub(r'\[[^\]]*\]', '', name)
    name = re.sub(r'\s+', ' ', name).strip()
    return name

def clean_phone(phone):
    """전화번호 정리"""
    if not phone:
        return ""
    # 숫자와 하이픈만 남기고 모두 제거
    phone = re.sub(r'[^0-9-]', '', phone)
    # 연속된 하이픈 제거
    phone = re.sub(r'-+', '-', phone)
    # 앞뒤 하이픈 제거
    phone = phone.strip('-')
    return phone

def crawl_stores():
    """매장 정보 크롤링 (전화번호 포함)"""
    headers = {
        "X-Naver-Client-Id": NAVER_CLIENT_ID,
        "X-Naver-Client-Secret": NAVER_CLIENT_SECRET
    }
    
    all_stores = []
    seen_keys = set()
    
    total_queries = sum(len(location["queries"]) for location in SEARCH_QUERIES)
    print(f"\n📊 총 {total_queries}개 검색어로 크롤링 예정")
    
    query_count = 0
    
    for location in SEARCH_QUERIES:
        print(f"\n📍 {location['name']} 검색 시작...")
        location_count = 0
        
        for query in location["queries"]:
            query_count += 1
            print(f"  [{query_count}/{total_queries}] '{query}' 검색 중...", end=" ")
            
            for start in range(1, 101, 10):
                params = {
                    "query": query,
                    "display": 10,
                    "start": start,
                    "sort": "sim"
                }
                
                try:
                    response = requests.get(
                        "https://openapi.naver.com/v1/search/local.json",
                        headers=headers,
                        params=params,
                        timeout=10
                    )
                    
                    if response.status_code != 200:
                        break
                        
                    data = response.json()
                    items = data.get("items", [])
                    
                    if not items:
                        break
                        
                    for item in items:
                        lat = float(item["mapy"]) / 1e7
                        lng = float(item["mapx"]) / 1e7
                        
                        distance = calculate_distance(location["lat"], location["lng"], lat, lng)
                        
                        if distance <= 3.0:
                            name = normalize_name(item["title"])
                            key = f"{name}_{location['name']}"
                            
                            if key not in seen_keys:
                                seen_keys.add(key)
                                
                                # 전화번호 정리
                                phone = clean_phone(item.get("telephone", ""))
                                
                                store = {
                                    "name": name,
                                    "address": item.get("roadAddress", item.get("address", "")),
                                    "phone": phone,
                                    "category": item.get("category", ""),
                                    "lat": lat,
                                    "lng": lng,
                                    "location_type": location["name"],
                                    "distance": round(distance, 3)
                                }
                                all_stores.append(store)
                                location_count += 1
                    
                    time.sleep(0.2)
                    
                    if len(all_stores) >= 1000:
                        break
                        
                except Exception as e:
                    print(f"오류: {e}")
                    break
            
            print(f"✅ (총 {len(all_stores)}개)")
            time.sleep(0.3)
            
            if len(all_stores) >= 1000:
                print(f"\n⚠️ 목표치(1000개) 도달, 크롤링 중단")
                break
        
        print(f"  📌 {location['name']} 총 {location_count}개 수집")
        
        if len(all_stores) >= 1000:
            break
    
    return all_stores

def save_to_csv(stores, filename="stores_data.csv"):
    with open(filename, 'w', newline='', encoding='utf-8-sig') as csvfile:
        fieldnames = ['name', 'address', 'phone', 'category', 'lat', 'lng', 'location_type', 'distance']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for store in stores:
            writer.writerow(store)
    print(f"✅ CSV 저장: {filename} ({len(stores)}개)")

def save_to_json(stores, filename="stores_data.json"):
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(stores, f, ensure_ascii=False, indent=2)
    print(f"✅ JSON 저장: {filename} ({len(stores)}개)")

def save_to_sqlite(stores, db_name="stores.db"):
    conn = sqlite3.connect(db_name)
    cursor = conn.cursor()
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS stores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            address TEXT,
            phone TEXT,
            category TEXT,
            lat REAL,
            lng REAL,
            location_type TEXT,
            distance REAL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_location ON stores(location_type)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_distance ON stores(distance)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_phone ON stores(phone)')
    
    cursor.execute('DELETE FROM stores')
    
    for store in stores:
        cursor.execute('''
            INSERT INTO stores (name, address, phone, category, lat, lng, location_type, distance)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            store['name'], store['address'], store['phone'],
            store['category'], store['lat'], store['lng'],
            store['location_type'], store['distance']
        ))
    
    conn.commit()
    conn.close()
    print(f"✅ SQLite 저장: {db_name} ({len(stores)}개)")

def show_stats(stores):
    print("\n" + "="*50)
    print("📊 수집 통계")
    print("="*50)
    print(f"🏪 전체 매장: {len(stores)}개")
    
    phone_count = len([s for s in stores if s['phone']])
    print(f"📞 전화번호 있음: {phone_count}개 ({phone_count/len(stores)*100:.1f}%)")
    
    location_count = {}
    for store in stores:
        loc = store['location_type']
        location_count[loc] = location_count.get(loc, 0) + 1
    
    print("\n📍 위치별 매장 수:")
    for loc, count in location_count.items():
        print(f"   - {loc}: {count}개")
    
    category_count = {}
    for store in stores:
        cat = store['category'].split('>')[0].strip() if store['category'] else "기타"
        category_count[cat] = category_count.get(cat, 0) + 1
    
    print("\n🍽️ 카테고리 TOP 10:")
    sorted_cats = sorted(category_count.items(), key=lambda x: x[1], reverse=True)[:10]
    for cat, count in sorted_cats:
        print(f"   - {cat}: {count}개")
    
    # 전화번호 있는 매장 예시
    stores_with_phone = [s for s in stores if s['phone']]
    if stores_with_phone:
        print("\n📞 전화번호 있는 매장 예시:")
        for store in stores_with_phone[:5]:
            print(f"   - {store['name']}: {store['phone']}")

def main():
    print("="*50)
    print("🚀 매장 정보 크롤링 시작 (전화번호 포함)")
    print("="*50)
    
    if not NAVER_CLIENT_ID or not NAVER_CLIENT_SECRET:
        print("❌ API 키가 없습니다.")
        return
    
    start_time = time.time()
    
    stores = crawl_stores()
    
    elapsed = time.time() - start_time
    print(f"\n⏱️ 크롤링 시간: {elapsed:.1f}초")
    
    if not stores:
        print("❌ 수집된 매장이 없습니다. API 키를 확인하세요.")
        return
    
    save_to_csv(stores)
    save_to_json(stores)
    save_to_sqlite(stores)
    show_stats(stores)
    
    print("\n✅ 크롤링 완료!")

if __name__ == "__main__":
    main()