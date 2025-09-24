import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const WelcomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E90FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.book, size: 32, color: Colors.white),
              ),

              const SizedBox(height: 32),

              // Welcome Text
              const Text(
                'ReadHabit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                'Tu hábito comienza hoy',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              const Text(
                '"Un capítulo al día mantiene la ignorancia alejada"',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Buttons
              Column(
                children: [
                  // Iniciar sesión button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => onNavigate('login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E90FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Registrarse button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () => onNavigate('register'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color.fromARGB(255, 179, 184, 188),
                          width: 2,
                        ),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
