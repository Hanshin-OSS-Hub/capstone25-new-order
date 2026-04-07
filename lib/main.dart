import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mypage_screen.dart';
import 'store_map_webview_screen.dart';
import 'dart:async';

// ---------------------- 장바구니 전역 데이터 ----------------------

class CartItem {
  final String name;
  final int price;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}

// 앱 전체에서 공유하는 장바구니
final List<CartItem> cartItems = [];


void main() {
  runApp(const NewOrderApp());
}

class NewOrderApp extends StatelessWidget {
  const NewOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '원격 주문 앱',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C5CD4)),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (_) => const HomeScreen(),
        '/near': (_) => const NearSearchPage(),
        '/favorites': (_) => const FavoritesPage(),
        '/orders': (_) => const OrderHistoryPage(),
        '/mypage': (_) => const MyPageScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const _LocationSelector(),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchBar(),
                SizedBox(height: 16),
                _PromotionBannerCarousel(),
                SizedBox(height: 16),
                _TopMenuTabs(),
                SizedBox(height: 16),
                _CategoryGrid(),
                SizedBox(height: 24),
                _ShortcutCardsRow(),
                SizedBox(height: 24),
                _MembershipBanner(),
                SizedBox(height: 24),
                _RestaurantListPlaceholder(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

/// ------------------------ 상단 위치 선택 ------------------------

class _LocationSelector extends StatelessWidget {
  const _LocationSelector();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
        const SizedBox(width: 4),
        const Text(
          '한신대학교',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_drop_down, color: Colors.black),
      ],
    );
  }
}

/// ------------------------ 검색 바 ------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ✅ 수정된 부분: 검색바 전체를 탭하면 검색 UI 열기
      onTap: () {
        showSearch(
          context: context,
          delegate: RestaurantSearchDelegate(), // ✅ 아래에서 새로 만드는 SearchDelegate
        );
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: const [
            Icon(Icons.search, color: Color(0xFF828282)),
            SizedBox(width: 8),
            // ✅ (문구만 약간 다듬고 그대로 둠 – 실제 검색은 onTap에서 처리)
            Text(
              '가게, 메뉴 검색',
              style: TextStyle(
                color: Color(0xFF828282),
                fontSize: 16,
              ),
            ),
            Spacer(),

          ],
        ),
      ),
    );
  }
}

// 검색에 사용할 식당 데이터 모델
class _SearchRestaurant {
  final String name;         // 식당 이름
  final String description;  // 한 줄 설명
  final String category;     // 카테고리 (버거, 한식, 카페 등)
  final List<String> tags;   // 검색용 태그 (버거, 햄버거, 패스트푸드 등)

  const _SearchRestaurant({
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
  });
}

// 검색 결과에서 사용될 식당 카드 UI
class _SearchResultCard extends StatelessWidget {
  final _SearchRestaurant store;

  const _SearchResultCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (store.name == '맛있는 버거집') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BurgerOrderTypePage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '"${store.name}" 상세 페이지는 아직 준비 중입니다.',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 왼쪽 썸네일 (placeholder)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.storefront,
                color: Color(0xFF727784),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // 오른쪽 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF727784),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB0B3BA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ✅ 새로 추가된 클래스: 검색 기능 구현용 SearchDelegate
class RestaurantSearchDelegate extends SearchDelegate<String> {
  // 🔹 검색 대상이 되는 식당 데이터들
  final List<_SearchRestaurant> _restaurants = const [
    _SearchRestaurant(
      name: '맛있는 버거집',
      description: '',
      category: '버거',
      tags: ['버거', '햄버거', '패스트푸드'],
    ),
    _SearchRestaurant(
      name: '우리 동네 덮밥집',
      description: '',
      category: '한식',
      tags: ['덮밥', '한식', '밥집'],
    ),
    _SearchRestaurant(
      name: '블루밍가든',
      description: '',
      category: '양식',
      tags: ['파스타', '스테이크', '양식'],
    ),
    _SearchRestaurant(
      name: '한식당 한그릇',
      description: '',
      category: '한식',
      tags: ['한식', '정식', '백반'],
    ),
    _SearchRestaurant(
      name: '로컬 커피',
      description: '',
      category: '카페',
      tags: ['커피', '디저트', '카페'],
    ),
  ];

