import '../models/restaurant.dart';

const List<Restaurant> sampleRestaurants = [
  Restaurant(
    id: 'burger_store_001',
    name: '맛있는 버거집',
    category: '버거',
    address: '경기도 화성시 병점동 어딘가 123',
    description: '수제버거와 감자튀김이 인기 있는 버거 전문점입니다.',
    imageAsset: 'assets/images/Home_Burger.png',
    menus: [
      RestaurantMenuItem(
        id: 'burger_cheese_set',
        name: '치즈버거 세트',
        description: '치즈버거, 감자튀김, 콜라가 포함된 기본 세트입니다.',
        price: 8900,
      ),
      RestaurantMenuItem(
        id: 'burger_bulgogi_set',
        name: '불고기버거 세트',
        description: '달콤한 불고기 소스가 들어간 인기 세트입니다.',
        price: 9200,
      ),
      RestaurantMenuItem(
        id: 'burger_double',
        name: '더블 패티 버거',
        description: '패티가 두 장 들어간 든든한 버거입니다.',
        price: 7600,
      ),
      RestaurantMenuItem(
        id: 'fries',
        name: '감자튀김',
        description: '바삭한 기본 감자튀김입니다.',
        price: 2200,
      ),
      RestaurantMenuItem(
        id: 'cola',
        name: '콜라',
        description: '시원한 탄산음료입니다.',
        price: 2200,
      ),
    ],
  ),
];

Restaurant get deliciousBurgerRestaurant => sampleRestaurants.first;