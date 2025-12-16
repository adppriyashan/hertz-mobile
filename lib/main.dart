import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hertzmobile/config/theme.dart';
import 'package:hertzmobile/providers/auth_provider.dart';
import 'package:hertzmobile/providers/switches_provider.dart';
import 'package:hertzmobile/providers/voice_provider.dart';
import 'package:hertzmobile/services/api_service.dart';
import 'package:hertzmobile/services/token_service.dart';
import 'package:hertzmobile/screens/splash_screen.dart';
import 'package:hertzmobile/screens/auth/login_screen.dart';
import 'package:hertzmobile/screens/auth/register_screen.dart';
import 'package:hertzmobile/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<TokenService>(create: (_) => TokenService(prefs)),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            apiService: context.read<ApiService>(),
            tokenService: context.read<TokenService>(),
          ),
        ),
        ChangeNotifierProvider<SwitchesProvider>(
          create: (context) =>
              SwitchesProvider(apiService: context.read<ApiService>()),
        ),
        ChangeNotifierProvider<VoiceProvider>(
          create: (context) =>
              VoiceProvider(apiService: context.read<ApiService>()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Hertz',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
