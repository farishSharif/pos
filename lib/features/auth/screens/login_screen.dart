import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    // Subtle shifting gradient animation for background
    _bgAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text;
    final password = _passwordController.text;

    final success = await ref.read(authNotifierProvider.notifier).signIn(email, password);

    if (mounted) {
      if (success) {
        CustomSnackBar.showSuccess(context, 'Welcome to SAVOR POS!');
      } else {
        final errorMsg = ref.read(authNotifierProvider).errorMessage ?? 'Login failed';
        CustomSnackBar.showError(context, errorMsg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isLargeScreen(context);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: AnimatedBuilder(
          animation: _bgAnimationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kBg,
                    Color.lerp(kBg, const Color(0xFF1E152A), _bgAnimationController.value)!,
                    kBg,
                  ],
                ),
              ),
              child: child,
            );
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isTablet) {
                return _buildTabletLayout(authState);
              }
              return _buildPhoneLayout(authState);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(AuthState authState) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBrandHeader(),
            const SizedBox(height: 48),
            _buildLoginFormCard(authState),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(AuthState authState) {
    return Row(
      children: [
        // Left Branding Panel
        Expanded(
          flex: 5,
          child: Container(
            color: kSurface.withOpacity(0.3),
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SAVOR POS', style: kDisplayLarge.copyWith(fontSize: 48, color: kAccent)),
                const SizedBox(height: 16),
                Text(
                  'Complete Restaurant Management SaaS. Manage orders, tables, billing, and KDS realtime.',
                  style: kTitle.copyWith(color: kTextSecondary, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 48),
                Center(
                  child: SizedBox(
                    height: 300,
                    child: Lottie.network(
                      'https://assets5.lottiefiles.com/packages/lf20_q5pk6hyq.json',
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.restaurant, size: 120, color: kAccent.withOpacity(0.4));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right Form Panel
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Welcome Back', style: kHeadline.copyWith(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text('Sign in to continue managing your outlet', style: kCaption),
                    const SizedBox(height: 32),
                    _buildLoginFormCard(authState),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        const Icon(Icons.restaurant_menu, size: 64, color: kAccent),
        const SizedBox(height: 16),
        Text('SAVOR POS', style: kDisplayLarge),
        const SizedBox(height: 8),
        Text('Smart Dining, Seamless Service', style: kCaption),
      ],
    );
  }

  Widget _buildLoginFormCard(AuthState authState) {
    return Card(
      color: kSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, color: kTextSecondary),
                  hintText: 'e.g. admin@savor.pos',
                ),
                style: kBody,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: Validators.validatePassword,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: kTextSecondary),
                  hintText: '••••••••',
                ),
                style: kBody,
              ),
              const SizedBox(height: 24),
              AnimatedScale(
                scale: authState.isLoading ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Demo credentials: admin@savor.pos (any password)',
                  style: kCaption.copyWith(fontSize: 10, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
