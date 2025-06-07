import 'package:core/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:settings/settings.dart';
import '../pages/business_card_list_page.dart';
import '../pages/camera_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  void _openBottomSheet(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        useSafeArea: true,
        builder: (BuildContext context) => const SettingsSheet(),
      );

  void _navigateToBusinessCards(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BusinessCardListPage(),
      ),
    );
  }

  void _navigateToCamera(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Opacity(
              opacity: 0.7,
              child: SvgPicture.asset(
                'assets/logo.svg',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),

            // Navigation items
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Scan New Card'),
              onTap: () => _navigateToCamera(context),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('My Business Cards'),
              onTap: () => _navigateToBusinessCards(context),
            ),
            const Divider(),

            const Spacer(),
            BcsButton(
              onPressed: () => _openBottomSheet(context),
              text: AppLocalizations.of(context)!.settings,
            ),
            BcsButton(
              onPressed: () {},
              text: AppLocalizations.of(context)!.logOut,
            ),
          ],
        ),
      ),
    );
  }
}
