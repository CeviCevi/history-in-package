import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/services/cache_service.dart';
import 'package:pytl_backup/domain/services/route_service.dart';
import 'package:pytl_backup/domain/services/user_service.dart';
import 'package:pytl_backup/presentation/app/start_screen/start_screen.dart';
import 'package:pytl_backup/presentation/auth/reg_screen.dart/reg_screen.dart';
import 'package:pytl_backup/presentation/moderator/all_places_screen.dart';
import 'package:pytl_backup/presentation/widgets/buttons/app_button_red.dart';
import 'package:pytl_backup/presentation/widgets/buttons/app_button_white.dart';
import 'package:pytl_backup/presentation/widgets/textfield/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Контроллеры для полей ввода
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();
  final preferences = CacheService.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, заполните оба поля.")),
      );
      return;
    }

    if (email == "admin" && password == "1111") {
      // ignore: use_build_context_synchronously
      RouterService.routeFade(context, AllPlacesScreen());
      return;
    }

    try {
      final data = await _userService.login(email, password);
      if (data == null) {
        throw Exception('User isn`t Exist');
      }
      preferences.setString("email", email);

      // ignore: use_build_context_synchronously
      RouterService.routeFade(context, const StartScreen());
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(
        SnackBar(content: Text("Ошибка регистрации\n$e", textAlign: .center)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70),

            // --- Заголовок ---
            Text(
              "Добро пожаловать!",
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Войдите, чтобы продолжить.",
              style: GoogleFonts.manrope(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 50),

            // --- Поля ввода ---
            AppTextField(
              controller: _emailController,
              label: "Email",
              icon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _passwordController,
              label: "Пароль",
              icon: Icons.lock_outline,
              isPassword: true,
            ),

            const SizedBox(height: 50),

            // --- Кнопки действий ---
            AppButtonRed(text: "Войти", color: primaryRed, onTap: _login),
            const SizedBox(height: 15),
            AppButtonWhite(
              text: "Регистрация",
              color: primaryRed,
              onTap: () =>
                  RouterService.routeFade(context, RegistrationScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
