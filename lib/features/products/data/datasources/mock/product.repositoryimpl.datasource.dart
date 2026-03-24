import 'package:pos_terminal/features/categories/domain/models/category.domain.dart';
import 'package:pos_terminal/features/products/domain/models/products.domain.dart';
import 'package:pos_terminal/features/products/domain/repository/products.repository.dart';
import 'package:result_dart/result_dart.dart';

class MockProductRepository extends ProductRepository {
  late final List<Product> _products;

  MockProductRepository() {
    _products = _generateMockProducts();
  }

  List<Product> _generateMockProducts() {
    final categories = [
      const Category(id: '1', name: 'Electronics'),
      const Category(id: '2', name: 'Clothing'),
      const Category(id: '3', name: 'Food & Beverages'),
      const Category(id: '4', name: 'Home & Garden'),
      const Category(id: '5', name: 'Books'),
      const Category(id: '6', name: 'Sports & Outdoors'),
      const Category(id: '7', name: 'Health & Beauty'),
      const Category(id: '8', name: 'Toys & Games'),
    ];

    final productData = [
      (
        'Wireless Headphones Pro',
        'Premium noise-cancelling headphones with 30-hour battery',
        199.99,
      ),
      ('USB-C Cable Pack', 'Set of 3 durable USB-C charging cables', 24.99),
      ('Phone Case Armor', 'Military-grade protective phone case', 34.99),
      (
        'Screen Protector Glass',
        'Tempered glass screen protector with anti-fingerprint coating',
        12.99,
      ),
      (
        'Power Bank 50000mAh',
        'High-capacity power bank with multiple outputs',
        59.99,
      ),
      (
        'Laptop Stand Aluminum',
        'Adjustable aluminum laptop stand for better ergonomics',
        49.99,
      ),
      (
        'Mechanical Keyboard RGB',
        'Gaming mechanical keyboard with RGB backlighting',
        129.99,
      ),
      (
        'Wireless Mouse Pro',
        'Precision wireless mouse with adjustable DPI',
        39.99,
      ),
      ('4K Monitor 27"', 'Ultra-high definition 27-inch 4K monitor', 399.99),
      ('HD Webcam 1080p', 'Professional 1080p webcam with auto-focus', 79.99),
      (
        'Condenser Microphone',
        'Studio-grade condenser microphone with shock mount',
        89.99,
      ),
      (
        'USB 3.0 Hub',
        'Multi-port USB hub with high-speed data transfer',
        29.99,
      ),
      ('HDMI 2.1 Cable', 'Premium HDMI cable supporting 8K resolution', 19.99),
      ('Universal Adapter Set', 'Travel adapter set for worldwide use', 44.99),
      (
        'Fast Phone Charger',
        'Quick charge 65W phone charger with multiple ports',
        54.99,
      ),
      ('LED Desk Lamp', 'Adjustable LED desk lamp with USB charging', 44.99),
      ('Cable Organizer Kit', 'Complete cable management organizer set', 14.99),
      ('Phone Mount Magnetic', 'Strong magnetic phone mount for cars', 15.99),
      ('Portable Cooling Fan', 'USB-powered portable cooling fan', 24.99),
      (
        'External SSD 1TB',
        '1TB portable solid-state drive with fast speeds',
        119.99,
      ),
      (
        'MicroSD Card 256GB',
        '256GB microSD card with high read/write speeds',
        34.99,
      ),
      ('Card Reader Multi', 'Multi-card reader for SD and microSD', 9.99),
      (
        'DisplayPort Cable 2m',
        'High-quality DisplayPort cable for 4K displays',
        14.99,
      ),
      (
        'VGA Cable Premium',
        'Premium VGA cable with gold-plated connectors',
        11.99,
      ),
      (
        'Audio Interface USB',
        'Professional USB audio interface for recording',
        149.99,
      ),
      (
        'Monitor Speaker Pair',
        'Active studio monitor speakers for music production',
        249.99,
      ),
      (
        'Desk Organizer Wood',
        'Wooden desk organizer with multiple compartments',
        34.99,
      ),
      (
        'Keyboard Wrist Rest',
        'Ergonomic wrist rest for extended typing',
        19.99,
      ),
      (
        'Mouse Pad XL',
        'Extra-large gaming mouse pad with non-slip base',
        24.99,
      ),
      (
        'Chair Cushion Memory Foam',
        'Memory foam chair cushion for comfort',
        39.99,
      ),
      ('Desk Mat Leather', 'Premium leather desk mat with mouse pad', 44.99),
      ('Phone Holder Stand', 'Adjustable phone holder for any device', 12.99),
      ('Tablet Stand Foldable', 'Portable foldable tablet stand', 14.99),
      (
        'Tripod Stand Camera',
        'Professional camera tripod with ball head',
        69.99,
      ),
      ('Ring Light LED', 'LED ring light for photography and streaming', 59.99),
      (
        'Portable Speaker Bluetooth',
        'Waterproof Bluetooth portable speaker',
        79.99,
      ),
      ('Action Camera 4K', '4K action camera with waterproof housing', 299.99),
      ('Drone Quadcopter', 'Compact 4K drone with obstacle avoidance', 499.99),
      (
        'Smartwatch Fitness',
        'Smartwatch with fitness tracking and heart rate monitor',
        199.99,
      ),
      (
        'Fitness Tracker Band',
        'Advanced fitness tracker with GPS and water resistance',
        149.99,
      ),
      (
        'Wireless Charger Pad',
        'Fast wireless charging pad for phones and accessories',
        29.99,
      ),
      (
        'Phone Camera Lens',
        'Ultra-wide camera lens for smartphone photography',
        34.99,
      ),
      (
        'Selfie Stick Bluetooth',
        'Bluetooth-enabled selfie stick with remote control',
        24.99,
      ),
      ('Remote Control IR', 'Programmable infrared remote control', 19.99),
      (
        'Smart Light Bulb RGB',
        'WiFi smart bulb with millions of color options',
        14.99,
      ),
      (
        'Smart Plug Outlet',
        'WiFi-enabled smart plug for remote control',
        19.99,
      ),
      (
        'WiFi Router Mesh',
        'Mesh WiFi router system with excellent coverage',
        179.99,
      ),
      (
        'Network Modem Cable',
        'High-speed cable modem for internet connection',
        99.99,
      ),
      ('Ethernet Cable Cat6', 'Professional Cat6 ethernet cable 50ft', 14.99),
      (
        'Network Switch Gigabit',
        '8-port gigabit network switch for reliable connections',
        39.99,
      ),
      (
        'Surge Protector Power Strip',
        'Multi-outlet surge protector with USB ports',
        24.99,
      ),
      (
        'UPS Battery Backup',
        'Uninterruptible power supply with battery backup',
        129.99,
      ),
      (
        'Laptop Messenger Bag',
        'Durable messenger bag with laptop compartment',
        49.99,
      ),
      ('Cable Pouch Storage', 'Organized cable storage pouch', 12.99),
      (
        'Laptop Cooling Pad',
        'Active cooling pad with USB fan for laptops',
        34.99,
      ),
    ];

    List<Product> products = [];
    for (int i = 0; i < productData.length; i++) {
      final (name, description, price) = productData[i];
      final category = categories[i % categories.length];
      products.add(
        Product(
          id: 'PROD_${String.fromCharCode(65 + (i % 26))}${(i ~/ 26) + 1}',
          name: name,
          description: description,
          basePrice: price,
          categories: [category],
        ),
      );
    }

    return products;
  }

  @override
  AsyncResult<Object> delete(String id) async {
    try {
      _products.removeWhere((product) => product.id == id);
      return Success('Product deleted successfully');
    } catch (e) {
      return Failure(Exception('Failed to delete product: $e'));
    }
  }

  @override
  AsyncResult<List<Product>> get() async {
    try {
      return Success(_products);
    } catch (e) {
      return Failure(Exception('Failed to fetch products: $e'));
    }
  }

  @override
  AsyncResult<Product> getById(String id) async {
    try {
      final product = _products.firstWhere((p) => p.id == id);
      return Success(product);
    } catch (e) {
      return Failure(Exception('Product not found: $e'));
    }
  }

  @override
  AsyncResult<Object> update(Product object) async {
    try {
      final index = _products.indexWhere((p) => p.id == object.id);
      if (index == -1) {
        return Failure(Exception('Product not found'));
      }
      _products[index] = object;
      return Success('Product updated successfully');
    } catch (e) {
      return Failure(Exception('Failed to update product: $e'));
    }
  }
}
