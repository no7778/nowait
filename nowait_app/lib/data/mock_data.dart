import '../models/models.dart';

// ─── Category products shown at top of each category screen ───────────────────

const salonProducts = [
  CategoryProduct(name: 'Haircut', icon: '✂️', priceFrom: '₹149'),
  CategoryProduct(name: 'Beard Trim', icon: '🪒', priceFrom: '₹99'),
  CategoryProduct(name: 'Hair Color', icon: '🎨', priceFrom: '₹499'),
  CategoryProduct(name: 'Head Massage', icon: '💆', priceFrom: '₹149'),
  CategoryProduct(name: 'Threading', icon: '🧵', priceFrom: '₹50'),
  CategoryProduct(name: 'Kids Cut', icon: '👶', priceFrom: '₹99'),
  CategoryProduct(name: 'Shave', icon: '🪮', priceFrom: '₹80'),
  CategoryProduct(name: 'Styling', icon: '💈', priceFrom: '₹199'),
];

const beautyProducts = [
  CategoryProduct(name: 'Facial', icon: '🧖', priceFrom: '₹349'),
  CategoryProduct(name: 'Waxing', icon: '💅', priceFrom: '₹199'),
  CategoryProduct(name: 'Manicure', icon: '💅', priceFrom: '₹199'),
  CategoryProduct(name: 'Pedicure', icon: '🦶', priceFrom: '₹249'),
  CategoryProduct(name: 'Eyebrows', icon: '👁️', priceFrom: '₹60'),
  CategoryProduct(name: 'Bleach', icon: '✨', priceFrom: '₹299'),
  CategoryProduct(name: 'Cleanup', icon: '🧴', priceFrom: '₹199'),
  CategoryProduct(name: 'Bridal', icon: '👰', priceFrom: '₹2999'),
];

const hospitalProducts = [
  CategoryProduct(name: 'General OPD', icon: '🩺', priceFrom: '₹200'),
  CategoryProduct(name: 'Emergency', icon: '🚨', priceFrom: 'Free'),
  CategoryProduct(name: 'Dentist', icon: '🦷', priceFrom: '₹300'),
  CategoryProduct(name: 'Blood Test', icon: '🩸', priceFrom: '₹150'),
  CategoryProduct(name: 'X-Ray', icon: '🔬', priceFrom: '₹400'),
  CategoryProduct(name: 'Eye Check', icon: '👁️', priceFrom: '₹250'),
  CategoryProduct(name: 'Pediatric', icon: '👶', priceFrom: '₹300'),
  CategoryProduct(name: 'Orthopedic', icon: '🦴', priceFrom: '₹500'),
];

const garageProducts = [
  CategoryProduct(name: 'Oil Change', icon: '🛢️', priceFrom: '₹399'),
  CategoryProduct(name: 'Tyre Service', icon: '🔧', priceFrom: '₹199'),
  CategoryProduct(name: 'AC Repair', icon: '❄️', priceFrom: '₹799'),
  CategoryProduct(name: 'Brake Check', icon: '🛑', priceFrom: '₹299'),
  CategoryProduct(name: 'Denting', icon: '🔨', priceFrom: '₹499'),
  CategoryProduct(name: 'Wash & Clean', icon: '🚿', priceFrom: '₹149'),
  CategoryProduct(name: 'Battery', icon: '🔋', priceFrom: '₹299'),
  CategoryProduct(name: 'Alignment', icon: '⚙️', priceFrom: '₹599'),
];

List<CategoryProduct> productsForCategory(String category) {
  switch (category) {
    case 'Salon': return salonProducts;
    case 'Beauty Parlour': return beautyProducts;
    case 'Hospital': return hospitalProducts;
    case 'Garage': return garageProducts;
    default: return salonProducts;
  }
}

// ─── Mock shops ───────────────────────────────────────────────────────────────

