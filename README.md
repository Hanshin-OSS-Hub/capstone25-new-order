# capstone25-new-order

Flutter + Flask 기반 **매장 식사 / 포장 주문 / 원격 결제 통합 주문 앱**  
(한신대학교 캡스톤디자인 2025 – New Order 프로젝트)

---

## 1. 프로젝트 소개

이 프로젝트는 오프라인 매장(카페, 음식점 등)의 **매장 식사 / 포장 주문을 원격으로 결제**할 수 있는 통합 주문 앱입니다.  

스타벅스 사이렌오더처럼 미리 주문·결제를 해두고,  
배달앱처럼 여러 매장을 한 번에 탐색할 수 있도록 하는 것이 목표입니다.

- 사용자는 주변 매장을 지도로 탐색하고,
- 메뉴/식사 방식을 선택한 뒤,
- 앱에서 바로 결제까지 완료합니다.
- 매장 입장 시 별도 주문 없이 음식을 받을 수 있습니다.

---

## 2. 팀원 소개

팀원(Contributors)
- **최우진(팀장)** - UI/UX 디자인, Flutter UI 개발
- **김성호** - Flask 백엔드, 로그인 인증, DB 개발
- **김현진** - Flask 백엔드, 지도 API 기반 설계

---

## 3. 주요 기능

- **홈 화면**
  - 위치 기반 매장 추천
  - 카테고리별 음식(한식, 일식, 치킨, 피자, 단체주문 등)
  - 프로모션/이벤트 배너

- **검색 기능**
  - 가게/메뉴명으로 검색
  - 검색 결과에서 바로 매장 상세/주문 페이지로 이동

- **근처 찾기**
  - 네이버 지도 API 기반 주변 매장 지도 표시
  - 매장 목록 + 지도 마커 연동
  - 사용자 현재 위치 표시

- **단체 주문 예약**
  - 날짜 / 인원 / 시간 선택
  - 조건에 맞는 단체 주문 가능 매장 리스트 제공(추가 예정)

- **찜 / 주문 내역 / 마이페이지**
  - 찜한 매장 관리
  - JWT 기반 로그인 후 내 주문 내역 조회
  - 장바구니, 결제 수단 선택 UI

---

## 4. 기술 스택

- **Frontend**
  - Flutter (Dart)
  - Android Studio / VS Code
- **Backend**
  - Python, Flask
  - JWT 기반 인증
  - 현재는 SQLite(개발용) 사용 중, 배포는 MySQL 예정
- **외부 서비스**
  - 네이버 지도 API
- **협업 & 버전 관리**
  - Git, GitHub

---

## 5. 실행 방법

### 5-1. Flutter 앱 실행

```bash
# 프로젝트 클론
git clone https://github.com/Hanshin-OSS-Hub/capstone25-new-order.git
cd capstone25-new-order

# 패키지 설치
flutter pub get

# 에뮬레이터 또는 실제 기기에서 실행
flutter run

### Flask 백엔드 서버 실행

cd server

# 가상환경 생성 (선택)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 패키지 설치
pip install -r requirements.txt

# 서버 실행
python app.py

---

## 6. 디렉토리 구조

※ 현재 구조 기준 예시입니다. 이후 `frontend/`, `backend/`로 나눌 예정입니다.

capstone25-new-order/
├─ lib/                     # Flutter 앱 소스 코드
│  ├─ main.dart
│  ├─ screens/              # 화면 단위 위젯들
│  ├─ widgets/              # 공용 UI 컴포넌트
│  └─ models/               # 데이터 모델
│
├─ assets/                  # 이미지, 아이콘 등
│
├─ android/                 # Android 빌드 관련
├─ ios/                     # iOS 빌드 관련
├─ pubspec.yaml
│
├─ server/                  # Flask 백엔드 서버
│  ├─ app.py                # Flask 엔트리 포인트
│  ├─ config.py             # DB/환경 설정
│  ├─ models.py             # DB 모델
│  ├─ requirements.txt      # Python 패키지 목록
│  └─ templates/
│     └─ index.html         # 네이버 지도 WebView 페이지
│
├─ docs/                    # 보고서, 시스템 구성도, 스크린샷
│
└─ README.md

---