  @override
  String get searchFieldLabel => '가게, 메뉴 검색';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  // 🔹 결과 화면: "버거" or "맛있는 버거집" 같은 검색어에 맞는 식당 카드들
  @override
  Widget buildResults(BuildContext context) {
    final lowerQuery = query.toLowerCase();

    // 이름 / 카테고리 / 태그 중 하나라도 검색어를 포함하면 결과로 인정
    final results = _restaurants.where((store) {
      final inName = store.name.toLowerCase().contains(lowerQuery);
      final inCategory = store.category.toLowerCase().contains(lowerQuery);
      final inTags = store.tags
          .any((tag) => tag.toLowerCase().contains(lowerQuery));
      return inName || inCategory || inTags;
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          '"$query" 에 대한 검색 결과가 없습니다.',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final store = results[index];
        return _SearchResultCard(store: store);
      },
    );
  }

  // 🔹 추천/자동완성 영역: 검색어에 맞는 식당들을 미리 보여주기
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      // 검색어 없을 때: 전체 식당을 히스토리처럼 쭉 보여줌
      return ListView(
        children: _restaurants.map((store) {
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(store.name),
            subtitle: Text(store.description),
            onTap: () {
              // 어떤 식당이든: 검색어만 바꾸고 결과 화면으로 이동
              query = store.name;
              showResults(context);
            },
          );
        }).toList(),
      );
    }

    final lowerQuery = query.toLowerCase();
    final suggestions = _restaurants.where((store) {
      final inName = store.name.toLowerCase().contains(lowerQuery);
      final inCategory = store.category.toLowerCase().contains(lowerQuery);
      final inTags = store.tags
          .any((tag) => tag.toLowerCase().contains(lowerQuery));
      return inName || inCategory || inTags;
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final store = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(store.name),
          subtitle: Text(store.description),
          onTap: () {
            // 추천에서 선택해도 무조건 결과 화면으로
            query = store.name;
            showResults(context);
          },
        );
      },
    );
  }
}


/// ------------------------ 프로모션 배너 ------------------------

class _PromotionBannerCarousel extends StatefulWidget {
  const _PromotionBannerCarousel({super.key});

  @override
  State<_PromotionBannerCarousel> createState() => _PromotionBannerCarouselState();
}

class _PromotionBannerCarouselState extends State<_PromotionBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // 배너에 들어갈 데이터들 (문구 + 색)
  final List<_BannerData> _banners = [
    // 1번 배너: 신규가입 배너
    const _BannerData(
      title: '지금 신규가입하면 모든 메뉴 5,000원 할인!',
      subtitle: '가입하고 혜택받기 >',
      colors: [
        Color(0xFF45B5AA),
        Color(0xFF7BC4C4),
      ],
    ),
    // 2번 배너: 연말 회식 / 단체주문 배너
    const _BannerData(
      title: '연말 회식 장소 찾아야 할 땐?',
      subtitle: '단체주문 바로 가기 >',
      colors: [
        Color(0xFFDD4124),
        Color(0xFFFFA41B),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    // 4초마다 자동으로 다음 배너로 이동
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: banner.colors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final List<Color> colors;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.colors,
  });
}


/// ------------------------ 상단 탭 (매장주문 / 픽업 / 이벤트...) ------------------------

class _TopMenuTabs extends StatelessWidget {
  const _TopMenuTabs();

