# clean_duplicates.py (pandas 없이 실행 가능)
import csv
import re
from collections import defaultdict

print("="*50)
print("데이터 정리 시작 (네이버 우선, 본점 우선)")
print("="*50)

# ============================================
# 1. CSV 파일 읽기
# ============================================
def read_csv(filename):
    stores = []
    with open(filename, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            stores.append(row)
    return stores

def write_csv(stores, filename):
    if not stores:
        print("저장할 데이터가 없습니다.")
        return
    with open(filename, 'w', newline='', encoding='utf-8-sig') as f:
        fieldnames = stores[0].keys()
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(stores)
    print(f"저장 완료: {filename} ({len(stores)}개)")

# CSV 파일 읽기
try:
    stores = read_csv('stores_data.csv')
    print(f"정리 전 매장 수: {len(stores)}개")
except FileNotFoundError:
    print("stores_data.csv 파일이 없습니다. 먼저 crawler.py를 실행하세요.")
    exit()

# ============================================
# 2. 같은 이름이 있으면 naver 우선 (kakao 삭제)
# ============================================
def is_branch(name):
    """지점명 패턴 확인"""
    branch_patterns = [
        r'점$',           # OO점
        r'지점$',         # OO지점
        r'[0-9]+호점$',   # 1호점, 2호점
        r'[가-힣]+점$',   # 수원점, 병점점
        r'Branch$',       # 영문 Branch
    ]
    for pattern in branch_patterns:
        if re.search(pattern, name):
            return True
    return False

def is_main_store(name):
    """본점인지 확인"""
    main_patterns = [
        r'본점$',
        r'본사$',
        r'직영점$',
        r'\(본점\)$',
    ]
    for pattern in main_patterns:
        if re.search(pattern, name):
            return True
    return False

# 이름별로 그룹화
name_groups = defaultdict(list)
for store in stores:
    name_groups[store['name']].append(store)

# naver 우선 선택
naver_priority_stores = []
for name, group in name_groups.items():
    if len(group) == 1:
        naver_priority_stores.append(group[0])
    else:
        # naver가 있으면 naver만 선택
        naver_stores = [s for s in group if s.get('source') == 'naver']
        if naver_stores:
            naver_priority_stores.append(naver_stores[0])
        else:
            naver_priority_stores.append(group[0])

print(f"네이버 우선 적용 후: {len(naver_priority_stores)}개")

# ============================================
# 3. 본점/지점 구분 (본점만 남기기)
# ============================================
# 이름 정규화 (지점명 패턴 제거)
def normalize_name(name):
    # 지점명 패턴 제거
    name = re.sub(r'점$', '', name)
    name = re.sub(r'지점$', '', name)
    name = re.sub(r'[0-9]+호점$', '', name)
    name = re.sub(r'\([^)]*\)$', '', name)
    return name.strip()

# 정규화된 이름으로 그룹화
normalized_groups = defaultdict(list)
for store in naver_priority_stores:
    norm_name = normalize_name(store['name'])
    normalized_groups[norm_name].append(store)

# 본점 우선 선택
main_priority_stores = []
for norm_name, group in normalized_groups.items():
    if len(group) == 1:
        main_priority_stores.append(group[0])
    else:
        # 본점이 있으면 본점만 선택
        main_stores = [s for s in group if is_main_store(s['name'])]
        if main_stores:
            main_priority_stores.append(main_stores[0])
        else:
            # 본점이 없으면 이름이 가장 짧은 것 (본점 추정) 선택
            shortest = min(group, key=lambda x: len(x['name']))
            main_priority_stores.append(shortest)

print(f"본점 우선 적용 후: {len(main_priority_stores)}개")

# ============================================
# 4. 같은 전화번호 중복 제거
# ============================================
def clean_phone(phone):
    if not phone:
        return ""
    return re.sub(r'[^0-9]', '', phone)

# 전화번호로 그룹화
phone_groups = defaultdict(list)
for store in main_priority_stores:
    phone_clean = clean_phone(store.get('phone', ''))
    phone_groups[phone_clean].append(store)

# 전화번호 중복 제거 (전화번호 있으면 하나만)
phone_dedup_stores = []
for phone, group in phone_groups.items():
    if len(group) == 1 or not phone:
        phone_dedup_stores.extend(group)
    else:
        # 같은 전화번호면 naver 우선, 그 다음 첫 번째 선택
        naver_first = [s for s in group if s.get('source') == 'naver']
        if naver_first:
            phone_dedup_stores.append(naver_first[0])
        else:
            phone_dedup_stores.append(group[0])

print(f"전화번호 중복 제거 후: {len(phone_dedup_stores)}개")

# ============================================
# 5. 이름+주소 중복 최종 제거
# ============================================
def get_key(store):
    return f"{store['name']}_{store['address'][:30] if store.get('address') else ''}"

final_stores = []
seen_keys = set()
for store in phone_dedup_stores:
    key = get_key(store)
    if key not in seen_keys:
        seen_keys.add(key)
        final_stores.append(store)

print(f"이름+주소 중복 제거 후: {len(final_stores)}개")

# ============================================
# 6. 저장
# ============================================
write_csv(final_stores, 'stores_data_cleaned.csv')

# ============================================
# 7. 통계 출력
# ============================================
print("\n" + "="*50)
print("정리 통계")
print("="*50)
print(f"시작: {len(stores)}개")
print(f"네이버 우선: {len(naver_priority_stores)}개")
print(f"본점 우선: {len(main_priority_stores)}개")
print(f"전화번호 중복 제거: {len(phone_dedup_stores)}개")
print(f"최종: {len(final_stores)}개")
print(f"제거된 매장: {len(stores) - len(final_stores)}개")

# source별 통계
source_count = {}
for store in final_stores:
    src = store.get('source', 'unknown')
    source_count[src] = source_count.get(src, 0) + 1
print("\n출처별 매장 수:")
for src, cnt in source_count.items():
    print(f"  {src}: {cnt}개")

print("\n✅ 정리 완료!")
print("저장된 파일: stores_data_cleaned.csv")