final List<ShopModel> mockShops = [
  // SALON
  ShopModel(
    id: '1',
    name: 'Luxe Cuts Studio',
    category: 'Salon',
    address: '12, MG Road',
    city: 'Bengaluru',
    rating: 4.8,
    isOpen: true,
    queueCount: 12,
    currentToken: 8,
    avgWaitMinutes: 18,
    distance: '0.4 km',
    ownerName: 'Ravi Kumar',
    images: [],
    services: [
      const ServiceModel(id: 's1', name: 'Haircut', description: 'Classic haircut & styling', price: 299),
      const ServiceModel(id: 's2', name: 'Beard Trim', description: 'Precision beard shaping', price: 149),
      const ServiceModel(id: 's3', name: 'Hair Colour', description: 'Full colour treatment', price: 799),
    ],
    isPromoted: true,
    hasActiveSubscription: true,
    activeScheme: SchemeModel(
      id: 'sc1',
      title: '20% Off on Weekdays',
      description: 'Get flat 20% off on all services Monday–Friday',
      validUntil: DateTime.now().add(const Duration(days: 12)),
    ),
  ),
  ShopModel(
    id: '2',
    name: 'City Hair Craft',
    category: 'Salon',
    address: '8, Koramangala',
    city: 'Bengaluru',
    rating: 4.3,
    isOpen: false,
    queueCount: 0,
    currentToken: 0,
    avgWaitMinutes: 0,
    distance: '2.3 km',
    ownerName: 'Suresh Nair',
    images: [],
    services: [
      const ServiceModel(id: 's4', name: 'Haircut', description: 'Trendy cuts & styling', price: 249),
    ],
    hasActiveSubscription: false,
  ),
  ShopModel(
    id: '3',
    name: 'Royal Barber Shop',
    category: 'Salon',
    address: '3, Indiranagar',
    city: 'Bengaluru',
    rating: 4.7,
    isOpen: true,
    queueCount: 4,
    currentToken: 2,
    avgWaitMinutes: 8,
    distance: '0.8 km',
    ownerName: 'Mohammed Ali',
    images: [],
    services: [
      const ServiceModel(id: 's5', name: 'Haircut & Shave', description: 'Classic cut + hot towel shave', price: 399),
      const ServiceModel(id: 's6', name: 'Head Massage', description: 'Relaxing scalp massage', price: 199),
    ],
    isPromoted: true,
    hasActiveSubscription: true,
    activeScheme: SchemeModel(
      id: 'sc2',
      title: 'Free Head Massage',
      description: 'Free 10-min head massage with every haircut',
      validUntil: DateTime.now().add(const Duration(days: 5)),
    ),
  ),
  ShopModel(
    id: '4',
    name: 'Style Zone',
    category: 'Salon',
    address: '17, JP Nagar',
    city: 'Bengaluru',
    rating: 4.1,
    isOpen: true,
    queueCount: 7,
    currentToken: 4,
    avgWaitMinutes: 15,
    distance: '3.5 km',
    ownerName: 'Kiran S',
    images: [],
    services: [
      const ServiceModel(id: 's7', name: 'Haircut', description: 'Stylish cuts for men & women', price: 199),
      const ServiceModel(id: 's8', name: 'Hair Spa', description: 'Deep conditioning treatment', price: 499),
    ],
    hasActiveSubscription: true,
  ),

  // BEAUTY PARLOUR
  ShopModel(
    id: '5',
    name: 'Glow Beauty Lounge',
    category: 'Beauty Parlour',
    address: '5, Brigade Road',
    city: 'Bengaluru',
    rating: 4.6,
    isOpen: true,
    queueCount: 6,
    currentToken: 3,
    avgWaitMinutes: 22,
    distance: '1.1 km',
    ownerName: 'Priya Sharma',
    images: [],
    services: [
      const ServiceModel(id: 's9', name: 'Facial', description: 'Deep cleanse facial', price: 499),
      const ServiceModel(id: 's10', name: 'Waxing', description: 'Full body waxing', price: 599),
      const ServiceModel(id: 's11', name: 'Manicure', description: 'Nail care & polish', price: 249),
    ],
    isPromoted: true,
    hasActiveSubscription: true,
    activeScheme: SchemeModel(
      id: 'sc3',
      title: 'Combo Offer',
      description: 'Facial + Manicure + Pedicure at ₹899',
      validUntil: DateTime.now().add(const Duration(days: 8)),
    ),
  ),
  ShopModel(
    id: '6',
    name: 'Elite Wellness Spa',
    category: 'Beauty Parlour',
    address: '22, HSR Layout',
    city: 'Bengaluru',
    rating: 4.9,
    isOpen: true,
    queueCount: 9,
    currentToken: 5,
    avgWaitMinutes: 35,
    distance: '3.2 km',
    ownerName: 'Ananya Reddy',
    images: [],
    services: [
      const ServiceModel(id: 's12', name: 'Full Body Massage', description: '60-min therapeutic massage', price: 1299),
      const ServiceModel(id: 's13', name: 'Bridal Package', description: 'Complete bridal beauty', price: 4999),
    ],
    hasActiveSubscription: true,
  ),
  ShopModel(
    id: '7',
    name: 'Pink Petals Beauty',
    category: 'Beauty Parlour',
    address: '9, Whitefield',
    city: 'Bengaluru',
    rating: 4.4,
    isOpen: false,
    queueCount: 0,
    currentToken: 0,
    avgWaitMinutes: 0,
    distance: '5.1 km',
    ownerName: 'Deepa V',
    images: [],
    services: [
      const ServiceModel(id: 's14', name: 'Eyebrow Threading', description: 'Precision eyebrow shaping', price: 60),
      const ServiceModel(id: 's15', name: 'Bleach', description: 'Face & neck bleach', price: 299),
    ],
    hasActiveSubscription: false,
  ),

  // HOSPITAL
  ShopModel(
    id: '8',
    name: 'Apollo Clinic',
    category: 'Hospital',
    address: '1, Bannerghatta Road',
    city: 'Bengaluru',
    rating: 4.7,
    isOpen: true,
    queueCount: 18,
    currentToken: 11,
    avgWaitMinutes: 25,
    distance: '1.8 km',
    ownerName: 'Dr. Ramesh M',
    images: [],
    services: [
      const ServiceModel(id: 's16', name: 'General OPD', description: 'General physician consultation', price: 300),
      const ServiceModel(id: 's17', name: 'Blood Test', description: 'CBC, Sugar, Lipid profile', price: 250),
      const ServiceModel(id: 's18', name: 'ECG', description: 'Electrocardiogram', price: 400),
    ],
    isPromoted: true,
    hasActiveSubscription: true,
    activeScheme: SchemeModel(
      id: 'sc4',
      title: 'Free Health Checkup',
      description: 'Free basic health checkup on every 5th visit',
      validUntil: DateTime.now().add(const Duration(days: 30)),
    ),
  ),
  ShopModel(
    id: '9',
    name: 'City Dental Clinic',
    category: 'Hospital',
    address: '14, Jayanagar',
    city: 'Bengaluru',
    rating: 4.5,
    isOpen: true,
    queueCount: 8,
    currentToken: 4,
    avgWaitMinutes: 20,
    distance: '2.6 km',
    ownerName: 'Dr. Sunitha K',
    images: [],
    services: [
      const ServiceModel(id: 's19', name: 'Dental Checkup', description: 'Full dental examination', price: 350),
      const ServiceModel(id: 's20', name: 'Cleaning', description: 'Professional teeth cleaning', price: 800),
    ],
    hasActiveSubscription: true,
  ),
  ShopModel(
    id: '10',
    name: 'LifeCare Hospital',
    category: 'Hospital',
    address: '33, Electronic City',
    city: 'Bengaluru',
    rating: 4.2,
    isOpen: true,
    queueCount: 24,
    currentToken: 15,
    avgWaitMinutes: 40,
    distance: '7.3 km',
    ownerName: 'Dr. Anil R',
    images: [],
    services: [
      const ServiceModel(id: 's21', name: 'Emergency', description: '24x7 emergency care', price: 0),
      const ServiceModel(id: 's22', name: 'Orthopedic', description: 'Bone & joint consultation', price: 500),
    ],
    hasActiveSubscription: false,
  ),

  // GARAGE
  ShopModel(
    id: '11',
    name: 'SpeedFix Auto Works',
    category: 'Garage',
    address: '6, Old Airport Road',
    city: 'Bengaluru',
    rating: 4.6,
    isOpen: true,
    queueCount: 5,
    currentToken: 2,
    avgWaitMinutes: 45,
    distance: '2.1 km',
    ownerName: 'Sunil Mehta',
    images: [],
    services: [
      const ServiceModel(id: 's23', name: 'Oil Change', description: 'Engine oil + filter change', price: 499),
      const ServiceModel(id: 's24', name: 'Tyre Service', description: 'Rotation, balancing & alignment', price: 399),
      const ServiceModel(id: 's25', name: 'AC Repair', description: 'Car AC service & gas refill', price: 999),
    ],
    isPromoted: true,
    hasActiveSubscription: true,
    activeScheme: SchemeModel(
      id: 'sc5',
      title: '₹200 Off on Full Service',
      description: 'Complete car service at special price this month',
      validUntil: DateTime.now().add(const Duration(days: 18)),
    ),
  ),
  ShopModel(
    id: '12',
    name: 'TrustWheels Garage',
    category: 'Garage',
    address: '21, Peenya',
    city: 'Bengaluru',
    rating: 4.3,
    isOpen: true,
    queueCount: 3,
    currentToken: 1,
    avgWaitMinutes: 60,
    distance: '4.4 km',
    ownerName: 'Rajan P',
    images: [],
    services: [
      const ServiceModel(id: 's26', name: 'Denting & Painting', description: 'Scratch removal & paint job', price: 1499),
      const ServiceModel(id: 's27', name: 'Brake Service', description: 'Brake pad replacement', price: 699),
    ],
    hasActiveSubscription: true,
  ),
  ShopModel(
    id: '13',
    name: 'Quick Lube Station',
    category: 'Garage',
    address: '45, Hebbal',
    city: 'Bengaluru',
    rating: 4.0,
    isOpen: false,
    queueCount: 0,
    currentToken: 0,
    avgWaitMinutes: 0,
    distance: '5.9 km',
    ownerName: 'Farhan S',
    images: [],
    services: [
      const ServiceModel(id: 's28', name: 'Oil Change', description: 'Quick lube & filter', price: 399),
    ],
    hasActiveSubscription: false,
  ),
];

