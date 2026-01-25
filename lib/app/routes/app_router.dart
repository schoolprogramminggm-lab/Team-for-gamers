import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/public_profile_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/teams/presentation/pages/teams_page.dart';
import '../../features/teams/presentation/pages/create_team_page.dart';
import '../../features/teams/presentation/pages/team_details_page.dart';
import '../../features/teams/presentation/pages/edit_team_page.dart';
import '../../features/teams/presentation/pages/invitations_page.dart';
import '../../features/teams/presentation/pages/invite_player_page.dart';

import '../../features/chat/presentation/pages/team_chat_page.dart';
import '../../features/messages/presentation/pages/chats_page.dart';
import '../../features/messages/presentation/pages/private_chat_page.dart';
import '../../features/messages/data/models/private_chat_model.dart';
import '../../features/teams/data/models/team_model.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    // Auth Routes
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    
    // Main Routes
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      name: 'editProfile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.search,
      name: 'search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: AppRoutes.teams,
      name: 'teams',
      builder: (context, state) => const TeamsPage(),
    ),
    GoRoute(
      path: AppRoutes.createTeam,
      name: 'createTeam',
      builder: (context, state) => const CreateTeamPage(),
    ),
    
    // Detail Routes
    GoRoute(
      path: AppRoutes.userDetails,
      name: 'userDetails',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return PublicProfilePage(userId: userId);
      },
    ),
    GoRoute(
      path: AppRoutes.teamDetails,
      name: 'teamDetails',
      builder: (context, state) {
        final teamId = state.pathParameters['teamId']!;
        return TeamDetailsPage(teamId: teamId);
      },
    ),
    GoRoute(
      path: AppRoutes.teamChat,
      name: 'teamChat',
      builder: (context, state) {
        final team = state.extra as TeamModel;
        return TeamChatPage(team: team);
      },
    ),
    GoRoute(
      path: AppRoutes.editTeam,
      name: 'editTeam',
      builder: (context, state) {
        final teamId = state.pathParameters['teamId']!;
        return EditTeamPage(teamId: teamId);
      },
    ),
    GoRoute(
      path: AppRoutes.invitations,
      name: 'invitations',
      builder: (context, state) => const InvitationsPage(),
    ),
    GoRoute(
      path: AppRoutes.chats,
      name: 'chats',
      builder: (context, state) => const ChatsPage(),
    ),
    GoRoute(
      path: AppRoutes.privateChat,
      name: 'privateChat',
      builder: (context, state) {
        final chat = state.extra as PrivateChatModel;
        return PrivateChatPage(chat: chat);
      },
    ),
    GoRoute(
      path: AppRoutes.invitePlayer,
      name: 'invitePlayer',
      builder: (context, state) {
        final teamId = state.pathParameters['teamId']!;
        return InvitePlayerPage(teamId: teamId);
      },
    ),
  ],


  
  // Error handling
  errorBuilder: (context, state) => const LoginPage(),
);
