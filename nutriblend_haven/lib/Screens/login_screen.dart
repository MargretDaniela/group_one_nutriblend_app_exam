

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'main_screen.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const String _baseUrl =
      AppConstants.authApiUrl;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isEmail(String value) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final input = _contactController.text.trim();

      final Map<String, dynamic> body = {
        'password': _passwordController.text,
      };

      if (_isEmail(input)) {
        body['email'] = input;
      } else {
        body['contact'] = input;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] ??
            data['data']?['token'] ??
            data['access_token'] ??
            '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        if (!mounted) return;
        _showBar('Welcome back!', error: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        final message =
            data['message'] ?? 'Login failed. Please try again.';
        if (!mounted) return;
        _showBar(message, error: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showBar(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  color: Color(0xFF2E7D32),
                  strokeWidth: 3.5,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Signing in…',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Please wait',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
     
      body: Stack(
        children: [
       
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      _buildBrand(),
                      const SizedBox(height: 36),
                      _buildHeading(),
                      const SizedBox(height: 32),
                      _buildForm(),
                      const SizedBox(height: 20),
                      _buildRegisterRow(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

         
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/logo.png',
            width: 44,
            height: 44,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NutriBlend',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E7D32),
              ),
            ),
            Text(
              'Premium Health & Nutrition',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue your wellness journey',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Email or Phone Number'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _contactController,
              keyboardType: TextInputType.emailAddress,
           
              enabled: !_isLoading,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF1A1A2E),
                fontWeight: FontWeight.w500,
              ),
              decoration: _inputDecoration(
                hint: 'email@example.com or 07XXXXXXXX',
                icon: Icons.alternate_email_rounded,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email or phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _label('Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
             
              enabled: !_isLoading,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF1A1A2E),
                fontWeight: FontWeight.w500,
              ),
              decoration: _inputDecoration(
                hint: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF9CA3AF),
                    size: 19,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () => setState(
                          () => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                return null;
              },
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
            
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF2E7D32).withOpacity(0.55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  elevation: 0,
                ),
              
                child: Text(
                  'Sign In',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterRow() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Don't have an account? ",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          GestureDetector(
           
            onTap: _isLoading
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    ),
            child: Text(
              'Register',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _isLoading
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A2E),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: const Color(0xFF9CA3AF),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF4CAF50), size: 19),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAF9),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide:
            const BorderSide(color: Color(0xFF4CAF50), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFDC2626), width: 1.8),
      ),
      errorStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
    );
  }
}

// 

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'register_screen.dart';
// import 'main_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _contactController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;

