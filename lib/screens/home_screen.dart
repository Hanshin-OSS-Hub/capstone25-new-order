import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../app_design.dart';
import '../data/dummy_restaurant.dart';
import '../data/restaurant_data.dart';
import '../models/search_restaurant.dart';
import '../models/restaurant.dart';

import 'store_order_type_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        title: const _LocationSelector(),
        centerTitle: false,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
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
      bottomNavigationBar: const _HomeBottomNav(),
    );
  }
}

/// ------------------------ 식당 데이터 변환 ------------------------

Restaurant _restaurantFromSearchResult(SearchRestaurant store) {
  try {
    return sampleRestaurants.firstWhere(
          (restaurant) => restaurant.name == store.name,
    );
  } catch (_) {
    return Restaurant(
      id: 'temp_${store.name.hashCode}',
      name: store.name,
      category: store.category,
      address: '경기도 화성시 병점동 주변',
      description: store.description.isEmpty
          ? '${store.category} 메뉴를 제공하는 매장입니다.'
          : store.description,
      imageAsset: _imageAssetByCategory(store.category),
      menus: [
        RestaurantMenuItem(
          id: 'basic_menu_1',
          name: '${store.category} 대표 메뉴',
          description: '${store.name}의 대표 메뉴입니다.',
          price: 8900,
        ),
        RestaurantMenuItem(
          id: 'basic_menu_2',
          name: '${store.category} 세트 메뉴',
          description: '메인 메뉴와 사이드가 포함된 세트입니다.',
          price: 11900,
        ),
        RestaurantMenuItem(
          id: 'basic_menu_3',
          name: '사이드 메뉴',
          description: '함께 주문하기 좋은 사이드 메뉴입니다.',
          price: 3500,
        ),
        RestaurantMenuItem(
          id: 'basic_menu_4',
          name: '음료',
          description: '시원한 음료입니다.',
          price: 2200,
        ),
      ],
    );
  }
}

String _imageAssetByCategory(String category) {
  switch (category) {
    case '한식':
      return 'assets/images/Home_Korea.png';
    case '일식':
      return 'assets/images/Home_Japan.png';
    case '중식':
      return 'assets/images/Home_China.png';
    case '양식':
      return 'assets/images/Home_West.png';
    case '아시안':
      return 'assets/images/Home_Asian.png';
    case '치킨':
      return 'assets/images/Home_Chicken.png';
    case '피자':
      return 'assets/images/Home_Pizza.png';
    case '버거':
      return 'assets/images/Home_Burger.png';
    case '카페':
    case '커피·디저트':
      return 'assets/images/Home_Desert.png';
    default:
      return 'assets/images/Home_Burger.png';
  }
}

/// ------------------------ 상단 위치 선택 ------------------------

class _LocationSelector extends StatefulWidget {
  const _LocationSelector();

