import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'checkout_screen.dart';
import 'main_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          cart.cart.isEmpty ? 'Cart' : 'Cart (${cart.cartCount})',
          style: GoogleFonts.playfairDisplay(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          if (cart.cart.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: Text('Clear',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500)),
            ),
        ],
      ),
      body: cart.cart.isEmpty
          ? _EmptyCart(onBrowse: () => context
              .findAncestorStateOfType<MainScreenState>()
              ?.switchTab(1))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    itemCount: cart.cart.length,
                    itemBuilder: (_, i) =>
                        _CartItem(item: cart.cart[i], cart: cart),
                  ),
                ),
                _OrderSummary(cart: cart),
              ],
            ),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear Cart',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text('Remove all items from your cart?',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
            },
            child: Text('Clear',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Empty cart ───────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle),
              child: Icon(Icons.shopping_cart_outlined,
                  size: 48,
                  color: AppTheme.primaryColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            Text('Your cart is empty',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text('Add products to begin your order',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.storefront_outlined, size: 18),
              label: Text('Browse Products',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cart item row ─────────────────────────────────────────────────────────────

class _CartItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final CartProvider cart;
  const _CartItem({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(item['price'].toString()) ?? 0;
    final qty = item['quantity'] as int;
    final lineTotal = price * qty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.local_pharmacy_outlined,
                  color: Color(0xFF4CAF50), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(item['name'],
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      GestureDetector(
                        onTap: () => cart.removeFromCart(item['id'] as int),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(Icons.close_rounded,
                              size: 18, color: Colors.grey[400]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(AppConstants.formatPrice(price),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _QtyControl(item: item, cart: cart),
                      Text(AppConstants.formatPrice(lineTotal),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor)),
                    ],
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

// ─── Qty stepper ──────────────────────────────────────────────────────────────

class _QtyControl extends StatelessWidget {
  final Map<String, dynamic> item;
  final CartProvider cart;
  const _QtyControl({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    final qty = item['quantity'] as int;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => cart.decreaseQuantity(item),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Icon(
                qty == 1
                    ? Icons.delete_outline_rounded
                    : Icons.remove_rounded,
                size: 16,
                color: qty == 1 ? Colors.red : AppTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            height: 30,
            child: Center(
              child: Text('$qty',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ),
          ),
          GestureDetector(
            onTap: () => cart.increaseQuantity(item),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Icon(Icons.add_rounded,
                  size: 16, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order summary ────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  final CartProvider cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.totalAmount;
    final shipping = subtotal > 0 ? 5000.0 : 0.0;
    final total = subtotal + shipping;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2)),
          ),
          _Row('Subtotal', AppConstants.formatPrice(subtotal)),
          const SizedBox(height: 8),
          _Row('Shipping', AppConstants.formatPrice(shipping)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _Row('Total', AppConstants.formatPrice(total),
              isBold: true, valueColor: AppTheme.primaryColor),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        CheckoutScreen(cart: cart.cart)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
              ),
              child: Text('Proceed to Checkout',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _Row(this.label, this.value,
      {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: isBold ? 15 : 13,
                fontWeight:
                    isBold ? FontWeight.w700 : FontWeight.w400,
                color: isBold
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary)),
        Text(value,
            style: GoogleFonts.plusJakartaSans(
                fontSize: isBold ? 16 : 13,
                fontWeight:
                    isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? AppTheme.textPrimary)),
      ],
    );
  }
}