  @override
  Widget build(BuildContext context) {
    final tabs = ['매장주문', '픽업', '이벤트', '선물하기', '혜택모음'];

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          return Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, // ✅ 중앙 배치 유지
              ),
              onPressed: () {
                // ✅ 수정된 부분: 페이지 이동(Navigator) 제거하고,
                //    단순히 눌렸다는 것만 SnackBar로 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${tabs[index]} 탭을 눌렀어요'),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              },
              child: Text(
                tabs[index],
                textAlign: TextAlign.center, // ✅ 텍스트 중앙 정렬
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // ✅ 항상 검정색
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// ------------------------ 단체 주문 예약 정보 ------------------------
class GroupReservationInfo {
  final DateTime date;
  final int people;
  final String time;

  const GroupReservationInfo({
    required this.date,
    required this.people,
    required this.time,
  });
}


/// ------------------------ 음식 카테고리 그리드 ------------------------

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    final categories = [
      '한식',
      '일식',
      '중식',
      '양식',
      '아시안',
      '치킨',
      '피자',
      '버거',
      '커피·디저트',
      '단체주문',
    ];

    final categoryImages = {
      '한식': 'assets/images/Home_Korea.png',
      '일식': 'assets/images/Home_Japan.png',
      '중식': 'assets/images/Home_China.png',
      '양식': 'assets/images/Home_West.png',
      '아시안': 'assets/images/Home_Asian.png',
      '치킨': 'assets/images/Home_Chicken.png',
      '피자': 'assets/images/Home_Pizza.png',
      '버거': 'assets/images/Home_Burger.png',
      '커피·디저트': 'assets/images/Home_Desert.png',
      '단체주문': 'assets/images/Home_Group.png',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final label = categories[index];
          return GestureDetector(
            onTap: () async {
              // 단체주문만 예약 세팅 BottomSheet 오픈
              if (label == '단체주문') {
                final result =
                await showModalBottomSheet<GroupReservationInfo>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (_) => const GroupReservationBottomSheet(),
                );

                // 예약 정보까지 선택한 경우에만 식당 선택 페이지로 이동
                if (result != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GroupRestaurantListPage(reservationInfo: result),
                    ),
                  );
                }
                return;
              }

              // 나머지 카테고리는 기존처럼 리스트 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryRestaurantListPage(
                    categoryName: label,
                  ),
                ),
              );
            },
            child: _CategoryItem(
              label: label,
              imagePath: categoryImages[label]!,
            ),
          );
        },
      ),
    );
  }
}

/// ------------------------ 단체 주문 예약 Bottom Sheet ------------------------

class GroupReservationBottomSheet extends StatefulWidget {
  const GroupReservationBottomSheet({super.key});

  @override
  State<GroupReservationBottomSheet> createState() =>
      _GroupReservationBottomSheetState();
}