  @override
  State<_LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<_LocationSelector> {
  String _selectedLocation = '한신대학교';
  bool _isFetchingCurrentLocation = false;

  final List<String> _savedLocations = [
    '한신대학교',
    '오산역',
    '병점역',
    '동탄역',
  ];

  Future<void> _addCurrentLocation(BuildContext bottomSheetContext) async {
    if (_isFetchingCurrentLocation) return;

    setState(() {
      _isFetchingCurrentLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치 서비스가 꺼져 있습니다. 설정에서 위치 서비스를 켜주세요.'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치 권한이 거부되었습니다.'),
          ),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.'),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String locationLabel = '현재 위치';

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final parts = <String>[
          if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
          if ((p.thoroughfare ?? '').trim().isNotEmpty) p.thoroughfare!.trim(),
        ];

        if (parts.isNotEmpty) {
          locationLabel = parts.join(' ');
        }
      }

      if (!mounted) return;

      setState(() {
        if (!_savedLocations.contains(locationLabel)) {
          _savedLocations.add(locationLabel);
        }
        _selectedLocation = locationLabel;
      });

      Navigator.pop(bottomSheetContext);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('현재 위치가 "$locationLabel"로 추가되었습니다.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('현재 위치를 불러오지 못했습니다: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingCurrentLocation = false;
        });
      }
    }
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '위치 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ..._savedLocations.map((location) {
                  final isSelected = location == _selectedLocation;

                  return ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: isSelected
                          ? kPrimaryColor
                          : const Color(0xFF9CA3AF),
                    ),
                    title: Text(
                      location,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: kTextColor,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                      Icons.check,
                      color: kPrimaryColor,
                    )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLocation = location;
                      });
                      Navigator.pop(bottomSheetContext);
                    },
                  );
                }),
                const Divider(height: 20, thickness: 1),
                ListTile(
                  leading: Icon(
                    Icons.my_location,
                    color: _isFetchingCurrentLocation
                        ? const Color(0xFF9CA3AF)
                        : kPrimaryColor,
                  ),
                  title: Text(
                    _isFetchingCurrentLocation
                        ? '현재 위치 불러오는 중...'
                        : '현재 위치 추가',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _isFetchingCurrentLocation
                          ? const Color(0xFF9CA3AF)
                          : kPrimaryColor,
                    ),
                  ),
                  trailing: _isFetchingCurrentLocation
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : null,
                  onTap: _isFetchingCurrentLocation
                      ? null
                      : () => _addCurrentLocation(bottomSheetContext),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _showLocationSelector,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on,
            color: kPrimaryColor,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            _selectedLocation,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kTextColor,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_drop_down,
            color: kTextColor,
          ),
        ],
      ),
    );
  }
}

