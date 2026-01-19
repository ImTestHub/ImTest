import 'package:go_router/go_router.dart';
import 'package:im_test/pages/app_shell/page.dart';
import 'package:im_test/pages/home/page.dart';
import 'package:im_test/pages/login/page.dart';

final GoRouter router = GoRouter(
  initialLocation: "/",
  routes: [
    ShellRoute(
      builder: (context, state, page) => AppShell(page: page),
      routes: [
        GoRoute(path: '/', builder: (_, state) => const LoginPage()),
        GoRoute(path: '/home', builder: (_, state) => const HomePage()),
      ],
    ),
  ],
);