class _GroupReservationBottomSheetState
    extends State<GroupReservationBottomSheet> {
  DateTime _selectedDate = DateTime.now();
  int _selectedPeople = 2;
  String? _selectedTime;

  final List<int> _peopleOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
  final List<String> _timeOptions = const [
    '오전 12:00',
    '오전 12:30',
    '오후 1:00',
    '오후 1:30',
    '오후 2:00',
    '오후 2:30',
    '오후 3:00',
    '오후 3:30',
    '오후 4:00',
    '오후 4:30',
    '오후 5:00',
    '오후 5:30',
    '오후 6:00',
    '오후 6:30',
    '오후 7:00',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: SizedBox(
        height: size.height * 0.8, // 화면의 80% 정도
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 손잡이 바
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '단체 주문 예약',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 🔸 날짜 선택 (위 이미지의 달력 영역)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '날짜',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0000FF),
                ),
              ),
            ),
            SizedBox(
              height: 270,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),

            const SizedBox(height: 8),

            // 🔸 인원 선택 (동그란 버튼들)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '인원',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _peopleOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final people = _peopleOptions[index];
                  final isSelected = people == _selectedPeople;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedPeople = people);
                    },
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFF0000FF) : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0000FF)
                              : const Color(0xFFDDDDDD),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${people}명',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 🔸 시간 선택 (주황색 타임 슬롯들)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '시간',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeOptions.map((time) {
                  final isSelected = time == _selectedTime;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTime = time);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0000FF)
                            : const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Spacer(),

            // 🔸 하단 버튼 (닫기 / 식당 선택하기)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // 아무 값 없이 닫기
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('닫기'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('시간을 선택해주세요.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }

                        // 선택한 값을 부모(showModalBottomSheet)로 넘김
                        Navigator.pop(
                          context,
                          GroupReservationInfo(
                            date: _selectedDate,
                            people: _selectedPeople,
                            time: _selectedTime!,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0000FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '식당 선택하기',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------ 단체 주문 식당 리스트 (임시) ------------------------

class GroupRestaurantListPage extends StatelessWidget {
  final GroupReservationInfo reservationInfo;

  const GroupRestaurantListPage({
    super.key,
    required this.reservationInfo,
  });

  String _formatDate(DateTime d) =>
      '${d.year}년 ${d.month}월 ${d.day}일';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '단체 주문 가능한 식당',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 선택 요약
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE5EAF4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '선택한 예약 정보',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '날짜  ·  ${_formatDate(reservationInfo.date)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      '인원  ·  ${reservationInfo.people}명',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      '시간  ·  ${reservationInfo.time}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 60,
                      color: Color(0xFFB0B3BA),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '단체 주문 가능한 식당 정보가\n곧 추가될 예정입니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '현재는 예약 조건만 먼저 설정할 수 있어요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF727784),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class CategoryRestaurantListPage extends StatelessWidget {
  final String categoryName;

  const CategoryRestaurantListPage({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          '$categoryName 리스트',
          style: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storefront,
                size: 60,
                color: Color(0xFFB0B3BA),
              ),
              SizedBox(height: 12),
              Text(
                '식당 정보 준비중입니다.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '빠른 시일 내에 해당 카테고리 식당 정보를 추가할게요.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF727784),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _CategoryItem extends StatelessWidget {
  final String label;
  final String imagePath;

  const _CategoryItem({required this.label, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 이미지를 쓰려면 AssetImage로 교체
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// ------------------------ 최근주문 / 인기식당 / 오늘의 할인 등 ------------------------

class _ShortcutCardsRow extends StatelessWidget {
  const _ShortcutCardsRow();

  @override
  Widget build(BuildContext context) {
    final items = ['최근 주문', '인기 식당', '오늘의 할인', '동네맛집', '자주 찾은 식당'];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                items[index],
                style: const TextStyle(
                  color: Color(0xFF191919),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ------------------------ 맴버십 배너 ------------------------

class _MembershipBanner extends StatelessWidget {
  const _MembershipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF2C5CD4),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: const Center(
        child: Text(
          '멤버십 할인받고 주문해요',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// ------------------------ 가게 리스트 자리 (추후 실제 데이터 연동) ------------------------

class _RestaurantListPlaceholder extends StatelessWidget {
  const _RestaurantListPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '추천 매장',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BurgerOrderTypePage(),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '맛있는 버거집',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ------------------------ 하단 네비게이션 ------------------------

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0, // 홈 탭 선택된 상태
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.place_outlined),
          label: '근처 찾기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: '찜',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: '주문내역',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '마이페이지',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          // 근처 찾기
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NearSearchPage(),
            ),
          );
        } else if (index == 2) {
          // 찜
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FavoritesPage(),
            ),
          );
        } else if (index == 3) {
          // 주문 내역
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OrderHistoryPage(),
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyPageScreen(),
            ),
          );
        }
      },
    );
  }
}



// ---------------------- 근처 찾기 페이지 ----------------------

class NearSearchPage extends StatelessWidget {
  const NearSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '근처 찾기',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const SafeArea(
        child: Column(
          children: [
            _NearSearchBar(),
            SizedBox(height: 8),
            Expanded(
              child: _MapPlaceholder(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _NearBottomNav(),
    );
  }
}

/// ---------------------- 상단 검색바 (근처 찾기 전용) ----------------------

class _NearSearchBar extends StatelessWidget {
  const _NearSearchBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showSearch(
          context: context,
          delegate: RestaurantSearchDelegate(), // 👈 동일한 SearchDelegate 사용
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFEAEAF2),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: const [
              Icon(
                Icons.search,
                color: Color(0xFF8C939E),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '가게, 메뉴 검색',
                style: TextStyle(
                  color: Color(0xFF8C939E),
                  fontSize: 13,
                ),
              ),
              Spacer(),
              Icon(
                Icons.tune,
                color: Color(0xFF8C939E),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------- 지도 영역 (Placeholder) ----------------------

/// ---------------------- 지도 영역 (Inline WebView) ----------------------

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Container(
        width: double.infinity,
        height: 320, // 지도가 들어갈 높이 (필요하면 조절)
        decoration: BoxDecoration(
          color: const Color(0xFFF2F7FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE5EAF4),
            width: 1,
          ),
        ),
        child: const InlineStoreMapWebView(), // ✅ 아까 만든 WebView 위젯 삽입
      ),
    );
  }
}



/// ---------------------- 하단 네비게이션 (근처 찾기 탭 선택) ----------------------

class _NearBottomNav extends StatelessWidget {
  const _NearBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, // 근처 찾기 탭 선택
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.place),
          label: '근처 찾기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: '찜',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: '주문내역',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '마이페이지',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          // 홈으로
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 2) {
          // 찜으로
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FavoritesPage(),
            ),
          );
        } else if (index == 3) {
          // 주문 내역
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OrderHistoryPage(),
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyPageScreen(),
            ),
          );
        }
      },
    );
  }
}