//   static const String _baseUrl =
//       AppConstants.authApiUrl;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _fadeAnim =
//         CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.05),
//       end: Offset.zero,
//     ).animate(
//         CurvedAnimation(parent: _animController, curve: Curves.easeOut));
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     _contactController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   bool _isEmail(String value) {
//     return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);

//     try {
//       final input = _contactController.text.trim();

//       final Map<String, dynamic> body = {
//         'password': _passwordController.text,
//       };

//       if (_isEmail(input)) {
//         body['email'] = input;
//       } else {
//         body['contact'] = input;
//       }

//       final response = await http.post(
//         Uri.parse('$_baseUrl/auth/login'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(body),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final token = data['token'] ??
//             data['data']?['token'] ??
//             data['access_token'] ??
//             '';
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', token);

//         if (!mounted) return;
//         _showBar('Welcome back!', error: false);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const MainScreen()),
//         );
//       } else {
//         final message =
//             data['message'] ?? 'Login failed. Please try again.';
//         if (!mounted) return;
//         _showBar(message, error: true);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       _showBar(e.toString(), error: true);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showBar(String message, {required bool error}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: GoogleFonts.plusJakartaSans(fontSize: 13),
//         ),
//         backgroundColor:
//             error ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
//         behavior: SnackBarBehavior.floating,
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAF9),
//       body: SafeArea(
//         child: FadeTransition(
//           opacity: _fadeAnim,
//           child: SlideTransition(
//             position: _slideAnim,
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 48),
//                   _buildBrand(),
//                   const SizedBox(height: 36),
//                   _buildHeading(),
//                   const SizedBox(height: 32),
//                   _buildForm(),
//                   const SizedBox(height: 20),
//                   _buildRegisterRow(),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBrand() {
//     return Row(
//       children: [
//         Container(
//           width: 44,
//           height: 44,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child:
//               const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
//         ),
//         const SizedBox(width: 12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'NutriBlend',
//               style: GoogleFonts.playfairDisplay(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: const Color(0xFF2E7D32),
//               ),
//             ),
//             Text(
//               'Premium Health & Nutrition',
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 11,
//                 color: const Color(0xFF6B7280),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildHeading() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Welcome Back',
//           style: GoogleFonts.playfairDisplay(
//             fontSize: 30,
//             fontWeight: FontWeight.w700,
//             color: const Color(0xFF1A1A2E),
//             height: 1.15,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'Sign in to continue your wellness journey',
//           style: GoogleFonts.plusJakartaSans(
//             fontSize: 14,
//             color: const Color(0xFF6B7280),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildForm() {
//     return Container(
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF2E7D32).withOpacity(0.05),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _label('Email or Phone Number'),
//             const SizedBox(height: 6),
//             TextFormField(
//               controller: _contactController,
//               keyboardType: TextInputType.emailAddress,
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 14,
//                 color: const Color(0xFF1A1A2E),
//                 fontWeight: FontWeight.w500,
//               ),
//               decoration: _inputDecoration(
//                 hint: 'email@example.com or 07XXXXXXXX',
//                 icon: Icons.alternate_email_rounded,
//               ),
//               validator: (v) {
//                 if (v == null || v.trim().isEmpty) {
//                   return 'Email or phone number is required';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 18),
//             _label('Password'),
//             const SizedBox(height: 6),
//             TextFormField(
//               controller: _passwordController,
//               obscureText: _obscurePassword,
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 14,
//                 color: const Color(0xFF1A1A2E),
//                 fontWeight: FontWeight.w500,
//               ),
//               decoration: _inputDecoration(
//                 hint: 'Enter your password',
//                 icon: Icons.lock_outline_rounded,
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _obscurePassword
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined,
//                     color: const Color(0xFF9CA3AF),
//                     size: 19,
//                   ),
//                   onPressed: () =>
//                       setState(() => _obscurePassword = !_obscurePassword),
//                 ),
//               ),
//               validator: (v) {
//                 if (v == null || v.isEmpty) return 'Password is required';
//                 return null;
//               },
//             ),
//             const SizedBox(height: 26),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _submit,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2E7D32),
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor:
//                       const Color(0xFF2E7D32).withOpacity(0.55),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(13)),
//                   elevation: 0,
//                 ),
//                 child: _isLoading
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2.5,
//                         ),
//                       )
//                     : Text(
//                         'Sign In',
//                         style: GoogleFonts.plusJakartaSans(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.2,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRegisterRow() {
//     return Center(
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             "Don't have an account? ",
//             style: GoogleFonts.plusJakartaSans(
//               fontSize: 13,
//               color: const Color(0xFF6B7280),
//             ),
//           ),
//           GestureDetector(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const RegisterScreen()),
//             ),
//             child: Text(
//               'Register',
//               style: GoogleFonts.plusJakartaSans(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: const Color(0xFF2E7D32),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _label(String text) {
//     return Text(
//       text,
//       style: GoogleFonts.plusJakartaSans(
//         fontSize: 13,
//         fontWeight: FontWeight.w600,
//         color: const Color(0xFF1A1A2E),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration({
//     required String hint,
//     required IconData icon,
//     Widget? suffixIcon,
//   }) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: GoogleFonts.plusJakartaSans(
//         fontSize: 13,
//         color: const Color(0xFF9CA3AF),
//       ),
//       prefixIcon: Icon(icon, color: const Color(0xFF4CAF50), size: 19),
//       suffixIcon: suffixIcon,
//       filled: true,
//       fillColor: const Color(0xFFF8FAF9),
//       contentPadding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.8),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFDC2626)),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide:
//             const BorderSide(color: Color(0xFFDC2626), width: 1.8),
//       ),
//       errorStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
//     );
//   }
// }