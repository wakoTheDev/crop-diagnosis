import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../core/services/localization_service.dart';
import 'market_provider.dart';
import 'community_provider.dart';
import 'user_provider.dart';

class AppProviders {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => LocalizationService()..loadLocale()),
    ChangeNotifierProvider(create: (_) => MarketProvider()),
    ChangeNotifierProvider(create: (_) => CommunityProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    // Add more providers here as needed
  ];
}
