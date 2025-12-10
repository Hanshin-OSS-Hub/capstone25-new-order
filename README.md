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
- **외부 서비스**
  - 네이버 지도 API
- **협업 & 버전 관리**
  - Git, GitHub

---

## 5. 디렉토리 구조

※ 현재 구조 기준 예시입니다. 이후 `frontend/`, `backend/`로 나눌 예정입니다.

```text
capstone25-new-order/
  android/
  ios/
  lib/
  web/
  test/
  pubspec.yaml
  pubspec.lock
  app.py              # Flask 진입점
  config.py
  jwt_config.py
  jwt_middleware.py
  jwt_utils.py
  models.py
  JWT/
  templates/
  README.md
  .gitignore


