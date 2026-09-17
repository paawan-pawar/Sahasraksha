import 'package:flutter/material.dart';

import '../pages/ai_trailing.dart' as ai_trailing;
import '../pages/alerts_risk.dart' as alerts_risk;
import '../pages/command_center.dart' as command_center;
import '../pages/coverage_intel.dart' as coverage_intel;
import '../pages/intelligence_search.dart' as intelligence_search;
import '../pages/system_admin.dart' as system_admin;
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.commandCenter:
        return _pageRoute(const command_center.CommandCenter(), settings);
      case AppRoutes.aiShadow:
        return _pageRoute(const ai_trailing.AITrailingView(), settings);
      case AppRoutes.aiTrailing:
        return _pageRoute(const ai_trailing.AITrailingView(), settings);
      case AppRoutes.intelligenceSearch:
        return _pageRoute(
          const intelligence_search.IntelligenceSearchView(),
          settings,
        );
      case AppRoutes.alertsRisk:
        return _pageRoute(const alerts_risk.AlertsRiskView(), settings);
      case AppRoutes.coverageIntel:
        return _pageRoute(const coverage_intel.CoverageIntelView(), settings);
      case AppRoutes.systemAdmin:
        return _pageRoute(const system_admin.SystemAdminView(), settings);
      default:
        return _pageRoute(const command_center.CommandCenter(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _pageRoute(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<void>(
      builder: (_) => child,
      maintainState: true,
      settings: settings,
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _currentRoute = AppRoutes.commandCenter;

  static const _routes = [
    AppRoutes.commandCenter,
    AppRoutes.aiShadow,
    AppRoutes.intelligenceSearch,
    AppRoutes.alertsRisk,
    AppRoutes.coverageIntel,
    AppRoutes.systemAdmin,
  ];

  @override
  Widget build(BuildContext context) {
    return AppNavigationScope(
      currentRoute: _currentRoute,
      onSelectRoute: (route) {
        if (_routes.contains(route) && route != _currentRoute) {
          setState(() {
            _currentRoute = route;
          });
        }
      },
      child: IndexedStack(
        index: _routes.indexOf(_currentRoute),
        children: const [
          command_center.CommandCenter(),
          ai_trailing.AITrailingView(),
          intelligence_search.IntelligenceSearchView(),
          alerts_risk.AlertsRiskView(),
          coverage_intel.CoverageIntelView(),
          system_admin.SystemAdminView(),
        ],
      ),
    );
  }
}

class AppNavigationScope extends InheritedWidget {
  const AppNavigationScope({
    required this.currentRoute,
    required this.onSelectRoute,
    required super.child,
    super.key,
  });

  final String currentRoute;
  final ValueChanged<String> onSelectRoute;

  static AppNavigationScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppNavigationScope>();
  }

  @override
  bool updateShouldNotify(AppNavigationScope oldWidget) {
    return currentRoute != oldWidget.currentRoute;
  }
}
