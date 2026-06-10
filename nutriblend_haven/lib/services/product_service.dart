import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ProductService {
  ProductService._();

  static const _headers = {'User-Agent': 'NutriBlendApp/1.0 (Flutter)'};

  static String _proxied(String url) =>
      kIsWeb ? 'https://corsproxy.io/?$url' : url;

  /// Fetch a page of products, optionally filtered by search / category.
  static Future<Map<String, dynamic>> fetchProducts({
    int page = 1,
    int? perPage,
    String? search,
    int? categoryId,
  }) async {
    final params = StringBuffer('${AppConstants.baseApiUrl}/products?page=$page');
    if (perPage != null) params.write('&per_page=$perPage');
    if (search != null && search.isNotEmpty) params.write('&search=$search');
    if (categoryId != null) params.write('&category_id=$categoryId');

    final response = await http
        .get(Uri.parse(_proxied(params.toString())), headers: _headers)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'products': body['data'] as List,
        'total': body['meta']['total'] as int,
        'lastPage': body['meta']['last_page'] as int,
      };
    }
    throw HttpException('Server error: ${response.statusCode}');
  }

  /// Debug helper — prints all products to the console.
  static Future<void> fetchProductsSafely() async {
    try {
      final res = await fetchProducts(perPage: 100);
      debugPrint('Total products: ${res['total']}');
      for (final p in res['products'] as List) {
        debugPrint('${p['name']} - ${p['formatted_price']}');
      }
    } on SocketException {
      debugPrint('No internet connection');
    } on TimeoutException {
      debugPrint('Request timed out — try again');
    }
  }
}
