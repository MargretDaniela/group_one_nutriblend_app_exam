// ignore_for_file: unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const String _baseUrl =
      'https://testing.rasmuspharmaceuticals.com/api/v1';

  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  List<dynamic> _regions = [];
  List<dynamic> _towns = [];

  int? _selectedRegionId;
  String? _selectedRegionName;
  int? _selectedTownId;
  String? _selectedTownName;
  String _deliveryMethod = 'delivery';

  bool _loadingRegions = false;
  bool _loadingTowns = false;
  bool _placingOrder = false;

  @override
  void initState() {
    super.initState();
    _fetchRegions();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchRegions() async {
    setState(() => _loadingRegions = true);

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/regions'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _regions = data['data'] ?? data['regions'] ?? [];
          _loadingRegions = false;
        });
      } else {
        setState(() => _loadingRegions = false);
        _showBar('Failed to load regions. Please try again.', error: true);
      }
    } catch (e) {
      setState(() => _loadingRegions = false);
      _showBar('Network error. Could not load regions.', error: true);
    }
  }

  Future<void> _fetchTowns(int regionId) async {
    setState(() {
      _loadingTowns = true;
      _towns = [];
      _selectedTownId = null;
      _selectedTownName = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/regions/$regionId/towns'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _towns = data['data'] ?? data['towns'] ?? [];
          _loadingTowns = false;
        });
      } else {
        setState(() => _loadingTowns = false);
        _showBar('Failed to load towns. Please try again.', error: true);
      }
    } catch (e) {
      setState(() => _loadingTowns = false);
      _showBar('Network error. Could not load towns.', error: true);
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRegionId == null) {
      _showBar('Please select a region.', error: true);
      return;
    }

    if (_selectedTownId == null) {
      _showBar('Please select a town.', error: true);
      return;
    }

    setState(() => _placingOrder = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        _showBar('Session expired. Please log in again.', error: true);
        setState(() => _placingOrder = false);
        return;
      }

      final items = widget.cart.map((item) {
        return {
          'product_id': item['id'],
          'quantity': item['quantity'],
        };
      }).toList();

      final body = jsonEncode({
        'items': items,
        'delivery_method': _deliveryMethod,
        'delivery_region_id': _selectedRegionId,
        'delivery_town_id': _selectedTownId,
        'delivery_address': _addressController.text.trim(),
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        _showBar('Order placed successfully!', error: false);
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        final message = data['message'] ?? 'Order failed. Please try again.';
        if (!mounted) return;
        _showBar(message, error: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showBar(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _placingOrder = false);
    }
  }

  void _showBar(String message, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        backgroundColor:
            error ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    final number = double.tryParse(price.toString()) ?? 0;
    final formatted = number.toStringAsFixed(0);
    final chars = formatted.split('');
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[i]);
    }
    return 'UGX ${buffer.toString()}';
  }

  double get _orderTotal {
    return widget.cart.fold(0, (sum, item) {
      final price = double.tryParse(item['price'].toString()) ?? 0;
      return sum + (price * (item['quantity'] as int));
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Order Summary'),
          ...widget.cart.map((item) {
            final price = double.tryParse(item['price'].toString()) ?? 0;
            final quantity = item['quantity'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item['name']} x$quantity',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                  Text(
                    _formatPrice(price * quantity),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                _formatPrice(_orderTotal),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Delivery Details'),
            _buildDeliveryMethodSelector(),
            const SizedBox(height: 16),
            _buildRegionDropdown(),
            const SizedBox(height: 16),
            _buildTownDropdown(),
            const SizedBox(height: 16),
            _buildAddressField(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Method',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _deliveryMethod = 'delivery'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _deliveryMethod == 'delivery'
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFF8FAF9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _deliveryMethod == 'delivery'
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Delivery',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _deliveryMethod == 'delivery'
                            ? Colors.white
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _deliveryMethod = 'pickup'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _deliveryMethod == 'pickup'
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFF8FAF9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _deliveryMethod == 'pickup'
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Pickup',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _deliveryMethod == 'pickup'
                            ? Colors.white
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8FAF9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Region',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        _loadingRegions
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    color: Color(0xFF2E7D32),
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : DropdownButtonFormField<int>(
                value: _selectedRegionId,
                hint: Text(
                  'Select a region',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                decoration: _dropdownDecoration(),
                items: _regions.map((region) {
                  final id = region['id'] as int;
                  final name = region['name'] as String;
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  final region = _regions.firstWhere((r) => r['id'] == value);
                  setState(() {
                    _selectedRegionId = value;
                    _selectedRegionName = region['name'];
                    _selectedTownId = null;
                    _selectedTownName = null;
                    _towns = [];
                  });
                  _fetchTowns(value);
                },
                validator: (value) {
                  if (value == null) return 'Please select a region';
                  return null;
                },
              ),
      ],
    );
  }

  Widget _buildTownDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Town',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        _loadingTowns
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    color: Color(0xFF2E7D32),
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : DropdownButtonFormField<int>(
                value: _selectedTownId,
                hint: Text(
                  _selectedRegionId == null
                      ? 'Select a region first'
                      : 'Select a town',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                decoration: _dropdownDecoration(),
                items: _towns.map((town) {
                  final id = town['id'] as int;
                  final name = town['name'] as String;
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: _selectedRegionId == null
                    ? null
                    : (value) {
                        if (value == null) return;
                        final town = _towns.firstWhere((t) => t['id'] == value);
                        setState(() {
                          _selectedTownId = value;
                          _selectedTownName = town['name'];
                        });
                      },
                validator: (value) {
                  if (value == null) return 'Please select a town';
                  return null;
                },
              ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Address',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            hintText: 'Enter your delivery address',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAF9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
            ),
            errorStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your delivery address';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCartSummary(),
            const SizedBox(height: 16),
            _buildDeliveryForm(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _placingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF2E7D32).withOpacity(0.55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  elevation: 0,
                ),
                child: _placingOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Place Order',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}