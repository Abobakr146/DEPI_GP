import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:route_optim/home_page.dart';
import 'package:route_optim/theme_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://aypcapqgacugujyjsbzv.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF5cGNhcHFnYWN1Z3VqeWpzYnp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MDE1NDUsImV4cCI6MjA3OTM3NzU0NX0.EqcxoMkcZ7yGzx4bukgV2LbSnJzekMGDLPwm9pRKr60'
  );
  runApp(const MyApp());
}

final cloud = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomePage(),
    );
  }
}
