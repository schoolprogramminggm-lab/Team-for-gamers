class AppRoutes {
  // Auth routes
  static const String login = '/';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String search = '/search';
  static const String teams = '/teams';
  static const String createTeam = '/teams/create';
  static const String editTeam = '/team/:teamId/edit';
  static const String invitations = '/invitations';
  static const String invitePlayer = '/team/:teamId/invite';
  static const String teamChat = '/team/:teamId/chat';
  static const String chats = '/chats';
  static const String privateChat = '/chat/:chatId';
  
  // Detail routes
  static const String userDetails = '/user/:userId';
  static const String teamDetails = '/team/:teamId';
}
