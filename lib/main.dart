import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trailapp/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: 'https://tpwdtjirtslndokjvcmy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwd2R0amlydHNsbmRva2p2Y215Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwMDY4MjAsImV4cCI6MjA4MjU4MjgyMH0.I9jqEqC2faD0SfBKjDcGrLnaLQU-VtW8nJ21cVJKVUk',

  );

  runApp(const TrailApp());
}