// ---------------------- 찜 페이지 ----------------------

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  // Figma에서 가져온 찜 리스트 데이터 (로그인 상태일 때만 사용)
  static final List<_FavoriteStore> _initialFavorites = [
    _FavoriteStore(
      name: '맛있는 버거집',
      description: '',
      imageAsset: 'assets/images/Home_Burger.png',
    ),
    _FavoriteStore(
      name: '우리 동네 덮밥집',
      description: '',
      imageAsset: 'assets/images/Home_Friedrice.png',
    ),
    _FavoriteStore(
      name: '블루밍가든',
      description: '',
      imageAsset: 'assets/images/Home_Pasta.png',
    ),
    _FavoriteStore(
      name: '한식당 한그릇',
      description: '',
      imageAsset: 'assets/images/Home_Korea.png',
    ),
    _FavoriteStore(
      name: '로컬 커피',
      description: '',
      imageAsset: 'assets/images/Home_Desert.png',
    ),
  ];

  late List<_FavoriteStore> _favoriteStores;


  @override
  void initState() {
    super.initState();
    _checkLogin();
    _favoriteStores = List<_FavoriteStore>.from(_initialFavorites);
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    setState(() {
      _isLoggedIn = token != null; // 토큰 있으면 로그인 상태로 간주
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '찜',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _isLoggedIn
          // ---------------- 로그인 상태: 기존 리스트 그대로 ----------------
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                '찜한 매장',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _favoriteStores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final store = _favoriteStores[index];
                    return FavoriteItemCard(
                      store: store,
                      onToggleFavorite: () {
                        setState(() {
                          // 하트 토글
                          store.isFavorite = !store.isFavorite;

                          // 🔹 찜 해제된 경우 리스트에서 제거
                          if (!store.isFavorite) {
                            _favoriteStores.removeAt(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"${store.name}" 찜을 해제했습니다.'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        });
                      },
                    );
                  },

                ),
              ),
            ],
          )
          // --------------- 비로그인 상태: 데이터 없음 / 로그인 안내 ---------------
              : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Color(0xFFB0B3BA),
                ),
                const SizedBox(height: 12),
                const Text(
                  '찜한 내역이 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '로그인 후 나의 찜 내역을 확인할 수 있어요.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF727784),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyPageScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '로그인 하러 가기',
                    style: TextStyle(
                      color: Color(0xFF4466DB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _FavBottomNav(),
    );
  }
}


/// 찜한 매장 하나를 나타내는 데이터 모델
class _FavoriteStore {
  final String name;
  final String description;
  final String imageAsset;

  bool isFavorite; // 🔹 하트 켜짐/꺼짐 상태

  _FavoriteStore({
    required this.name,
    required this.description,
    this.imageAsset = 'assets/images/default_store.png',
    this.isFavorite = true, // 기본값은 찜 0
  });
}

/// 개별 찜 카드 UI (Frame "FavItem1~5"를 Row/Column 구조로 리팩터링)
class FavoriteItemCard extends StatelessWidget {
  final _FavoriteStore store;
  final VoidCallback onToggleFavorite; // 하트 눌렀을 때 호출

  const FavoriteItemCard({
    super.key,
    required this.store,
    required this.onToggleFavorite,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEAEAF2),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 왼쪽 썸네일
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              store.imageAsset,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // 가운데 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  store.description,
                  style: const TextStyle(
                    color: Color(0xFF727784),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // 🔹 오른쪽 하트 아이콘
          IconButton(
            icon: Icon(
              store.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: store.isFavorite
                  ? const Color(0xFFFF0000) // 선택 상태: 주황색 하트
                  : const Color(0xFFB0B3BA), // 해제 상태: 회색 테두리 하트
            ),
            onPressed: onToggleFavorite,
          ),
        ],
      ),
    );
  }
}

