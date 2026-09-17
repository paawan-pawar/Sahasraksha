import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'app_router.dart';
import '../widgets/kavach_logo.dart';

class AppSideNavigationBar extends StatelessWidget {
  const AppSideNavigationBar({super.key});

  static const _items = <_NavigationItem>[
    _NavigationItem(Icons.dashboard, 'Command Center', AppRoutes.commandCenter),
    _NavigationItem(Icons.route, 'AI Trailing', AppRoutes.aiShadow),
    _NavigationItem(Icons.search, 'Scene Search', AppRoutes.intelligenceSearch),
    _NavigationItem(Icons.warning, 'Alerts & Risk', AppRoutes.alertsRisk),
    _NavigationItem(Icons.radar, 'Coverage Intel', AppRoutes.coverageIntel),
    _NavigationItem(Icons.settings, 'Admin', AppRoutes.systemAdmin),
  ];

  @override
  Widget build(BuildContext context) {
    final navigation = AppNavigationScope.maybeOf(context);
    final currentRoute = navigation?.currentRoute ??
        ModalRoute.of(context)?.settings.name;

    return Container(
      width: 240,
      height: double.infinity,
      color: const Color(0xFF0A0E17),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Color(0xFFDFE2EF)),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                const KavachLogo(size: 40, padding: EdgeInsets.zero),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IBVAP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDFE2EF),
                      ),
                    ),
                    Text(
                      'Border Security',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFBAC9CC),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF3B494C), height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (final item in _items)
                    _NavigationTile(
                      item: item,
                      active: currentRoute == item.route,
                      onTap: () {
                        if (currentRoute != item.route) {
                          final navigation = AppNavigationScope.maybeOf(context);
                          if (navigation != null) {
                            navigation.onSelectRoute(item.route);
                          } else {
                            Navigator.pushNamed(context, item.route);
                          }
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(this.icon, this.label, this.route);

  final IconData icon;
  final String label;
  final String route;
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Material(
        color: active ? const Color(0xFF262A34) : Colors.transparent,
        child: ListTile(
          leading: Icon(
            item.icon,
            color: active ? const Color(0xFF00DAF3) : const Color(0xFFBAC9CC),
            size: 24,
          ),
          title: Text(
            item.label,
            style: TextStyle(
              fontSize: 13,
              color: active ? const Color(0xFFDFE2EF) : const Color(0xFFBAC9CC),
            ),
          ),
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onTap: onTap,
        ),
      ),
    );
  }
}
