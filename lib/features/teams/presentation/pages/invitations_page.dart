import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team_for_gamers/features/teams/presentation/widgets/invitation_card.dart';
import 'package:team_for_gamers/features/teams/providers/invitation_provider.dart';
import 'package:team_for_gamers/features/teams/providers/team_provider.dart';

/// Страница просмотра приглашений в команды
class InvitationsPage extends ConsumerStatefulWidget {
  const InvitationsPage({super.key});

  @override
  ConsumerState<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends ConsumerState<InvitationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingInvitations = ref.watch(pendingInvitationsProvider);
    final invitationHistory = ref.watch(invitationHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Приглашения'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Входящие (${pendingInvitations.length})',
              icon: const Icon(Icons.inbox),
            ),
            Tab(
              text: 'История (${invitationHistory.length})',
              icon: const Icon(Icons.history),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending Invitations Tab
          _buildInvitationsList(
            invitations: pendingInvitations,
            emptyMessage: 'Нет новых приглашений',
            emptyIcon: Icons.inbox_outlined,
          ),

          // History Tab
          _buildInvitationsList(
            invitations: invitationHistory,
            emptyMessage: 'История приглашений пуста',
            emptyIcon: Icons.history,
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsList({
    required List invitations,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final invitation = invitations[index];
        return InvitationCard(invitation: invitation);
      },
    );
  }
}
