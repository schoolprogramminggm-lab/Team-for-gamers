import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team_for_gamers/core/constants/app_constants.dart';
import 'package:team_for_gamers/core/widgets/custom_button.dart';
import 'package:team_for_gamers/core/widgets/custom_text_field.dart';
import 'package:team_for_gamers/features/teams/data/models/team_model.dart';
import 'package:team_for_gamers/features/teams/providers/team_provider.dart';

/// Страница редактирования команды (только для капитана)
class EditTeamPage extends ConsumerStatefulWidget {
  final String teamId;

  const EditTeamPage({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<EditTeamPage> createState() => _EditTeamPageState();
}

class _EditTeamPageState extends ConsumerState<EditTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedGame;
  int _maxMembers = 5;
  bool _isLoading = false;
  TeamModel? _team;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeForm(TeamModel team) {
    if (_team != null) return; // Already initialized
    
    _team = team;
    _nameController.text = team.name;
    _descriptionController.text = team.description ?? '';
    _selectedGame = team.game;
    _maxMembers = team.maxMembers;
  }

  Future<void> _saveChanges() async {
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
      final repository = ref.read(teamRepositoryProvider);
      
      final updatedTeam = _team!.copyWith(
        name: _nameController.text.trim(),
        game: _selectedGame!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        maxMembers: _maxMembers,
      );

      await repository.updateTeam(updatedTeam);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Команда обновлена!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Обновляем провайдеры
        ref.invalidate(teamDetailsProvider(widget.teamId));
        ref.invalidate(allTeamsProvider);
        
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
    final teamAsyncValue = ref.watch(teamDetailsProvider(widget.teamId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать команду'),
        centerTitle: true,
      ),
      body: teamAsyncValue.when(
        data: (team) {
          if (team == null) {
            return const Center(child: Text('Команда не найдена'));
          }

          _initializeForm(team);

          return SingleChildScrollView(
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
                  const SizedBox(height: 8),
                  
                  // Warning if reducing max members below current count
                  if (_maxMembers < team.memberIds.length) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Нельзя установить меньше текущего количества участников (${team.memberIds.length})',
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  Slider(
                    value: _maxMembers.toDouble(),
                    min: team.memberIds.length.toDouble(), // Минимум = текущее количество
                    max: 10,
                    divisions: (10 - team.memberIds.length),
                    label: _maxMembers.toString(),
                    onChanged: _isLoading ? null : (value) {
                      setState(() => _maxMembers = value.toInt());
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  CustomButton(
                    onPressed: _isLoading ? () {} : _saveChanges,
                    text: 'Сохранить изменения',
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка загрузки: $error'),
        ),
      ),
    );
  }
}
