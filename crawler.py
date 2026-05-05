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

# ============================================
# API 키 설정
# ============================================
NAVER_CLIENT_ID = os.getenv("NAVER_CLIENT_ID")
NAVER_CLIENT_SECRET = os.getenv("NAVER_CLIENT_SECRET")
KAKAO_REST_API_KEY = os.getenv("KAKAO_REST_API_KEY")

# API 키 디버깅 출력 (실행 시 확인)
print("="*50)
print(" API 키 확인")
print("="*50)
print(f"네이버 ID: {NAVER_CLIENT_ID}")
print(f"네이버 SECRET: {NAVER_CLIENT_SECRET[:5] if NAVER_CLIENT_SECRET else '없음'}...")
print(f"카카오 REST API 키: {KAKAO_REST_API_KEY[:10] if KAKAO_REST_API_KEY else '없음'}...")
print("="*50)

# ============================================
# 검색 설정 (84개 검색어 유지)
# ============================================
SEARCH_QUERIES = [
    {"name": "병점역", "lat": 37.2075, "lng": 127.0336, "queries": [
        "병점역 맛집", "병점역 음식점", "병점역 식당", "병점역 회식", "병점역 데이트",
        "병점동 맛집", "병점동 음식점", "병점 맛집", "병점 음식점", "병점 식당",
        "병점역 한식", "병점역 일식", "병점역 중식", "병점역 양식", "병점역 카페",
        "병점역 치킨", "병점역 피자", "병점역 족발", "병점역 보쌈", "병점역 회",
        "병점역 분식", "병점역 고기집", "병점역 해산물", "병점역 짜장면", "병점역 냉면",
        "병점역 김밥", "병점역 떡볶이", "병점역 순대국", "병점역 갈비", "병점역 삼겹살"
    ]},
    {"name": "수원역", "lat": 37.2668, "lng": 126.9995, "queries": [
        "수원역 맛집", "수원역 음식점", "수원역 식당", "수원역 회식", "수원역 데이트",
        "수원역 한식", "수원역 일식", "수원역 중식", "수원역 양식", "수원역 카페",
        "수원역 치킨", "수원역 피자", "수원역 족발", "수원 갈비", "수원 맛집",
        "수원역 야시장", "수원역 먹자골목", "수원역 맥주", "수원역 혼밥", "수원역 분식",
        "수원역 고기집", "수원역 해산물", "수원역 짜장면", "수원역 냉면", "수원역 김밥",
        "수원역 떡볶이", "수원역 순대국", "수원역 삼겹살", "수원역 보쌈", "수원역 회"
    ]},
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
    if not phone:
        return ""
    phone = re.sub(r'[^0-9-]', '', phone)
    phone = re.sub(r'-+', '-', phone)
    phone = phone.strip('-')
    return phone

# ============================================
# 1. 네이버 API 크롤링
# ============================================
def crawl_naver(location, query):
    headers = {
        "X-Naver-Client-Id": NAVER_CLIENT_ID,
        "X-Naver-Client-Secret": NAVER_CLIENT_SECRET
    }
    
    stores = []
    
    for start in range(1, 51, 10):
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
                    phone = clean_phone(item.get("telephone", ""))
                    
                    store = {
                        "name": name,
                        "address": item.get("roadAddress", item.get("address", "")),
                        "phone": phone,
                        "category": item.get("category", ""),
                        "lat": lat,
                        "lng": lng,
                        "location_type": location["name"],
                        "distance": round(distance, 3),
                        "source": "naver"
                    }
                    stores.append(store)
            
            time.sleep(0.2)
            
        except Exception as e:
            break
    
    return stores

# ============================================
# 2. 카카오 API 크롤링 (수정됨 - 오류 상세 출력)
# ============================================
def crawl_kakao(location, query):
    """카카오 API로 매장 검색 (전화번호 제공률 높음)"""
    if not KAKAO_REST_API_KEY:
        return []
    
    headers = {
        "Authorization": f"KakaoAK {KAKAO_REST_API_KEY}"
    }
    
    stores = []
    
    params = {
        "query": query,
        "x": location["lng"],
        "y": location["lat"],
        "radius": 3000,
        "size": 15
    }
    
    try:
        response = requests.get(
            "https://dapi.kakao.com/v2/local/search/keyword.json",
            headers=headers,
            params=params,
            timeout=10
        )
        
        # 디버깅: 응답 코드 출력
        if response.status_code != 200:
            print(f"\n     [카카오]  응답 코드: {response.status_code}")
            if response.status_code == 401:
                print(f"     [카카오]  인증 실패! REST API 키를 확인하세요.")
                print(f"     [카카오] 현재 사용 중인 키: {KAKAO_REST_API_KEY[:15]}...")
            return stores
        
        data = response.json()
        items = data.get("documents", [])
        
        for item in items:
            lat = float(item["y"])
            lng = float(item["x"])
            
            distance = calculate_distance(location["lat"], location["lng"], lat, lng)
            
            if distance <= 3.0:
                phone = clean_phone(item.get("phone", ""))
                
                store = {
                    "name": normalize_name(item["place_name"]),
                    "address": item.get("road_address_name", item.get("address_name", "")),
                    "phone": phone,
                    "category": item.get("category_name", ""),
                    "lat": lat,
                    "lng": lng,
                    "location_type": location["name"],
                    "distance": round(distance, 3),
                    "source": "kakao"
                }
                stores.append(store)
        
        time.sleep(0.3)
        
    except Exception as e:
        print(f"    카카오 오류: {e}")
    
    return stores

# ============================================
# 3. 통합 크롤링
# ============================================
def crawl_stores():
    all_stores = []
    seen_keys = set()
    
    total_queries = sum(len(location["queries"]) for location in SEARCH_QUERIES)
    print(f"\n 총 {total_queries}개 검색어로 크롤링 예정")
    
    query_count = 0
    naver_total = 0
    kakao_total = 0
    
    for location in SEARCH_QUERIES:
        print(f"\n {location['name']} 검색 시작...")
        
        for query in location["queries"]:
            query_count += 1
            print(f"  [{query_count}/{total_queries}] '{query}' 검색 중...")
            
            # 네이버 API
            print(f"     [네이버] 검색 중...", end=" ")
            naver_stores = crawl_naver(location, query)
            naver_total += len(naver_stores)
            print(f" {len(naver_stores)}개 발견")
            
            # 카카오 API
            if KAKAO_REST_API_KEY:
                print(f"     [카카오] 검색 중...", end=" ")
                kakao_stores = crawl_kakao(location, query)
                kakao_total += len(kakao_stores)
                print(f" {len(kakao_stores)}개 발견")
            else:
                kakao_stores = []
            
            # 중복 제거 및 통합
            for store in naver_stores + kakao_stores:
                key = f"{store['name']}_{store['address']}_{store['location_type']}"
                
                if key not in seen_keys:
                    seen_keys.add(key)
                    all_stores.append(store)
            
            print(f"     → 현재 총 {len(all_stores)}개 매장")
            time.sleep(0.3)
    
    if KAKAO_REST_API_KEY:
        print(f"\n 크롤링 결과:")
        print(f"   네이버: {naver_total}개")
        print(f"   카카오: {kakao_total}개")
        print(f"   중복 제거 후: {len(all_stores)}개")
    
    return all_stores

# ============================================
# 4. 저장 함수
# ============================================
def save_to_csv(stores, filename="stores_data.csv"):
    with open(filename, 'w', newline='', encoding='utf-8-sig') as csvfile:
        fieldnames = ['name', 'address', 'phone', 'category', 'lat', 'lng', 'location_type', 'distance', 'source']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for store in stores:
            writer.writerow(store)
    print(f" CSV 저장: {filename} ({len(stores)}개)")

def save_to_json(stores, filename="stores_data.json"):
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(stores, f, ensure_ascii=False, indent=2)
    print(f" JSON 저장: {filename} ({len(stores)}개)")

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
            source TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_location ON stores(location_type)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_phone ON stores(phone)')
    
    cursor.execute('DELETE FROM stores')
    
    for store in stores:
        cursor.execute('''
            INSERT INTO stores (name, address, phone, category, lat, lng, location_type, distance, source)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            store['name'], store['address'], store['phone'],
            store['category'], store['lat'], store['lng'],
            store['location_type'], store['distance'], store['source']
        ))
    
    conn.commit()
    conn.close()
    print(f" SQLite 저장: {db_name} ({len(stores)}개)")

def show_stats(stores):
    print("\n" + "="*50)
    print(" 수집 통계")
    print("="*50)
    print(f" 전체 매장: {len(stores)}개")
    
    # 소스별 통계
    naver_count = len([s for s in stores if s.get('source') == 'naver'])
    kakao_count = len([s for s in stores if s.get('source') == 'kakao'])
    
    # 전화번호 통계
    phone_count = len([s for s in stores if s['phone']])
    naver_phone = len([s for s in stores if s.get('source') == 'naver' and s['phone']])
    kakao_phone = len([s for s in stores if s.get('source') == 'kakao' and s['phone']])
    
    print(f"\n 소스별 매장 수:")
    print(f"   네이버: {naver_count}개")
    if kakao_count > 0:
        print(f"   카카오: {kakao_count}개")
    
    print(f"\n 전화번호 있음:")
    print(f"   전체: {phone_count}개 ({phone_count/len(stores)*100:.1f}%)")
    if naver_count > 0:
        print(f"   네이버: {naver_phone}개 ({naver_phone/naver_count*100:.1f}%)")
    if kakao_count > 0:
        print(f"   카카오: {kakao_phone}개 ({kakao_phone/kakao_count*100:.1f}%)")
    
    # 위치별 통계
    location_count = {}
    for store in stores:
        loc = store['location_type']
        location_count[loc] = location_count.get(loc, 0) + 1
    
    print("\n 위치별 매장 수:")
    for loc, count in location_count.items():
        print(f"   - {loc}: {count}개")
    
    # 전화번호 있는 매장 예시
    stores_with_phone = [s for s in stores if s['phone']]
    if stores_with_phone:
        print("\n 전화번호 있는 매장 예시:")
        for store in stores_with_phone[:10]:
            print(f"   - {store['name']}: {store['phone']} ({store.get('source', 'unknown')})")
    else:
        print("\n 전화번호가 있는 매장이 없습니다.")
        print("   카카오 API 키가 유효한지 확인하세요.")

def main():
    print("="*50)
    print(" 네이버 + 카카오 통합 크롤링")
    print("="*50)
    
    if not NAVER_CLIENT_ID or not NAVER_CLIENT_SECRET:
        print(" 네이버 API 키가 없습니다.")
        return
    
    if KAKAO_REST_API_KEY:
        print(" 카카오 API 키 있음 (전화번호 수집률 향상)")
        print(f"   사용 중인 키: {KAKAO_REST_API_KEY[:15]}...")
    else:
        print(" 카카오 API 키 없음 (네이버 API만 사용)")
        print("   전화번호가 필요하면 .env 파일에 추가하세요:")
        print("   KAKAO_REST_API_KEY=여기에_키_입력")
    
    start_time = time.time()
    
    stores = crawl_stores()
    
    elapsed = time.time() - start_time
    print(f"\n⏱ 크롤링 시간: {elapsed:.1f}초")
    
    if not stores:
        print(" 수집된 매장이 없습니다.")
        return
    
    save_to_csv(stores)
    save_to_json(stores)
    save_to_sqlite(stores)
    show_stats(stores)
    
    print("\n 크롤링 완료!")

if __name__ == "__main__":
    main()