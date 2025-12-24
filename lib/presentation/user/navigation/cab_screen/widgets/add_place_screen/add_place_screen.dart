import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pytl_backup/data/models/place_model/place_model.dart';
import 'package:pytl_backup/data/models/user_model/user_model.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/services/place_service.dart';
import 'package:pytl_backup/domain/services/user_service.dart';

class AddPlaceModal extends StatefulWidget {
  final UserModel user;
  const AddPlaceModal({super.key, required this.user});

  @override
  State<AddPlaceModal> createState() => _AddPlaceModalState();
}

class _AddPlaceModalState extends State<AddPlaceModal> {
  final _formKey = GlobalKey<FormState>();
  final PlaceService _placeService = PlaceService();
  final UserService _userService = UserService();

  final labelController = TextEditingController();
  final addressController = TextEditingController();
  final aboutController = TextEditingController();
  final typeController = TextEditingController();
  final xController = TextEditingController();
  final yController = TextEditingController();

  String? imageBase64;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) return;

    final bytes =
        result.files.first.bytes ??
        await File(result.files.first.path!).readAsBytes();

    imageBase64 = base64Encode(bytes);

    setState(() {});
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (imageBase64 == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Добавьте изображение")));
      return;
    }

    final place = PlaceModel(
      id: DateTime.now().millisecondsSinceEpoch,
      label: labelController.text,
      address: addressController.text,
      about: aboutController.text,
      typeName: typeController.text,
      oX: double.parse(xController.text),
      oY: double.parse(yController.text),
      imageBit: imageBase64,
      idAR: [],
      idComments: [],
    );
    try {
      var newObject = await _placeService.createPlace(place);
      widget.user.copyWith(
        idMyObject: [...(widget.user.idMyObject ?? []), newObject.id],
      );
      await _userService.updateUser(widget.user);
      //TODO переложить эту работу на бэкэнд

      // ignore: use_build_context_synchronously
      Navigator.pop(context, place);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.99,
      maxChildSize: 1,
      minChildSize: 0.60,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: bgcolor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const Text(
                  "Предложить новую достопримечательность",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _input(label: "Название", controller: labelController),
                      const SizedBox(height: 12),

                      _input(label: "Адрес", controller: addressController),
                      const SizedBox(height: 12),

                      _input(
                        label: "Описание (списки отделяйте знаком минус -)",
                        controller: aboutController,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),

                      _input(label: "Тип объекта", controller: typeController),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _input(
                              label: "Координата X",
                              controller: xController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _input(
                              label: "Координата Y",
                              controller: yController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ----------- IMAGE PICKER CARD-----------
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: appWhite,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (255 * 0.06).toInt(),
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Добавить изображение",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // -------- FULL IMAGE PREVIEW --------
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imageBase64 == null
                                    ? Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.add_photo_alternate,
                                          size: 48,
                                          color: primaryRed,
                                        ),
                                      )
                                    : Image.memory(
                                        base64Decode(imageBase64!),
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                              ),

                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ----------- SUBMIT BUTTON ----------- //
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Отправить",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (v) =>
            v == null || v.trim().isEmpty ? "Обязательное поле" : null,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }
}