/// ---------------------- 찜 화면 하단 네비게이션 ----------------------

class _FavBottomNav extends StatelessWidget {
  const _FavBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, // 찜 탭 선택
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.place_outlined),
          label: '근처 찾기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: '찜',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: '주문내역',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '마이페이지',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          // 홈으로
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          // 근처 찾기로
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NearSearchPage(),
            ),
          );
        } else if (index == 3) {
          // 주문 내역
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OrderHistoryPage(),
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyPageScreen(),
            ),
          );
        }
      },
    );
  }
}


// ---------------------- 주문 내역 페이지 ----------------------

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  // 더미 주문 데이터 (로그인 상태에서만 사용)
  static const orders = [
    _OrderHistoryItemData(
      storeName: '맛있는 버거집',
      detail: '주문일 2025.11.14 · 13,300원 · 매장식사',
      imageAsset: 'assets/images/Home_Burger.png',
    ),
    _OrderHistoryItemData(
      storeName: '로컬 커피',
      detail: '주문일 2025.10.30 · 12,400원 · 포장주문',
      imageAsset: 'assets/images/Home_Desert.png',
    ),
    _OrderHistoryItemData(
      storeName: '한식당 한그릇',
      detail: '주문일 2025.08.02 · 15,900원 · 포장주문',
      imageAsset: 'assets/images/Home_Korea.png',
    ),
    _OrderHistoryItemData(
      storeName: '피자대학',
      detail: '주문일 2025.06.29 · 23,900원 · 매장식사',
      imageAsset: 'assets/images/Home_Pizza.png',
    ),
    _OrderHistoryItemData(
      storeName: '우리동네치킨',
      detail: '주문일 2025.05.17 · 25,600원 · 포장주문',
      imageAsset: 'assets/images/Home_Chicken.png',
    ),
    _OrderHistoryItemData(
      storeName: '블루밍가든',
      detail: '주문일 2025.10.30 · 15,900원 · 매장식사',
      imageAsset: 'assets/images/Home_Pasta.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    setState(() {
      _isLoggedIn = token != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '주문 내역',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _isLoggedIn
          // ---------------- 로그인 상태: 기존 리스트 ----------------
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OrderSearchBar(),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: orders.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = orders[index];
                    return OrderHistoryItemCard(item: item);
                  },
                ),
              ),
            ],
          )
          // --------------- 비로그인 상태: 주문 내역 없음 안내 ---------------
              : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Color(0xFFB0B3BA),
                ),
                const SizedBox(height: 12),
                const Text(
                  '주문 내역이 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '로그인 후 나의 주문 내역을 확인할 수 있어요.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF727784),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyPageScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '로그인 하러 가기',
                    style: TextStyle(
                      color: Color(0xFF4466DB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _OrderBottomNav(),
    );
  }
}


/// ---------------------- 주문 내역 검색바 (Frame "주문 내역 검색") ----------------------

class _OrderSearchBar extends StatelessWidget {
  const _OrderSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5EAF4),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color(0xFF8C939E),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            '주문 내역 검색',
            style: TextStyle(
              color: Color(0xFF8C939E),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.tune,
              color: Color(0xFF8C939E),
              size: 20,
            ),
            onPressed: () {
              // TODO: 필터 기능
            },
          ),
        ],
      ),
    );
  }
}

/// ---------------------- 주문 내역 아이템 데이터 ----------------------

class _OrderHistoryItemData {
  final String storeName;
  final String detail;
  final String imageAsset;

  const _OrderHistoryItemData({
    required this.storeName,
    required this.detail,
    this.imageAsset = 'assets/images/default_store.png',
  });
}

/// ---------------------- 주문 내역 카드 (Frame 안 개별 Row) ----------------------

class OrderHistoryItemCard extends StatelessWidget {
  final _OrderHistoryItemData item;

