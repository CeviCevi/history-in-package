import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pytl_backup/data/dto/object_dto.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/app/app_supabase.dart';
import 'package:pytl_backup/domain/services/cache_service.dart';
import 'package:pytl_backup/presentation/app/start_screen/start_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.instance.init();
  await Supabase.initialize(url: appUrl, anonKey: appApiKey);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      tools: const [...DevicePreview.defaultTools],
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ObjectDto())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: TextTheme(bodyMedium: GoogleFonts.manrope()),
          progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryRed),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: appWhite,
          ),
          iconTheme: IconThemeData(color: primaryRed),
          primaryColor: primaryRed,
          scaffoldBackgroundColor: bgcolor,
          snackBarTheme: SnackBarThemeData(
            backgroundColor: primaryRed,
            contentTextStyle: GoogleFonts.manrope(color: appWhite),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(appWhite),
              textStyle: WidgetStateTextStyle.resolveWith(
                (states) => GoogleFonts.manrope(color: primaryRed),
              ),
            ),
          ),
        ),
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        home: StartScreen(),
      ),
    );
  }
}
