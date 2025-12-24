import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pytl_backup/data/models/user_model/user_model.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/repository/user_repository.dart';
import 'package:pytl_backup/domain/services/cache_service.dart';

class UserEditScreen extends StatefulWidget {
  final UserModel user;

  const UserEditScreen({super.key, required this.user});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final TextEditingController loginController = TextEditingController();
  late String email;
  String? imageLink;

  final UserRepository _userService = UserRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserFromWidget();
  }

  void _loadUserFromWidget() {
    loginController.text = widget.user.login;
    email = widget.user.email;
    imageLink = widget.user.imageBit;
  }

  Future<void> _saveChangesToBackend() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = UserModel(
        login: loginController.text,
        email: email,
        imageBit: imageLink,

        // --- Сохраняем поля, которые не редактировались ---
        id: widget.user.id,
        password: widget.user.password,
        role: widget.user.role,
        idSavedPlaces: widget.user.idSavedPlaces,
        idWins: widget.user.idWins,
        idVisitedPlaces: widget.user.idVisitedPlaces,
        idMyComments: widget.user.idMyComments,
        idMyObject: widget.user.idMyObject,
      );

      await _userService.updateUser(updatedUser);

      final prefs = CacheService.instance;
      await prefs.setString('login', updatedUser.login);
      if (updatedUser.imageBit != null) {
        await prefs.setString("image", updatedUser.imageBit!);
      } else {
        await prefs.remove("image");
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Данные успешно сохранены")));
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка сохранения: ${e.toString()}")),
      );
    }
  }

  /// ---------- PICK IMAGE (ANDROID + WINDOWS) ----------
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) return;

    final bytes = result.files.first.bytes;

    if (bytes != null) {
      imageLink = base64Encode(bytes);
    } else {
      final file = File(result.files.first.path!);
      final fileBytes = await file.readAsBytes();
      imageLink = base64Encode(fileBytes);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Редактирование профиля"),
        centerTitle: true,
        backgroundColor: primaryRed,
        foregroundColor: appWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ----------- AVATAR -----------
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade300,
                child: imageLink != null
                    ? ClipOval(child: Image.network(imageLink!))
                    : const Icon(Icons.add_a_photo, size: 36),
              ),
            ),

            const SizedBox(height: 20),

            // ----------- LOGIN -----------
            TextField(
              controller: loginController,
              decoration: InputDecoration(
                labelText: "Логин",
                labelStyle: GoogleFonts.manrope(color: Colors.grey),
                floatingLabelStyle: GoogleFonts.manrope(
                  color: primaryRed,
                  fontWeight: FontWeight.bold,
                ),
                focusColor: primaryRed,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: primaryRed.withAlpha(200),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryRed, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ----------- EMAIL (Неизменяемое поле) -----------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Почта: ", style: GoogleFonts.manrope(fontSize: 18)),
                    Text(
                      email,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Неизменяемое поле",
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ----------- SAVE BUTTON -----------
            Material(
              elevation: 1,
              color: primaryRed.withOpacity(_isLoading ? 0.7 : 1.0),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: _saveChangesToBackend,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: appWhite,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "Сохранить",
                            style: TextStyle(
                              color: appWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
