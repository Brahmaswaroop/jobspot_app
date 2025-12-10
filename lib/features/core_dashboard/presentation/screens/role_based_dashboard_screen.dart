import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobspot_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jobspot_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:jobspot_app/features/seeker_dashboard/presentation/seeker_dashboard_screen.dart';
import 'package:jobspot_app/features/employer_dashboard/presentation/screens/employer_dashboard_screen.dart';
import 'package:jobspot_app/features/admin_dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:jobspot_app/core/constants/user_role.dart';

class RoleBasedDashboardScreen extends StatelessWidget {
  const RoleBasedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          switch (state.user.role) {
            case UserRole.seeker:
              return const SeekerDashboardScreen();
            case UserRole.employer:
              return const EmployerDashboardScreen();
            case UserRole.admin:
              return const AdminDashboardScreen();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
