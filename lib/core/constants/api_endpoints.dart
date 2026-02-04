/// Supabase table names and storage bucket identifiers.
///
/// Centralizes all Supabase resource names to:
/// - Avoid typos in table/bucket names
/// - Easy refactoring if names change
/// - Clear documentation of backend resources
class ApiEndpoints {
  ApiEndpoints._(); // Private constructor

  // ─── Tables ─────────────────────────────────────────────────────────────────
  
  /// Blogs table name in Supabase.
  static const String blogsTable = 'blogs';
  
  /// Comments table name in Supabase.
  static const String commentsTable = 'comments';

  // ─── Storage ────────────────────────────────────────────────────────────────
  
  /// Storage bucket for blog and profile images.
  static const String blogImagesBucket = 'blog-images';
}
