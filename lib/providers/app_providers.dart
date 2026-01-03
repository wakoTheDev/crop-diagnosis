import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../core/services/localization_service.dart';

class AppProviders {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => LocalizationService()..loadLocale()),
    // Add more providers here as needed
  ];
}