/// ------------------------ 검색 바 ------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showSearch(
          context: context,
          delegate: RestaurantSearchDelegate(),
        );
      },
      child: MinimalSquircleCard(
        radius: 26,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: const SizedBox(
          height: 44,
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Color(0xFF8A8F98),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '가게, 메뉴 검색',
                style: TextStyle(
                  color: Color(0xFF8A8F98),
                  fontSize: 15,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------ 검색 기능 ------------------------

class RestaurantSearchDelegate extends SearchDelegate<String> {
  final List<SearchRestaurant> _restaurants = dummyRestaurants;

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

  @override
  Widget buildResults(BuildContext context) {
    return _SearchResultsView(
      query: query,
      restaurants: _restaurants,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final lowerQuery = query.toLowerCase();

    final suggestions = query.isEmpty
        ? _restaurants
        : _restaurants.where((store) {
      final inName = store.name.toLowerCase().contains(lowerQuery);
      final inCategory =
      store.category.toLowerCase().contains(lowerQuery);
      final inTags = store.tags.any(
            (tag) => tag.toLowerCase().contains(lowerQuery),
      );

      return inName || inCategory || inTags;
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final store = suggestions[index];

        return ListTile(
          leading: Icon(query.isEmpty ? Icons.history : Icons.search),
          title: Text(store.name),
          subtitle: Text(store.category),
          onTap: () {
            query = store.name;
            showResults(context);
          },
        );
      },
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  final String query;
  final List<SearchRestaurant> restaurants;

  const _SearchResultsView({
    required this.query,
    required this.restaurants,
  });

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
  String _selectedSort = '추천 순';

  final List<String> _sortOptions = const [
    '추천 순',
    '가까운 거리 순',
    '자주 주문한 순',
    '주문 많은 순',
    '새로 생긴 순',
  ];

  List<SearchRestaurant> _getFilteredAndSortedResults() {
    final lowerQuery = widget.query.toLowerCase();

    final results = widget.restaurants.where((store) {
      final inName = store.name.toLowerCase().contains(lowerQuery);
      final inCategory = store.category.toLowerCase().contains(lowerQuery);
      final inTags = store.tags.any(
            (tag) => tag.toLowerCase().contains(lowerQuery),
      );

      return inName || inCategory || inTags;
    }).toList();

    switch (_selectedSort) {
      case '가까운 거리 순':
        results.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case '자주 주문한 순':
        results.sort((a, b) => b.myOrderCount.compareTo(a.myOrderCount));
        break;
      case '주문 많은 순':
        results.sort((a, b) => b.totalOrderCount.compareTo(a.totalOrderCount));
        break;
      case '새로 생긴 순':
        results.sort((a, b) => b.createdOrder.compareTo(a.createdOrder));
        break;
      case '추천 순':
      default:
        results.sort((a, b) => b.recommendScore.compareTo(a.recommendScore));
        break;
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final results = _getFilteredAndSortedResults();

    if (results.isEmpty) {
      return Center(
        child: Text(
          '"${widget.query}" 에 대한 검색 결과가 없습니다.',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MinimalSquircleCard(
                radius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 36,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: kSubTextColor,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kTextColor,
                      ),
                      items: _sortOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedSort = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final store = results[index];
              return _SearchResultCard(store: store);
            },
          ),
        ),
      ],
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final SearchRestaurant store;

  const _SearchResultCard({
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final restaurant = _restaurantFromSearchResult(store);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MinimalSquircleCard(
        radius: 28,
        padding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoreOrderTypePage(
                restaurant: restaurant,
              ),
            ),
          );
        },
        child: Row(
          children: [
            ClipPath(
              clipper: ShapeBorderClipper(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Image.asset(
                restaurant.imageAsset,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.description.isEmpty
                        ? store.category
                        : store.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kSubTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${store.distance.toStringAsFixed(1)}km · ${store.category}',
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

/// ------------------------ 프로모션 배너 ------------------------

class _PromotionBannerCarousel extends StatefulWidget {
  const _PromotionBannerCarousel();

  @override
  State<_PromotionBannerCarousel> createState() =>
      _PromotionBannerCarouselState();
}

class _PromotionBannerCarouselState extends State<_PromotionBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<_BannerData> _banners = const [
    _BannerData(
      title: '지금 신규가입하면 모든 메뉴 5,000원 할인!',
      subtitle: '가입하고 혜택받기 >',
      colors: [
        Color(0xFF45B5AA),
        Color(0xFF7BC4C4),
      ],
    ),
    _BannerData(
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

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
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
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: kSoftShadow,
              ),
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: banner.colors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
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
              ),
            ),
          );
        },
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

/// ------------------------ 상단 탭 ------------------------

class _TopMenuTabs extends StatelessWidget {
  const _TopMenuTabs();

  @override
  Widget build(BuildContext context) {
    final tabs = ['매장주문', '픽업', '이벤트', '선물하기', '혜택모음'];

    return MinimalSquircleCard(
      padding: EdgeInsets.zero,
      radius: 24,
      child: SizedBox(
        height: 44,
        child: Row(
          children: List.generate(tabs.length, (index) {
            return Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: kTextColor,
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tabs[index]} 탭을 눌렀어요'),
                      duration: const Duration(milliseconds: 800),
                    ),
                  );
                },
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextColor,
                  ),
                ),
              ),
            );
          }),
        ),
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

  final List<int> _peopleOptions = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
  ];

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
        height: size.height * 0.82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '단체 주문 예약',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kTextColor,
                ),
              ),
            ),

            const SizedBox(height: 14),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '날짜',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor,
                ),
              ),
            ),

            SizedBox(
              height: 270,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(
                  const Duration(days: 90),
                ),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),

            const SizedBox(height: 8),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '인원',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kTextColor,
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _peopleOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final people = _peopleOptions[index];
                  final isSelected = people == _selectedPeople;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPeople = people;
                      });
                    },
                    child: Container(
                      width: 58,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: isSelected ? kPrimaryColor : Colors.white,
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: isSelected ? kPrimaryColor : kBorderColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        '${people}명',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : kTextColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '시간',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kTextColor,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeOptions.map((time) {
                  final isSelected = time == _selectedTime;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: isSelected
                            ? kPrimaryColor
                            : const Color(0xFFF7F8FA),
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: isSelected ? kPrimaryColor : kBorderColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : kTextColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: minimalOutlinedButtonStyle(),
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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

                        Navigator.pop(
                          context,
                          GroupReservationInfo(
                            date: _selectedDate,
                            people: _selectedPeople,
                            time: _selectedTime!,
                          ),
                        );
                      },
                      style: minimalPrimaryButtonStyle(),
                      child: const Text(
                        '식당 선택하기',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
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

/// ------------------------ 단체 주문 식당 리스트 ------------------------

class GroupRestaurantListPage extends StatelessWidget {
  final GroupReservationInfo reservationInfo;

  const GroupRestaurantListPage({
    super.key,
    required this.reservationInfo,
  });

  String _formatDate(DateTime d) {
    return '${d.year}년 ${d.month}월 ${d.day}일';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        title: const Text('단체 주문 가능한 식당'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MinimalSquircleCard(
              radius: 30,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '선택한 예약 정보',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '날짜  ·  ${_formatDate(reservationInfo.date)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: kSubTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '인원  ·  ${reservationInfo.people}명',
                    style: const TextStyle(
                      fontSize: 13,
                      color: kSubTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '시간  ·  ${reservationInfo.time}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: kSubTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 64,
                      color: Color(0xFFB0B3BA),
                    ),
                    SizedBox(height: 14),
                    Text(
                      '단체 주문 가능한 식당 정보가\n곧 추가될 예정입니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kTextColor,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '현재는 예약 조건만 먼저 설정할 수 있어요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: kSubTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------ 카테고리 ------------------------

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

    return MinimalSquircleCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          final label = categories[index];

          return GestureDetector(
            onTap: () async {
              if (label == '단체주문') {
                final result = await showModalBottomSheet<GroupReservationInfo>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const ContinuousRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  builder: (_) => const GroupReservationBottomSheet(),
                );

                if (result != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupRestaurantListPage(
                        reservationInfo: result,
                      ),
                    ),
                  );
                }

                return;
              }

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

class _CategoryItem extends StatelessWidget {
  final String label;
  final String imagePath;

  const _CategoryItem({
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipPath(
          clipper: ShapeBorderClipper(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Image.asset(
            imagePath,
            width: 58,
            height: 58,
            fit: BoxFit.cover,
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

class CategoryRestaurantListPage extends StatelessWidget {
  final String categoryName;

  const CategoryRestaurantListPage({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        title: Text('$categoryName 리스트'),
      ),
      body: const Center(
        child: Text(
          '식당 정보 준비중입니다.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kTextColor,
          ),
        ),
      ),
    );
  }
}

/// ------------------------ 숏컷 카드 ------------------------

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
          return _ShortcutCard(label: items[index]);
        },
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final String label;

  const _ShortcutCard({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return MinimalSquircleCard(
      radius: 28,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 120,
        height: 100,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------ 멤버십 배너 ------------------------

class _MembershipBanner extends StatelessWidget {
  const _MembershipBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kPrimaryColor,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: const SizedBox(
        width: double.infinity,
        height: 58,
        child: Center(
          child: Text(
            '멤버십 할인받고 주문해요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------ 추천 매장 ------------------------

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
            color: kTextColor,
          ),
        ),
        const SizedBox(height: 12),
        MinimalSquircleCard(
          radius: 28,
          padding: const EdgeInsets.all(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoreOrderTypePage(
                  restaurant: deliciousBurgerRestaurant,
                ),
              ),
            );
          },
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '맛있는 버거집',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '버거 · 패스트푸드',
                style: TextStyle(
                  fontSize: 13,
                  color: kSubTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ------------------------ 하단 네비게이션 ------------------------

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
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
          Navigator.pushNamed(context, '/near');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/favorites');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/orders');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/mypage');
        }
      },
    );
  }
}