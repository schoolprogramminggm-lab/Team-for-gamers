import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team_for_gamers/core/constants/app_constants.dart';
import 'package:team_for_gamers/core/widgets/custom_button.dart';
import 'package:team_for_gamers/core/widgets/custom_text_field.dart';
import 'package:team_for_gamers/features/auth/providers/auth_provider.dart';
import 'package:team_for_gamers/features/teams/providers/team_provider.dart';

/// Страница создания новой команды
class CreateTeamPage extends ConsumerStatefulWidget {
  const CreateTeamPage({super.key});

  @override
  ConsumerState<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends ConsumerState<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedGame;
  int _maxMembers = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGame == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите игру'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) return;

      final repository = ref.read(teamRepositoryProvider);
      
      await repository.createTeam(
        name: _nameController.text.trim(),
        game: _selectedGame!,
        captainId: currentUser.uid,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        maxMembers: _maxMembers,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Команда успешно создана!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Обновляем список команд
        ref.invalidate(allTeamsProvider);
        ref.invalidate(userTeamsProvider);
        
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать команду'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Team Name
              CustomTextField(
                controller: _nameController,
                labelText: 'Название команды',
                hintText: 'Введите название',
                prefixIcon: Icons.group,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название команды';
                  }
                  if (value.trim().length < 3) {
                    return 'Минимум 3 символа';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Game Selection
              DropdownButtonFormField<String>(
                value: _selectedGame,
                decoration: InputDecoration(
                  labelText: 'Игра',
                  prefixIcon: const Icon(Icons.sports_esports),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text('Выберите игру'),
                items: GameConstants.popularGames.map((game) {
                  return DropdownMenuItem(
                    value: game,
                    child: Text(game),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (value) {
                  setState(() => _selectedGame = value);
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Описание (необязательно)',
                hintText: 'Расскажите о вашей команде...',
                prefixIcon: Icons.description,
                maxLines: 4,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Max Members Slider
              Text(
                'Максимум участников: $_maxMembers',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _maxMembers.toDouble(),
                min: 2,
                max: 10,
                divisions: 8,
                label: _maxMembers.toString(),
                onChanged: _isLoading ? null : (value) {
                  setState(() => _maxMembers = value.toInt());
                },
              ),
              const SizedBox(height: 32),

              // Create Button
              CustomButton(
                onPressed: _isLoading ? () {} : _createTeam,
                text: 'Создать команду',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