// ─── Notifications ────────────────────────────────────────────────────────────

final List<NotificationModel> mockNotifications = [
  NotificationModel(
    id: 'n1',
    type: NotificationType.yourTurn,
    title: "It's Your Turn!",
    body: "Token A-08 is now being called at Luxe Cuts Studio. Please proceed.",
    shopName: 'Luxe Cuts Studio',
    time: DateTime.now().subtract(const Duration(minutes: 2)),
  ),
  NotificationModel(
    id: 'n2',
    type: NotificationType.almostThere,
    title: "Almost There!",
    body: "Only 2 people ahead of you at Glow Beauty Lounge. Get ready!",
    shopName: 'Glow Beauty Lounge',
    time: DateTime.now().subtract(const Duration(minutes: 18)),
  ),
  NotificationModel(
    id: 'n3',
    type: NotificationType.skipped,
    title: "Spot Skipped",
    body: "Your token was skipped at City Hair Craft. You've been moved to the end.",
    shopName: 'City Hair Craft',
    time: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: true,
  ),
  NotificationModel(
    id: 'n4',
    type: NotificationType.promotion,
    title: "Exclusive: 20% Off Today",
    body: "Royal Barber Shop is offering 20% off all services today only.",
    shopName: 'Royal Barber Shop',
    time: DateTime.now().subtract(const Duration(hours: 3)),
    isRead: true,
  ),
];

// ─── Owner's own shops (simulated state) ─────────────────────────────────────

final List<ShopModel> ownerShops = [
  mockShops[0], // Luxe Cuts Studio – active
  mockShops[1], // City Hair Craft – subscription inactive
];
