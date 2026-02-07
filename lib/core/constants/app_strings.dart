/// Centralized string constants for the Roblog application.
///
/// Benefits:
/// - Easy to find and fix typos
/// - Single place to update text
/// - Prepares app for internationalization (i18n)
/// - No magic strings scattered in code
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // ─── App Info ───────────────────────────────────────────────────────────────
  
  /// Application name displayed in app bar and titles.
  static const String appName = 'Roblog';

  // ─── Auth ───────────────────────────────────────────────────────────────────
  
  /// Login page title.
  static const String login = 'Login';
  
  /// Register page title.
  static const String register = 'Register';
  
  /// Logout button/action/confirmation text.
  static const String logout = 'Logout';
  static const String confirmLogout = 'Are you sure you want to logout?';

  
  /// Email field label.
  static const String email = 'Email';
  
  /// Password field label.
  static const String password = 'Password';
  
  /// Confirm password field label.
  static const String confirmPassword = 'Confirm Password';
  
  /// Text for "Don't have an account?" prompt.
  static const String noAccount = "Don't have an account? ";
  
  /// Text for "Already have an account?" prompt.
  static const String hasAccount = 'Already have an account? ';

  // ─── Posts ──────────────────────────────────────────────────────────────────
  
  /// Create post page title.
  static const String createPost = 'Create Post';
  
  /// Edit post page title.
  static const String editPost = 'Edit Post';
  
  /// Delete post action text.
  static const String deletePost = 'Delete Post';
  
  /// Delete confirmation message.
  static const String deletePostConfirm = 'Are you sure you want to delete this post?';
  
  /// Post title field label.
  static const String title = 'Title';
  
  /// Post content field label.
  static const String content = 'Content';
  
  /// Empty posts list message.
  static const String noPosts = 'No posts yet. Create your first one!';
  
  /// Add image button text.
  static const String addImage = 'Add Image';

  // ─── Comments ───────────────────────────────────────────────────────────────
  
  /// Comments section title.
  static const String comments = 'Comments';
  
  /// Add comment placeholder.
  static const String createComment = 'Add a comment...';
  
  /// Empty comments message.
  static const String noComments = 'No comments yet. Be the first!';

  // ─── Profile ────────────────────────────────────────────────────────────────
  
  /// Profile page title.
  static const String profile = 'Profile';
  
  /// Display name field label.
  static const String displayName = 'Display Name';

  // ─── Actions ────────────────────────────────────────────────────────────────
  
  /// Save button text.
  static const String save = 'Save';
  
  /// Cancel button text.
  static const String cancel = 'Cancel';
  
  /// Submit button text.
  static const String submit = 'Submit';
  
  /// Delete button text.
  static const String delete = 'Delete';
  
  /// Edit button text.
  static const String edit = 'Edit';

  // ─── Errors ─────────────────────────────────────────────────────────────────
  
  /// Generic error message.
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  
  /// No internet connection error.
  static const String noInternet = 'No internet connection.';
  
  /// Passwords don't match error.
  static const String passwordsDoNotMatch = 'Passwords do not match.';
}
