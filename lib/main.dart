import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'today_page.dart';
import 'login_page.dart';
import 'profile.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eokhvxeczqqhqwqjzulp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVva2h2eGVjenFxaHF3cWp6dWxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NDQ1NDQsImV4cCI6MjA2NzAyMDU0NH0.FH2OoVR3Mxz10IHJzIYdY0WmR6oBXyKpeUTE6U4Vgas',
  );

  if (WebViewPlatform.instance == null) {
    // Android
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }

  // Para iOS 
  if (WebViewPlatform.instance == null) {
    WebViewPlatform.instance = WebKitWebViewPlatform();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SupabaseClient supabase;
  late final Stream<AuthState> _authState;

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    _authState = supabase.auth.onAuthStateChange;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SUCO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      routes: {
        '/profile': (context) => const ProfilePage(), 
      },
      home: StreamBuilder<AuthState>(
        stream: _authState,
        builder: (context, snapshot) {
          final session = supabase.auth.currentSession;

          if (session == null) {
            return const LoginPage();
          }

          return const TodayPage();
        },
      ),
    );
  }
}
