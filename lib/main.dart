import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jobspot_app/core/constants/user_role.dart';
import 'package:jobspot_app/core/routes/dashboard_router.dart';
import 'package:jobspot_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:jobspot_app/features/auth/presentation/screens/unable_account_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jobspot_app/features/auth/presentation/screens/login_screen.dart';
import 'package:jobspot_app/core/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const JobSpotApp());
}

class JobSpotApp extends StatelessWidget {
  const JobSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobSpot',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RootPage(),
    );
  }
}

final supabase = Supabase.instance.client;

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _loading = true;
  Widget? _home;
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initAuth() async {
    final session = supabase.auth.currentSession;

    if (session == null) {
      _updateHome(const LoginScreen());
    }

    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        final user = data.session?.user;
        if (user != null) {
          _handleAuthStateChange(user);
        } else {
          _updateHome(const LoginScreen());
        }
      },
      onError: (_) {
        _updateHome(const LoginScreen());
      },
    );
  }

  Future<void> _handleAuthStateChange(User user) async {
    try {
      final userProfile = await supabase
          .from('user_profiles')
          .select('role, account_disabled, profile_completed')
          .eq('user_id', user.id)
          .maybeSingle();

      if (userProfile == null) {
        _updateHome(const RoleSelectionScreen());
        return;
      }

      final isDisabled = userProfile['account_disabled'] as bool? ?? false;
      if (isDisabled) {
        _updateHome(UnableAccountPage(userProfile: userProfile));
        return;
      }

      // final isProfileCompleted =
      //     userProfile['profile_completed'] as bool? ?? false;
      final roleStr = userProfile['role'] as String?;
      final UserRole? role = UserRoleExtension.fromDbValue(roleStr!);
      //
      // if (!isProfileCompleted || role == null) {
      //   _updateHome(const RoleSelectionScreen());
      // } else {
      if (navigatorKey.currentState != null &&
          navigatorKey.currentState!.canPop()) {
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      }
      _updateHome(DashboardRouter(role: role));
      // }
    } catch (e) {
      _updateHome(const LoginScreen());
    }
  }

  void _updateHome(Widget screen) {
    if (!mounted) return;

    // Avoid unnecessary rebuilds if we're already on that screen type
    if (_home?.runtimeType == screen.runtimeType && !_loading) return;

    setState(() {
      _home = screen;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _home == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.purple)),
      );
    }
    return _home!;
  }
}
