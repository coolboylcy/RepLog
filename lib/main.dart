import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/service_locator.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 强制竖屏
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 初始化服务
  final wrapWithServices = await ServiceLocator.initialize();

  runApp(wrapWithServices(const RepLogApp()));
}