  const OrderHistoryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEAEAF2),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 썸네일
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              item.imageAsset,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.storeName,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.detail,
                  style: const TextStyle(
                    color: Color(0xFF727784),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------- 주문 내역 화면 하단 네비게이션 ----------------------

class _OrderBottomNav extends StatelessWidget {
  const _OrderBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, // 주문내역 탭 선택
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.place_outlined),
          label: '근처 찾기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: '찜',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: '주문내역',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '마이페이지',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          // 홈으로
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          // 근처 찾기
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NearSearchPage(),
            ),
          );
        } else if (index == 2) {
          // 찜
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FavoritesPage(),
            ),
          );
        }
        // index == 3 은 현재 페이지(주문내역)
        else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyPageScreen(),
            ),
          );
        }
      },
    );
  }
}

// ---------------------- 맛있는 버거집 상세 페이지 ----------------------

class BurgerRestaurantPage extends StatelessWidget {
  const BurgerRestaurantPage({super.key});

  // 하드코딩 메뉴 리스트
  static final List<_BurgerMenuItem> _menuItems = [
    const _BurgerMenuItem(
      name: '클래식 버거 세트',
      description: '패티 + 치즈 + 감자튀김 + 콜라 포함 세트',
      price: 8900,
    ),
    const _BurgerMenuItem(
      name: '더블 치즈버거 세트',
      description: '치즈 2장, 패티 2장으로 푸짐하게',
      price: 10900,
    ),
    const _BurgerMenuItem(
      name: '불고기 버거 세트',
      description: '달콤한 불고기 소스와 신선한 야채',
      price: 9500,
    ),
    const _BurgerMenuItem(
      name: '스파이시 치킨버거 세트',
      description: '매콤한 치킨 패티와 매운 소스',
      price: 9800,
    ),
    const _BurgerMenuItem(
      name: '치즈버거 단품',
      description: '간단하게 즐기는 치즈버거',
      price: 5500,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '맛있는 버거집',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return _BurgerMenuCard(item: item);
        },
      ),
    );
  }
}

// 메뉴 아이템 데이터 모델
class _BurgerMenuItem {
  final String name;
  final String description;
  final int price;

  const _BurgerMenuItem({
    required this.name,
    required this.description,
    required this.price,
  });
}

// 메뉴 카드 UI
class _BurgerMenuCard extends StatelessWidget {
  final _BurgerMenuItem item;

