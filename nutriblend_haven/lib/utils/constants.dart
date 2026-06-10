class AppConstants {
  AppConstants._();

  static const String appTitle = 'NutriBlend';
  static const String welcomeMessage = 'Welcome Back!';
  static const String searchPlaceholder = 'Search vitamins, supplements...';

  static const List<String> categories = [
    'Vitamins',
    'Supplements',
    'Organic',
    'Beauty',
    'Protein',
    'Herbal',
  ];

  static const String baseApiUrl = 'https://admin.rasmuspharmaceuticals.com/api/v1';
  static const String authApiUrl = 'https://testing.rasmuspharmaceuticals.com/api/v1';

  /// Format a numeric price as a UGX string with comma separators.
  static String formatPrice(dynamic price) {
    final number = double.tryParse(price.toString()) ?? 0;
    final formatted = number.toStringAsFixed(0);
    final chars = formatted.split('');
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) buffer.write(',');
      buffer.write(chars[i]);
    }
    return 'UGX ${buffer.toString()}';
  }
}
