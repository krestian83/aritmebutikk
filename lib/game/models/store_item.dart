/// En vare tilgjengelig for kjøp i butikken.
class StoreItem {
  final String name;
  final String icon;
  final int cost;
  final String category;

  const StoreItem({
    required this.name,
    required this.icon,
    required this.cost,
    required this.category,
  });

  static const List<StoreItem> all = [
    StoreItem(
      name: '15 min skjermtid',
      icon: '\uD83D\uDCF1',
      cost: 1000,
      category: 'Skjermtid',
    ),
    StoreItem(
      name: '30 min skjermtid',
      icon: '\uD83D\uDCF1',
      cost: 1800,
      category: 'Skjermtid',
    ),
    StoreItem(
      name: '1 time skjermtid',
      icon: '\uD83D\uDCBB',
      cost: 3000,
      category: 'Skjermtid',
    ),
    StoreItem(
      name: '10 kr',
      icon: '\uD83D\uDCB0',
      cost: 2000,
      category: 'Penger',
    ),
    StoreItem(
      name: '20 kr',
      icon: '\uD83D\uDCB0',
      cost: 3500,
      category: 'Penger',
    ),
    StoreItem(
      name: '50 kr',
      icon: '\uD83D\uDCB5',
      cost: 8000,
      category: 'Penger',
    ),
  ];
}
