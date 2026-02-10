import '../../app/l10n/strings.dart';

/// Quick-add reward template for the parent store editor.
class StoreSuggestion {
  final String name;
  final String icon;
  final int defaultCost;
  final String category;

  const StoreSuggestion({
    required this.name,
    required this.icon,
    required this.defaultCost,
    required this.category,
  });

  static List<StoreSuggestion> get all {
    final s = S.current;
    return [
      // Screen time
      StoreSuggestion(
        name: s.suggExtraBedtime,
        icon: '\uD83D\uDECF\uFE0F',
        defaultCost: 1500,
        category: s.suggCatScreenTime,
      ),
      StoreSuggestion(
        name: s.suggOneEpisode,
        icon: '\uD83D\uDCFA',
        defaultCost: 1200,
        category: s.suggCatScreenTime,
      ),
      StoreSuggestion(
        name: s.suggMovieNight,
        icon: '\uD83C\uDFAC',
        defaultCost: 4000,
        category: s.suggCatScreenTime,
      ),

      // Treats
      StoreSuggestion(
        name: s.suggIceCream,
        icon: '\uD83C\uDF66',
        defaultCost: 2000,
        category: s.suggCatTreats,
      ),
      StoreSuggestion(
        name: s.suggCandyBag,
        icon: '\uD83C\uDF6C',
        defaultCost: 2500,
        category: s.suggCatTreats,
      ),
      StoreSuggestion(
        name: s.suggBakeCake,
        icon: '\uD83C\uDF82',
        defaultCost: 3000,
        category: s.suggCatTreats,
      ),

      // Activities
      StoreSuggestion(
        name: s.suggPlayground,
        icon: '\uD83C\uDFA0',
        defaultCost: 1500,
        category: s.suggCatActivities,
      ),
      StoreSuggestion(
        name: s.suggChooseDinner,
        icon: '\uD83C\uDF5D',
        defaultCost: 2000,
        category: s.suggCatActivities,
      ),
      StoreSuggestion(
        name: s.suggSleepover,
        icon: '\uD83D\uDECC',
        defaultCost: 5000,
        category: s.suggCatActivities,
      ),

      // Money
      StoreSuggestion(
        name: '5 kr',
        icon: '\uD83E\uDE99',
        defaultCost: 1000,
        category: s.suggCatMoney,
      ),
      StoreSuggestion(
        name: '100 kr',
        icon: '\uD83D\uDCB5',
        defaultCost: 15000,
        category: s.suggCatMoney,
      ),
      StoreSuggestion(
        name: s.suggNewBook,
        icon: '\uD83D\uDCDA',
        defaultCost: 3500,
        category: s.suggCatMoney,
      ),
    ];
  }
}
