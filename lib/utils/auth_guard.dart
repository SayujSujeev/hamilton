import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/continue_with_google_screen.dart';

/// Widget that checks authentication status before rendering children
class AuthGuard extends StatefulWidget {
  final Widget child;
  final Widget? loadingWidget;
  final bool redirectToLogin;

  const AuthGuard({
    super.key,
    required this.child,
    this.loadingWidget,
    this.redirectToLogin = true,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await _authService.isAuthenticated();
    if (mounted) {
      setState(() {
        _isAuthenticated = isAuth;
        _isLoading = false;
      });

      if (!isAuth && widget.redirectToLogin) {
        _redirectToLogin();
      }
    }
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ContinueWithGoogleScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
    }

    if (!_isAuthenticated && !widget.redirectToLogin) {
      return const Scaffold(
        body: Center(
          child: Text('Authentication required'),
        ),
      );
    }

    return widget.child;
  }
}

/// Route wrapper that checks authentication
class AuthenticatedRoute extends PageRoute {
  final WidgetBuilder builder;
  final AuthService _authService = AuthService();

  AuthenticatedRoute({
    required this.builder,
    super.settings,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FutureBuilder<bool>(
      future: _authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return builder(context);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ContinueWithGoogleScreen(),
              ),
            );
          });

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
