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

  static const List<StoreSuggestion> all = [
    // Skjermtid
    StoreSuggestion(
      name: 'Ekstra leggetid',
      icon: '\uD83D\uDECF\uFE0F',
      defaultCost: 1500,
      category: 'Skjermtid',
    ),
    StoreSuggestion(
      name: 'En episode',
      icon: '\uD83D\uDCFA',
      defaultCost: 1200,
      category: 'Skjermtid',
    ),
    StoreSuggestion(
      name: 'Filmkveld',
      icon: '\uD83C\uDFAC',
      defaultCost: 4000,
      category: 'Skjermtid',
    ),

    // Godteri
    StoreSuggestion(
      name: 'Iskrem',
      icon: '\uD83C\uDF66',
      defaultCost: 2000,
      category: 'Godteri',
    ),
    StoreSuggestion(
      name: 'Godtepose',
      icon: '\uD83C\uDF6C',
      defaultCost: 2500,
      category: 'Godteri',
    ),
    StoreSuggestion(
      name: 'Bake kake',
      icon: '\uD83C\uDF82',
      defaultCost: 3000,
      category: 'Godteri',
    ),

    // Aktiviteter
    StoreSuggestion(
      name: 'Lekeplass',
      icon: '\uD83C\uDFA0',
      defaultCost: 1500,
      category: 'Aktiviteter',
    ),
    StoreSuggestion(
      name: 'Velge middag',
      icon: '\uD83C\uDF5D',
      defaultCost: 2000,
      category: 'Aktiviteter',
    ),
    StoreSuggestion(
      name: 'Sleepover',
      icon: '\uD83D\uDECC',
      defaultCost: 5000,
      category: 'Aktiviteter',
    ),

    // Penger
    StoreSuggestion(
      name: '5 kr',
      icon: '\uD83E\uDE99',
      defaultCost: 1000,
      category: 'Penger',
    ),
    StoreSuggestion(
      name: '100 kr',
      icon: '\uD83D\uDCB5',
      defaultCost: 15000,
      category: 'Penger',
    ),
    StoreSuggestion(
      name: 'Ny bok',
      icon: '\uD83D\uDCDA',
      defaultCost: 3500,
      category: 'Penger',
    ),
  ];
}
