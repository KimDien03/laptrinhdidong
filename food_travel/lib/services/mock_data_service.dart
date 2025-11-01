import 'package:uuid/uuid.dart';

import '../models/place.dart';
import '../models/review.dart';

class MockDataService {
  MockDataService();

  final Uuid _uuid = const Uuid();

  List<Place> loadPlaces() {
    final dalatMorning = Place(
      id: _uuid.v4(),
      name: 'Morning In Town',
      category: PlaceCategory.cafe,
      description:
          'Quan ca phe phong cach ban cong, phuc vu do uong dac san Da Lat va do an nhe.',
      address: '11 Trieu Viet Vuong, Da Lat',
      city: 'Da Lat',
      latitude: 11.938047,
      longitude: 108.444324,
      imageUrls: const [
        'https://images.unsplash.com/photo-1447933601403-0c6688de566e',
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085',
      ],
      phone: '0263 3811 233',
      priceLevel: PriceLevel.medium,
      averageSpend: 120000,
      openingHours: const [
        OpeningHours(day: 'Mon - Sun', opensAt: '07:00', closesAt: '21:30'),
      ],
      tags: const ['caphe', 'view dep', 'ban cong'],
      website: null,
    );

    final dalatLauGa = Place(
      id: _uuid.v4(),
      name: 'Lau Ga La E Tao Ngo',
      category: PlaceCategory.specialty,
      description:
          'Lau ga nau la e chuan vi Tay Nguyen, khong gian am cung, phuc vu nhanh.',
      address: '7 Hai Ba Trung, Da Lat',
      city: 'Da Lat',
      latitude: 11.944528,
      longitude: 108.438724,
      imageUrls: const [
        'https://images.unsplash.com/photo-1589308078056-f84dfa1c709c',
        'https://images.unsplash.com/photo-1604908177522-4023acb59d4d',
      ],
      phone: '0911 220 099',
      priceLevel: PriceLevel.medium,
      averageSpend: 180000,
      openingHours: const [
        OpeningHours(day: 'Mon - Sun', opensAt: '09:00', closesAt: '22:00'),
      ],
      tags: const ['dac san', 'lau ga', 'am thuc'],
      website: null,
    );

    final dalatLangBiang = Place(
      id: _uuid.v4(),
      name: 'Lang Biang',
      category: PlaceCategory.attraction,
      description:
          'Dinh nui cao nhat Da Lat, thuan loi cho trekking, ngam toan canh thanh pho.',
      address: 'Lang Biang, Lac Duong, Lam Dong',
      city: 'Da Lat',
      latitude: 12.026381,
      longitude: 108.435226,
      imageUrls: const [
        'https://images.unsplash.com/photo-1497436072909-60f360e1d4b1',
        'https://images.unsplash.com/photo-1439396087961-98bc12c21176',
      ],
      phone: '0263 3833 644',
      priceLevel: PriceLevel.low,
      averageSpend: 50000,
      openingHours: const [
        OpeningHours(day: 'Mon - Sun', opensAt: '07:30', closesAt: '17:00'),
      ],
      tags: const ['ngoai troi', 'checkin', 'trekking'],
      website: 'https://dalat.info/langbiang',
    );

    final dalatDalatWonder = Place(
      id: _uuid.v4(),
      name: 'Dalat Wonder Resort',
      category: PlaceCategory.hotel,
      description:
          'Khu nghi duong bao quanh bo ho, phong bungalow, dich vu an uong trong khuon vien.',
      address: 'Hoa Hoai Thuong, Da Lat',
      city: 'Da Lat',
      latitude: 11.860667,
      longitude: 108.447126,
      imageUrls: const [
        'https://images.unsplash.com/photo-1551884170-09fb70a3a2ed',
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511',
      ],
      phone: '0263 3601 601',
      priceLevel: PriceLevel.luxury,
      averageSpend: 2500000,
      openingHours: const [
        OpeningHours(day: '24/7', opensAt: '00:00', closesAt: '23:59'),
      ],
      tags: const ['resort', 'khach san', 'ho nuoc'],
      website: 'https://dalatwonder.vn',
    );

    final dalatMaze = Place(
      id: _uuid.v4(),
      name: 'Me Linh Coffee Garden',
      category: PlaceCategory.experience,
      description:
          'Trang trai ca phe chon me linh, co khu tham quan quy trinh rang xay va khu vuon hoa.',
      address: 'Tong Lap 4, Ta Nung, Da Lat',
      city: 'Da Lat',
      latitude: 11.904176,
      longitude: 108.367526,
      imageUrls: const [
        'https://images.unsplash.com/photo-1470337458703-46ad1756a187',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
      ],
      phone: '0263 3838 888',
      priceLevel: PriceLevel.low,
      averageSpend: 90000,
      openingHours: const [
        OpeningHours(day: 'Mon - Sun', opensAt: '08:00', closesAt: '18:00'),
      ],
      tags: const ['trai nghiem', 'nong trai', 'caphe'],
      website: null,
    );

    final dalatNightMarket = Place(
      id: _uuid.v4(),
      name: 'Cho Dem Da Lat',
      category: PlaceCategory.nightlife,
      description:
          'Trung tam am thuc duong pho, mua sam dac san, am nhac duong pho soi dong.',
      address: 'Nguyen Thi Minh Khai, Da Lat',
      city: 'Da Lat',
      latitude: 11.946905,
      longitude: 108.441505,
      imageUrls: const [
        'https://images.unsplash.com/photo-1504753793650-d4a2b783c15e',
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
      ],
      phone: '0263 3556 789',
      priceLevel: PriceLevel.low,
      averageSpend: 70000,
      openingHours: const [
        OpeningHours(day: 'Mon - Sun', opensAt: '17:00', closesAt: '00:00'),
      ],
      tags: const ['dem', 'duong pho', 'dac san'],
      website: null,
    );

    return [
      dalatMorning,
      dalatLauGa,
      dalatLangBiang,
      dalatDalatWonder,
      dalatMaze,
      dalatNightMarket,
    ];
  }

  List<Review> loadReviews(List<Place> places) {
    if (places.isEmpty) {
      return const [];
    }
    final cafe = places.first;
    final now = DateTime.now();
    return [
      Review(
        id: _uuid.v4(),
        placeId: cafe.id,
        userId: 'user_alice',
        userName: 'Alice',
        rating: 4.5,
        comment: 'Ca phe ngon, view ban cong dep',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Review(
        id: _uuid.v4(),
        placeId: cafe.id,
        userId: 'user_bob',
        userName: 'Bob',
        rating: 4,
        comment: 'Phuc vu nhanh, gia hop ly',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      Review(
        id: _uuid.v4(),
        placeId: places[1].id,
        userId: 'user_carol',
        userName: 'Carol',
        rating: 5,
        comment: 'Lau ga ngon tuyet, nuoc dung dam da',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Review(
        id: _uuid.v4(),
        placeId: places[2].id,
        userId: 'user_david',
        userName: 'David',
        rating: 4.8,
        comment: 'Khung canh rat dep, nhac nho mang ao am.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }
}
