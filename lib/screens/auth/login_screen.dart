import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  // Validations
  if (email.isEmpty) {
    _showMessage('⚠️ Veuillez entrer votre adresse email');
    return;
  }
  if (!email.contains('@') || !email.contains('.')) {
    _showMessage('⚠️ Adresse email invalide (ex: nom@gmail.com)');
    return;
  }
  if (password.isEmpty) {
    _showMessage('⚠️ Veuillez entrer votre mot de passe');
    return;
  }
  if (password.length < 6) {
    _showMessage('⚠️ Le mot de passe doit contenir au moins 6 caractères');
    return;
  }

  setState(() => _isLoading = true);
  try {
    await _authService.login(email: email, password: password);
    _showMessage('✅ Connexion réussie !', isSuccess: true);
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        _showMessage('⚠️ Aucun compte trouvé avec cet email');
        break;
      case 'wrong-password':
        _showMessage('⚠️ Mot de passe incorrect');
        break;
      case 'invalid-email':
        _showMessage('⚠️ Adresse email invalide');
        break;
      case 'user-disabled':
        _showMessage('⚠️ Ce compte a été désactivé');
        break;
      case 'too-many-requests':
        _showMessage('⚠️ Trop de tentatives, réessayez plus tard');
        break;
      default:
        _showMessage('⚠️ Email ou mot de passe incorrect');
    }
  }
  setState(() => _isLoading = false);
}

void _showMessage(String message, {bool isSuccess = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message,
          style: const TextStyle(color: Colors.white)),
      backgroundColor: isSuccess ? const Color(0xFF2E7D32) : Colors.red[700],
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Icon(Icons.home, size: 80,
                    color: const Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 24),
              Text('Bienvenue !',
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              Text('Connectez-vous à NegoCasa',
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),

              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Mot de passe
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton connexion
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Se connecter',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}