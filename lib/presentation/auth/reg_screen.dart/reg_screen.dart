import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/services/cache_service.dart';
import 'package:pytl_backup/domain/services/route_service.dart';
import 'package:pytl_backup/domain/services/user_service.dart';
import 'package:pytl_backup/presentation/app/start_screen/start_screen.dart';
import 'package:pytl_backup/presentation/auth/login_screen/login_screen.dart';
import 'package:pytl_backup/presentation/widgets/buttons/app_button_red.dart';
import 'package:pytl_backup/presentation/widgets/buttons/app_button_white.dart';
import 'package:pytl_backup/presentation/widgets/textfield/app_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Контроллеры для полей ввода
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();
  final preferences = CacheService.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Метод, имитирующий регистрацию
  Future<void> _register() async {
    final login = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (login.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, заполните все поля.")),
      );
      return;
    }
    try {
      final data = await _userService.register(login, email, password);
      if (data == null) {
        throw Exception('User already exists');
      }
      await preferences.setString("email", email);

      // ignore: use_build_context_synchronously
      RouterService.routeFade(context, const StartScreen());
    } catch (e) {
      log(e.toString());
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
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),

              // --- Заголовок ---
              Text(
                "Создайте аккаунт",
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: primaryRed,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Введите данные для регистрации.",
                style: GoogleFonts.manrope(fontSize: 18, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // --- Поля ввода ---
              AppTextField(
                controller: _nameController,
                label: "Ваше имя",
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 20),
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
              AppButtonRed(
                text: "Зарегистрироваться",
                color: primaryRed,
                onTap: _register,
              ),
              const SizedBox(height: 15),
              AppButtonWhite(
                text: "Уже есть аккаунт? Войти",
                color: primaryRed,
                onTap: () => RouterService.routeFade(context, LoginScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
