import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Email field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Correo electrónico',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'tu@email.com',
                              hintStyle: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1E90FF),
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu correo electrónico';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Ingresa un correo electrónico válido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contraseña',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1E90FF),
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 18,
                                  color: const Color(0xFF6B7280),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E90FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Error message
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.errorMessage != null) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                authProvider.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      const SizedBox(height: 16),

                      // Register link
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: const Text(
                          '¿No tienes cuenta? Regístrate',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }
}
