import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pytl_backup/data/dto/object_dto.dart';
import 'package:pytl_backup/data/models/place_model/mock/place_model_mock.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/services/place_service.dart';
import 'package:pytl_backup/presentation/user/navigation/map_screen/map_screen.dart';
import 'package:pytl_backup/presentation/user/object/detail_object_screen/detail_object_screen.dart';
import 'package:pytl_backup/presentation/widgets/castle_text_field/castle_text_field.dart';

class ObjectScreen extends StatefulWidget {
  const ObjectScreen({super.key});

  @override
  State<ObjectScreen> createState() => _ObjectScreenState();
}

class _ObjectScreenState extends State<ObjectScreen> {
  final _castleController = TextEditingController();

  @override
  void dispose() {
    _castleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ObjectDto>(
      builder: (context, objectDto, child) {
        bool isSearching = objectDto.isSearching;

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),

                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        color: appWhite,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),

                    Positioned(
                      top: 0,
                      right: 0,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 2,
                        width: MediaQuery.of(context).size.width,
                        child: MapScreen(),
                      ),
                    ),

                    isSearching
                        ? DetailObjectScreen(
                            place: objectDto.placeModel ?? placeMockModel,
                          )
                        : Positioned(
                            top: 0,
                            left: 0,
                            child: SizedBox(
                              width: 1,
                              height: 1,
                              child: Center(),
                            ),
                          ),

                    Positioned(
                      top: 10,
                      left: 0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                        child: CastleTextField(
                          controller: _castleController,
                          searhObj: isSearching,
                          searchNewObj: () async {
                            if (_castleController.text.isNotEmpty &&
                                _castleController.text != '') {
                              // *** ИСПРАВЛЕНО: Используем objectDto напрямую ***
                              // final dataProvider = Provider.of<ObjectDto>(context, listen: false); // УДАЛЕНО

                              PlaceService service = PlaceService();
                              var y = await service.searchPlaces(
                                _castleController.text,
                              );

                              if (y.isNotEmpty) {
                                // Используем objectDto
                                objectDto.setPlace(y.first);
                                objectDto.startSearch();
                              } else {
                                objectDto.stopSearch();
                              }
                            }
                          },
                          backToMainMenu: () {
                            objectDto.stopSearch();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
