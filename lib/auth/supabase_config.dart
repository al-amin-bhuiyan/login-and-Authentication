class SupabaseConfig {
  // ⚠️ IMPORTANT: Replace with your ACTUAL anon key from Supabase Dashboard!
  //
  // HOW TO GET YOUR CORRECT API KEY:
  // 1. Go to: https://supabase.com/dashboard/project/rfmqnbutrutltrsdfgrj/settings/api
  // 2. Find "Project API keys" section
  // 3. Copy the "anon" "public" key (NOT the "service_role" key)
  // 4. It should be a LONG JWT token starting with: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  // 5. Paste it below replacing the placeholder

  static const String supabaseUrl = 'https://rfmqnbutrutltrsdfgrj.supabase.co';

  // ✅ Correct anon public JWT token
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmbXFuYnV0cnV0bHRyc2RmZ3JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0NDM3MjYsImV4cCI6MjA4MDAxOTcyNn0.BOyo2Gxl5FdJVBWGEBWxqxQukSSb4Zu9BUIxhZLue9I';

  // Example of what it should look like (yours will be different):
  // static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmbXFuYnV0cnV0bHRyc2RmZ3JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMwMTczMDEsImV4cCI6MjA0ODU5MzMwMX0.aB1cD2eF3gH4iJ5kL6mN7oP8qR9sT0uV1wX2yZ3';
}