  const _BurgerMenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽 썸네일 (placeholder)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAF2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lunch_dining,
              size: 32,
              color: Color(0xFF727784),
            ),
          ),
          const SizedBox(width: 12),
          // 가운데 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF727784),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.price}원',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C5CD4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 오른쪽 장바구니 버튼
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            color: const Color(0xFF2C5CD4),
            onPressed: () async {
              // 🔹 1) 로그인 여부 확인 (jwt_token 존재 여부)
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('jwt_token');

              if (token == null) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '로그인 후 진행해주세요.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        // 🔹 오른쪽 로그인 버튼
                        TextButton(
                          child: const Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyPageScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
                return;
              }


              // 🔹 2) 로그인 상태일 때만 장바구니에 추가
              bool found = false;
              for (final ci in cartItems) {
                if (ci.name == item.name) {
                  ci.quantity++;
                  found = true;
                  break;
                }
              }
              if (!found) {
                cartItems.add(
                  CartItem(
                    name: item.name,
                    price: item.price,
                    quantity: 1,
                  ),
                );
              }

              // 🔹 3) 스낵바 + 장바구니로 이동 버튼
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${item.name}" 을(를) 장바구니에 담았습니다.'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: '장바구니로 이동',
                    textColor: Colors.yellow,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartPage(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------- 장바구니 페이지 ----------------------

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final int totalPrice = cartItems.fold(
      0,
          (sum, item) => sum + item.price * item.quantity,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '장바구니',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          '장바구니가 비어 있습니다.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.name} x ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${item.price * item.quantity}원',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C5CD4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // 하단 합계 + 결제 버튼
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '총 주문 금액',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$totalPrice원',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C5CD4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5CD4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckoutPage(),
                        ),
                      ).then((_) {
                        // 결제 후 돌아왔을 때 UI 갱신
                        setState(() {});
                      });
                    },
                    child: const Text(
                      '주문 / 결제하기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ---------------------- 주문 / 결제 페이지 ----------------------

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // 0: 신용/체크카드, 1: 카카오페이, 2: 네이버페이
  int _selectedMethod = 0;

  final List<String> _methods = const [
    '신용/체크카드',
    '카카오페이',
    '네이버페이',
  ];

  @override
  Widget build(BuildContext context) {
    final int totalPrice = cartItems.fold(
      0,
          (sum, item) => sum + item.price * item.quantity,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '주문 / 결제',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '주문 내역',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          // ✅ 매장 이름 표시 (현재는 맛있는 버거집만 사용)
          const Text(
            '맛있는 버거집',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF727784),
            ),
          ),
          const SizedBox(height: 12),

          // 주문 내역 리스트
          ...cartItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.name} x ${item.quantity}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${item.price * item.quantity}원',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C5CD4),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          const Text(
            '결제 수단',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          // ✅ 하나만 선택되는 결제 수단 라디오 버튼
          _PaymentMethodTile(
            label: _methods[0],
            selected: _selectedMethod == 0,
            onTap: () {
              setState(() => _selectedMethod = 0);
            },
          ),
          _PaymentMethodTile(
            label: _methods[1],
            selected: _selectedMethod == 1,
            onTap: () {
              setState(() => _selectedMethod = 1);
            },
          ),
          _PaymentMethodTile(
            label: _methods[2],
            selected: _selectedMethod == 2,
            onTap: () {
              setState(() => _selectedMethod = 2);
            },
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 결제 금액',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$totalPrice원',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C5CD4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5CD4),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                if (cartItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('장바구니가 비어 있습니다.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  return;
                }

                // 여기서 _selectedMethod 로 어떤 수단인지 확인 가능
                // (현재는 UI만, 실제 결제 연동은 나중에)

                cartItems.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('결제가 완료되었습니다!'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // 뒤로 두 번 (결제 페이지, 장바구니 페이지)
                Navigator.pop(context); // CheckoutPage
                Navigator.pop(context); // CartPage
              },
              child: const Text(
                '결제하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 간단한 결제 수단 타일 (라디오처럼 동작)
class _PaymentMethodTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = selected
        ? Icons.radio_button_checked
        : Icons.radio_button_off;

    final color = selected
        ? const Color(0xFF2C5CD4)
        : const Color(0xFFB0B3BA);

    return ListTile(
      leading: Icon(icon, size: 20, color: color),
      title: Text(label),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: onTap,
    );
  }
}

// ---------------------- 맛있는 버거집 픽업 방식 선택 페이지 ----------------------

class BurgerOrderTypePage extends StatelessWidget {
  const BurgerOrderTypePage({super.key});

  // 여기 값들은 나중에 서버 연동하면 파라미터로 빼도 됨
  static const String storeName = '맛있는 버거집';
  static const String storeAddress = '경기도 화성시 병점동 어딘가 123'; // 실제 주소로 수정해도 됨

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '매장 정보',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) 상단 매장 이미지
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black12,
                child: Image.asset(
                  'assets/images/Home_Burger.png',
                  fit: BoxFit.cover,
                ),

              ),
            ),

            const SizedBox(height: 12),

            // 2) 매장 이름 + 주소 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C5CD4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            storeAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF616161),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3) "식사는 어떻게 하시겠어요?" 타이틀
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '식사 방식을 선택해주세요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 4) 두 개의 큰 버튼 (매장 식사 / 포장 주문)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 매장 식사
                  Expanded(
                    child: _OrderTypeButton(
                      icon: Icons.restaurant,
                      title: '매장 이용',
                      subtitle: '매장에서 먹을게요',
                      onTap: () {
                        // 나중에 orderType 넘기고 싶으면 파라미터 추가해서 넘기면 됨
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BurgerRestaurantPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 포장 주문
                  Expanded(
                    child: _OrderTypeButton(
                      icon: Icons.shopping_bag_outlined,
                      title: '포장 주문',
                      subtitle: '포장해서 가져갈게요',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BurgerRestaurantPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// 공통 버튼 위젯
class _OrderTypeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OrderTypeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 26,
              color: const Color(0xFF2C5CD4),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





