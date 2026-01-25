import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team_for_gamers/core/constants/app_constants.dart';
import 'package:team_for_gamers/core/widgets/custom_button.dart';
import 'package:team_for_gamers/core/widgets/custom_text_field.dart';
import 'package:team_for_gamers/features/auth/providers/auth_provider.dart';
import 'package:team_for_gamers/features/profile/presentation/widgets/game_selector.dart';
import 'package:team_for_gamers/features/profile/providers/user_provider.dart';

/// Страница редактирования профиля пользователя
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _steamIdController = TextEditingController();
  
  List<String> _selectedGames = [];
  String? _selectedRank;
  String? _selectedRegion;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _steamIdController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) return;

      final userRepository = ref.read(userRepositoryProvider);
      final existingUser = await userRepository.getUserById(currentUser.uid);
      
      if (existingUser == null) return;

      final updatedUser = existingUser.copyWith(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty 
            ? null 
            : _bioController.text.trim(),
        favoriteGames: _selectedGames,
        rank: _selectedRank,
        region: _selectedRegion,
        steamId: _steamIdController.text.trim().isEmpty
            ? null
            : _steamIdController.text.trim(),
      );

      await userRepository.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Произошла ошибка: $e'),
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
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Пользователь не авторизован')),
      );
    }

    final userAsyncValue = ref.watch(userProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        centerTitle: true,
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Профиль не найден'));
          }

          // Initialize form with user data (only once)
          if (!_isInitialized) {
            _displayNameController.text = user.displayName;
            _bioController.text = user.bio ?? '';
            _selectedGames = List.from(user.favoriteGames);
            _selectedRank = user.rank;
            _selectedRegion = user.region;
            _steamIdController.text = user.steamId ?? '';
            _isInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar placeholder
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Загрузка фото скоро',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Display Name
                  CustomTextField(
                    controller: _displayNameController,
                    labelText: 'Имя пользователя',
                    hintText: 'Введите ваше имя',
                    prefixIcon: Icons.person_outline,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите имя пользователя';
                      }
                      if (value.trim().length < 3) {
                        return 'Имя должно быть не менее 3 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Steam ID
                  CustomTextField(
                    controller: _steamIdController,
                    labelText: 'Steam ID (64-bit)',
                    hintText: 'Введите ваш Steam ID',
                    prefixIcon: Icons.videogame_asset,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  CustomTextField(
                    controller: _bioController,
                    labelText: 'О себе',
                    hintText: 'Расскажите о себе...',
                    prefixIcon: Icons.info_outline,
                    maxLines: 4,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Rank Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRank,
                    decoration: InputDecoration(
                      labelText: 'Ранг',
                      prefixIcon: const Icon(Icons.emoji_events),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: const Text('Выберите ранг'),
                    items: RankConstants.ranks.map((rank) {
                      return DropdownMenuItem(
                        value: rank,
                        child: Text(rank),
                      );
                    }).toList(),
                    onChanged: _isLoading ? null : (value) {
                      setState(() => _selectedRank = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Region Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    decoration: InputDecoration(
                      labelText: 'Регион',
                      prefixIcon: const Icon(Icons.public),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: const Text('Выберите регион'),
                    items: RegionConstants.regions.map((region) {
                      return DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                    onChanged: _isLoading ? null : (value) {
                      setState(() => _selectedRegion = value);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Game Selector
                  GameSelector(
                    selectedGames: _selectedGames,
                    onChanged: (games) {
                      if (!_isLoading) {
                        setState(() => _selectedGames = games);
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  CustomButton(
                    onPressed: _isLoading ? () {} : _saveProfile,
                    text: 'Сохранить изменения',
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка загрузки профиля: $error'),
        ),
      ),
    );
  }
}
