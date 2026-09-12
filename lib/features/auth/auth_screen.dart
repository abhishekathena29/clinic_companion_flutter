import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../widgets/app_button.dart';
import 'auth_provider.dart';
import 'user_type.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppColors.background),
        child: Row(
          children: [
            if (isDesktop)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(gradient: AppColors.gradientHero),
                  child: Padding(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BrandChip(),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: AppDecorations.glass(
                            color: Colors.black.withOpacity(0.1),
                            radius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.isLogin
                                    ? 'Welcome back to\nMentiFit'
                                    : 'Join\nMentiFit',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Your health, scheduled in a click.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 18,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 64 : 24,
                    vertical: 24,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 460),
                    decoration: AppDecorations.card(),
                    padding: const EdgeInsets.all(40),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isDesktop) ...[
                            _BrandChip(isLight: true),
                            const SizedBox(height: 24),
                          ],
                          Text(
                            provider.isLogin ? 'Sign in' : 'Create your account',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.isLogin
                                ? 'Enter your mobile number and 6-digit PIN.'
                                : 'Set up your clinic account with phone & 6-digit PIN.',
                            style: TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (!provider.isLogin) ...[
                            _UserTypeSelector(
                              selected: provider.selectedType,
                              onChanged: provider.updateUserType,
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (!provider.isLogin) ...[
                            TextFormField(
                              onChanged: provider.updateName,
                              validator: (val) {
                                if (provider.isLogin) return null;
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                if (val.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                if (!RegExp(r"^[a-zA-Z\s.'-]+$").hasMatch(val.trim())) {
                                  return 'Please enter a valid name (letters only)';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Full name',
                                prefixIcon: Icon(Icons.person_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            onChanged: provider.updatePhone,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                              if (digits.length != 10) {
                                return 'Mobile number must be exactly 10 digits';
                              }
                              if (!RegExp(r'^[6-9]').hasMatch(digits)) {
                                return 'Enter a valid 10-digit mobile number (starts with 6-9)';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              counterText: '',
                              labelText: 'Phone number',
                              hintText: '10-digit mobile number',
                              prefixIcon: Icon(Icons.phone_rounded),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            obscureText: provider.obscurePassword,
                            onChanged: provider.updatePin,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your 6-digit PIN';
                              }
                              final trimmed = val.trim();
                              if (trimmed.length != 6) {
                                return 'PIN must be exactly 6 digits';
                              }
                              if (!RegExp(r'^[0-9]{6}$').hasMatch(trimmed)) {
                                return 'PIN must contain digits only';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              counterText: '',
                              labelText: provider.isLogin ? '6-digit PIN' : 'Set 6-digit PIN',
                              hintText: '••••••',
                              prefixIcon: const Icon(Icons.lock_rounded),
                              suffixIcon: IconButton(
                                onPressed: provider.togglePasswordVisibility,
                                icon: Icon(
                                  provider.obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          if (!provider.isLogin) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              obscureText: provider.obscureConfirm,
                              onChanged: provider.updateConfirmPin,
                              validator: (val) {
                                if (provider.isLogin) return null;
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please confirm your 6-digit PIN';
                                }
                                if (val.trim() != provider.pin.trim()) {
                                  return 'PINs do not match';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                counterText: '',
                                labelText: 'Confirm 6-digit PIN',
                                hintText: '••••••',
                                prefixIcon: const Icon(Icons.lock_clock_rounded),
                                suffixIcon: IconButton(
                                  onPressed: provider.toggleConfirmVisibility,
                                  icon: Icon(
                                    provider.obscureConfirm
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (provider.error != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.destructive.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.destructive.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.destructive,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      provider.error!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.destructive,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              size: AppButtonSize.large,
                              label: provider.isLogin
                                  ? 'Sign in'
                                  : 'Create account',
                              icon: provider.isLogin
                                  ? Icons.login_rounded
                                  : Icons.check_circle_rounded,
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      await provider.submit();
                                      if (context.mounted &&
                                          provider.isAuthenticated) {
                                        Navigator.of(
                                          context,
                                        ).pushReplacementNamed(
                                          provider.homeRoute,
                                        );
                                      }
                                    },
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (provider.isLoading)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              provider.isLogin
                                  ? 'Need an account?'
                                  : 'Already have an account?',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _formKey.currentState?.reset();
                                provider.toggleMode();
                              },
                              child: Text(
                                provider.isLogin ? 'Create one' : 'Sign in',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(
                              context,
                            ).pushReplacementNamed('/onboarding'),
                            child: const Text(
                              'Back to onboarding',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({this.isLight = false});

  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'MentiFit',
          style: TextStyle(
            color: isLight ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: isLight ? 22 : 24,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isLight
                ? AppColors.primary.withOpacity(0.12)
                : Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isLight
                  ? AppColors.primary.withOpacity(0.25)
                  : Colors.white.withOpacity(0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: isLight ? AppColors.primary : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                'Swasthya Vault',
                style: TextStyle(
                  color: isLight ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserTypeSelector extends StatelessWidget {
  const _UserTypeSelector({required this.selected, required this.onChanged});

  final UserType selected;
  final ValueChanged<UserType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I am a',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TypeCard(
                title: 'Doctor',
                subtitle: 'Manage appointments',
                icon: Icons.medical_services_rounded,
                isActive: selected == UserType.doctor,
                onTap: () => onChanged(UserType.doctor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TypeCard(
                title: 'Patient',
                subtitle: 'Book consultations',
                icon: Icons.personal_injury_rounded,
                isActive: selected == UserType.patient,
                onTap: () => onChanged(UserType.patient),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.mutedForeground;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryLight.withOpacity(0.6)
              : AppColors.muted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

