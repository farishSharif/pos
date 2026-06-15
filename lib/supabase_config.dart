import 'package:flutter_dotenv/flutter_dotenv.dart';

String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';

String get supabaseAnon =>
    dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';

String get appDataSource =>
    (dotenv.env['APP_DATA_SOURCE'] ?? 'mock').trim().toLowerCase();
