class Product {
  final int id;
  final String name;
  final dynamic price;
  final String? imageUrl;
  final String? description;
  final String? category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
    this.category,
  });
}