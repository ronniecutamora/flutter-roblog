class Environment {
  // String.fromEnvironment looks for the keys we passed in the .sh script
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zlekdrnaycfrcqxuydsi.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsZWtkcm5heWNmcmNxeHV5ZHNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyNDc4NTYsImV4cCI6MjA4MzgyMzg1Nn0.JDqc7yZLKSq7u0RrBm8BH86SBHROXgiE-5kr5JGedXY',
  );

  // Simple validation to help you debug during development
  static bool get isValid => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
