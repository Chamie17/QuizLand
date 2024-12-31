import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/services/audio_manager.dart';
import 'package:quizland_app/utils/app_router.dart';
import 'package:quizland_app/utils/app_theme.dart';
import 'package:device_preview/device_preview.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AdaptiveDialog.instance.updateConfiguration(
    macOS: AdaptiveDialogMacOSConfiguration(
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/logo.png',
        ),
      ),
    ),
    defaultStyle: AdaptiveStyle.adaptive
  );

  await AudioManager().init();

  runApp(DevicePreview(
    enabled: !kReleaseMode || kIsWeb,
    isToolbarVisible: !kIsWeb,
    storage: DevicePreviewStorage.preferences(),
    builder: (context) => const MyApp(),
    defaultDevice: Devices.ios.iPhone13ProMax,
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    //* Material App là toàn bộ ứng dụng
    //* theme la phan dinh nghia style, decoration, cua cac widgets trong app
    //* home la phan noi dung cua app

    return MaterialApp.router(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTheme,
      routerConfig: router,
    );
  }
}