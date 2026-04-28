import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topik_go/app/theme/app_colors.dart';
import 'package:topik_go/core/constants/prefs_keys.dart';

class GoalLevelPage extends StatefulWidget {
  const GoalLevelPage({super.key});

  @override
  State<GoalLevelPage> createState() => _GoalLevelPageState();
}

class _GoalLevelPageState extends State<GoalLevelPage> {
  int selectedLevel = 3;

  final descriptions = const {
    3: '초급 / 취업 비자 발급 및 유학을 위한 최소 조건',
    4: '중급 / 한국 대학 졸업 가능 요건',
    5: '중상급 / 전문 분야 취업 가능 요건',
    6: '고급 / 대학원, 전문 직종 취업 등 가능 요건',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedLevel();
  }

  Future<void> _loadSavedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLevel = prefs.getInt(PrefsKeys.targetTopikLevel);

    if (!mounted || savedLevel == null || savedLevel < 3 || savedLevel > 6) {
      return;
    }

    setState(() => selectedLevel = savedLevel);
  }

  Future<void> _saveGoalAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.targetTopikLevel, selectedLevel);
    await prefs.setBool(PrefsKeys.onboardingCompleted, true);

    if (!mounted) return;
    context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('목표 등급을 선택하세요', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ...[3, 4, 5, 6].map((level) {
              final active = selectedLevel == level;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: active ? AppColors.mint : AppColors.border,
                    ),
                  ),
                  title: Text(
                    '$level급',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(descriptions[level] ?? ''),
                  ),
                  trailing: Icon(
                    active ? Icons.check_circle : Icons.circle_outlined,
                    color: active
                        ? AppColors.mintDark
                        : AppColors.textSecondary,
                  ),
                  onTap: () => setState(() => selectedLevel = level),
                ),
              );
            }),
            const Spacer(),
            FilledButton(
              onPressed: _saveGoalAndContinue,
              child: const Text('Next Step'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
