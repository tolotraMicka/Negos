import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _selectedRole = 'chercheur';
  bool _isLoading = false;

  void _register() async {
  final nom = _nomController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  // Validations
  if (nom.isEmpty) {
    _showMessage('⚠️ Veuillez entrer votre nom complet');
    return;
  }
  if (email.isEmpty) {
    _showMessage('⚠️ Veuillez entrer votre adresse email');
    return;
  }
  if (!email.contains('@') || !email.contains('.')) {
    _showMessage('⚠️ Adresse email invalide (ex: nom@gmail.com)');
    return;
  }
  if (password.isEmpty) {
    _showMessage('⚠️ Veuillez entrer un mot de passe');
    return;
  }
  if (password.length < 6) {
    _showMessage('⚠️ Le mot de passe doit contenir au moins 6 caractères');
    return;
  }

  setState(() => _isLoading = true);
  try {
    await _authService.register(
      email: email,
      password: password,
      nom: nom,
      role: _selectedRole,
    );
    _showMessage('✅ Compte créé avec succès !', isSuccess: true);
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'email-already-in-use':
        _showMessage('⚠️ Cet email est déjà utilisé');
        break;
      case 'invalid-email':
        _showMessage('⚠️ Adresse email invalide');
        break;
      case 'weak-password':
        _showMessage('⚠️ Mot de passe trop faible (min. 6 caractères)');
        break;
      default:
        _showMessage('⚠️ Erreur : ${e.message}');
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
              const SizedBox(height: 40),
              Text('Créer un compte',
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              Text('Rejoignez NegoCasa',
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),

              // Nom
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              // Rôle
              Text('Je suis :',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'chercheur'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'chercheur'
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.search,
                                color: _selectedRole == 'chercheur'
                                    ? Colors.white
                                    : Colors.grey),
                            Text('Chercheur',
                                style: TextStyle(
                                    color: _selectedRole == 'chercheur'
                                        ? Colors.white
                                        : Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedRole = 'proprietaire'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'proprietaire'
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.home,
                                color: _selectedRole == 'proprietaire'
                                    ? Colors.white
                                    : Colors.grey),
                            Text('Propriétaire',
                                style: TextStyle(
                                    color: _selectedRole == 'proprietaire'
                                        ? Colors.white
                                        : Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bouton inscription
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("S'inscrire",
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),

              // Lien connexion
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: Text('Déjà un compte ? Se connecter',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}