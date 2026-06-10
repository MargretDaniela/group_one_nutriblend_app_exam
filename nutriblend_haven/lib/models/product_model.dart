class Product {
  final int id;
  final String name;
  final double price;
  final String formattedPrice;
  final String? imageUrl;
  final String? description;
  final String? category;
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.formattedPrice,
    this.imageUrl,
    this.description,
    this.category,
    this.inStock = true,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] ?? 0) as int,
      name: (map['name'] ?? 'Product').toString().trim(),
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0,
      formattedPrice: (map['formatted_price'] ?? '') as String,
      imageUrl: map['main_image'] as String?,
      description: map['description'] as String?,
      category: map['category']?['name'] as String?,
      inStock: (map['in_stock'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toCartItem() => {
    'id': id,
    'name': name,
    'price': price,
  };
}
