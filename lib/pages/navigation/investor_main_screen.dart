
import 'package:flutter/material.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/pages/Investisseur/investisseurAcceuil.dart';
import 'package:startup_mobile/pages/Investisseur/investor_favorites_screen.dart';
import 'package:startup_mobile/pages/Investisseur/investor_profile_screen.dart';
import 'package:startup_mobile/pages/conversation/conversation_list_screen.dart';

class InvestorMainScreen extends StatefulWidget {
  const InvestorMainScreen({super.key});

  @override
  State<InvestorMainScreen> createState() =>
      _InvestorMainScreenState();
}

class _InvestorMainScreenState extends State<InvestorMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    InvestorDashboardScreen(),
    InvestorFavoritesScreen(),
    ConversationListScreen(),
    InvestorProfileScreen(),
  ];

  static const List<String> _labels = [
    'Explorer',
    'Favoris',
    'Messages',
    'Profil',
  ];

  static const List<IconData> _icons = [
    Icons.explore_outlined,
    Icons.favorite_outline_rounded,
    Icons.chat_bubble_outline_rounded,
    Icons.person_outline_rounded,
  ];

  static const List<IconData> _selectedIcons = [
    Icons.explore_rounded,
    Icons.favorite_rounded,
    Icons.chat_bubble_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.background,
          border: Border(
            top: BorderSide(
              color: context.borderColor,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62.h(context),
            child: Row(
              children: List.generate(_labels.length, (index) {
                final selected = _selectedIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_selectedIndex == index) return;

                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        vertical: 5.h(context),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selected
                                ? _selectedIcons[index]
                                : _icons[index],
                            size: 23,
                            color: selected
                                ? context.primary
                                : context.textMuted,
                          ),
                          SizedBox(height: 3.h(context)),
                          Text(
                            _labels[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.normalTextStyle.copyWith(
                              fontSize: 11.sp(context),
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selected
                                  ? context.primary
                                  : context.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvestorPlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InvestorPlaceholderPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.background,
        elevation: 0,
        title: Text(
          title,
          style: context.headingTextStyle.copyWith(
            fontSize: 19.sp(context),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 54.w(context),
                color: context.primary,
              ),
              SizedBox(height: 16.h(context)),
              Text(
                title,
                style: context.headingTextStyle.copyWith(
                  fontSize: 20.sp(context),
                ),
              ),
              SizedBox(height: 8.h(context)),
              Text(
                description,
                textAlign: TextAlign.center,
                style: context.normalTextStyle.copyWith(
                  fontSize: 14.sp(context),
                  color: context.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
