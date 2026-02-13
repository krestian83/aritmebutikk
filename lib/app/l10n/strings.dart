import 'locale_service.dart';

/// Lightweight localisation: every user-visible string in one
/// place, switching on the current [AppLocale].
class S {
  const S._();
  static const current = S._();

  bool get _nb => LocaleService.instance.locale.value == AppLocale.nb;

  // ── App name / branding ──────────────────────────────────

  String get appName => _nb ? 'MatteMarked' : 'MathMarket';

  // ── Screen titles ────────────────────────────────────────

  String get selectPlayer => _nb ? 'Velg spiller' : 'Select player';
  String get selectCategory => _nb ? 'Velg kategori' : 'Select category';
  String get store => _nb ? 'Butikk' : 'Store';
  String get editStore => _nb ? 'Rediger butikk' : 'Edit store';

  // ── Category names ───────────────────────────────────────

  String get addition => _nb ? 'Addisjon' : 'Addition';
  String get subtraction => _nb ? 'Subtraksjon' : 'Subtraction';
  String get multiplication => _nb ? 'Ganging' : 'Multiplication';
  String get division => _nb ? 'Deling' : 'Division';

  // ── Difficulty names ─────────────────────────────────────

  String get easy => _nb ? 'Lett' : 'Easy';
  String get medium => _nb ? 'Middels' : 'Medium';
  String get hard => _nb ? 'Vanskelig' : 'Hard';

  // ── Buttons / actions ────────────────────────────────────

  String get play => _nb ? 'Spill' : 'Play';
  String get parentMenu => _nb ? 'Foreldremeny' : 'Parent Menu';
  String get newPlayer => _nb ? 'Ny spiller' : 'New player';
  String get done => _nb ? 'Ferdig' : 'Done';
  String get chooseEmoji => _nb ? 'Velg emoji' : 'Choose emoji';
  String get chooseYourEmoji => _nb ? 'Velg din emoji!' : 'Choose your emoji!';
  String get back => _nb ? 'Tilbake' : 'Back';
  String get cancel => _nb ? 'Avbryt' : 'Cancel';
  String get delete => _nb ? 'Slett' : 'Delete';
  String get save => _nb ? 'Lagre' : 'Save';
  String get addButton => _nb ? 'Legg til' : 'Add';
  String get addItem => _nb ? 'Legg til vare' : 'Add item';
  String get buy => _nb ? 'Kj\u00F8p' : 'Buy';
  String get reset => _nb ? 'Tilbakestill' : 'Reset';
  String get receipts => _nb ? 'Kvitteringer' : 'Receipts';

  // ── Points / score ───────────────────────────────────────

  String get points => _nb ? 'poeng' : 'points';
  String get pointsColon => _nb ? 'Poeng:' : 'Points:';

  String pointsAmount(int n) => '$n ${_nb ? 'poeng' : 'points'}';

  // ── Profile screen ───────────────────────────────────────

  String get createFirstPlayer =>
      _nb ? 'Opprett din f\u00F8rste spiller!' : 'Create your first player!';

  String deleteProfileTitle(String name) =>
      _nb ? 'Slette $name?' : 'Delete $name?';
  String get deleteProfileBody => _nb
      ? 'Alle poeng og emoji blir borte.'
      : 'All points and emoji will be gone.';

  // ── New player screen ────────────────────────────────────

  String get whatsYourName => _nb ? 'Hva heter du?' : "What's your name?";
  String get enterYourName => _nb ? 'Skriv inn navnet ditt' : 'Enter your name';
  String get enterAName => _nb ? 'Skriv inn et navn' : 'Enter a name';
  String get nameAlreadyTaken =>
      _nb ? 'Navnet er allerede i bruk' : 'Name is already taken';

  // ── PIN dialog ───────────────────────────────────────────

  String get createParentCode =>
      _nb ? 'Opprett foreldrekode' : 'Create parent code';
  String get enterParentCode =>
      _nb ? 'Skriv inn foreldrekode' : 'Enter parent code';
  String get pinInstruction => _nb
      ? 'Velg en 4-sifret kode som bare du vet.'
      : 'Choose a 4-digit code only you know.';
  String get confirmPin => _nb ? 'Bekreft PIN' : 'Confirm PIN';
  String get pinMustBe4Digits =>
      _nb ? 'PIN m\u00E5 v\u00E6re 4 siffer.' : 'PIN must be 4 digits.';
  String get pinsDoNotMatch =>
      _nb ? 'PIN-kodene er ikke like.' : "PINs don't match.";
  String get wrongPin => _nb ? 'Feil PIN-kode.' : 'Wrong PIN code.';

  // ── Mute button ─────────────────────────────────────────

  String get enableMusic => _nb ? 'Sl\u00E5 p\u00E5 musikk' : 'Enable music';
  String get muteAll => _nb ? 'Demp alt' : 'Mute all';
  String get unmuteAudio => _nb ? 'Sl\u00E5 p\u00E5 lyd' : 'Turn on sound';

  // ── Game screen ──────────────────────────────────────────

  String get quitAndSave =>
      _nb ? 'Avslutt og lagre poeng' : 'Quit and save points';
  String get maxPointsEarned =>
      _nb ? 'Maks poeng opptjent!' : 'Max points earned!';
  String get tapToPlay => _nb ? 'Trykk for \u00E5 spille' : 'Tap to play';

  // ── Store screen ─────────────────────────────────────────

  String get noItemsInStore =>
      _nb ? 'Ingen varer i butikken.' : 'No items in store.';
  String get noPurchasesYet =>
      _nb ? 'Ingen kj\u00F8p enn\u00E5.' : 'No purchases yet.';

  String notEnoughPoints(int need, int have) => _nb
      ? 'Ikke nok poeng! Trenger $need, har $have.'
      : 'Not enough points! Need $need, have $have.';

  String boughtItem(String name) => _nb ? 'Kj\u00F8pt $name!' : 'Bought $name!';

  // ── Store editor ─────────────────────────────────────────

  String get deleteItemTitle => _nb ? 'Slett vare?' : 'Delete item?';

  String deleteItemConfirm(String name) => _nb
      ? 'Er du sikker p\u00E5 at du vil slette "$name"?'
      : 'Are you sure you want to delete "$name"?';

  String get resetTitle => _nb ? 'Tilbakestill?' : 'Reset?';
  String get resetDescription => _nb
      ? 'Dette fjerner alle endringer og '
            'tilbakestiller til standardvarene.'
      : 'This removes all changes and '
            'resets to the default items.';
  String get resetDefaults =>
      _nb ? 'Tilbakestill standardvarer' : 'Reset default items';
  String get noItemsYet => _nb
      ? 'Ingen varer enn\u00E5.\n'
            'Legg til fra forslagene under!'
      : 'No items yet.\n'
            'Add from the suggestions below!';
  String get suggestions => _nb ? 'Forslag' : 'Suggestions';
  String get tapToAddQuickly =>
      _nb ? 'Trykk for \u00E5 legge til raskt' : 'Tap to add quickly';

  // ── Item form dialog ─────────────────────────────────────

  String get newItem => _nb ? 'Ny vare' : 'New item';
  String get editItem => _nb ? 'Rediger vare' : 'Edit item';
  String get nameField => _nb ? 'Navn' : 'Name';
  String get nameRequired => _nb ? 'Navn er p\u00E5krevd' : 'Name is required';
  String get iconField => _nb ? 'Ikon' : 'Icon';
  String get iconRequired => _nb ? 'Ikon er p\u00E5krevd' : 'Icon is required';
  String get costField => _nb ? 'Poeng' : 'Points';
  String get mustBePositive => _nb ? 'M\u00E5 v\u00E6re > 0' : 'Must be > 0';
  String get categoryField => _nb ? 'Kategori' : 'Category';
  String get selectCategoryDropdown =>
      _nb ? 'Velg kategori' : 'Select category';
  String get newCategoryOption => _nb ? '+ Ny kategori' : '+ New category';
  String get enterNewCategory => _nb ? 'Skriv inn kategori' : 'Enter category';
  String get newCategoryLabel => _nb ? 'Ny kategori' : 'New category';

  // ── Celebration ──────────────────────────────────────────

  List<String> get celebrationMessages => _nb
      ? const [
          'Fantastisk! Du har mestret',
          'Utrolig! Full pott i',
          'Kjempebra! Du klarte alle poeng i',
          'Wow! Alle poeng samlet i',
          'Str\u00E5lende! Du er mester i',
          'Helt rett! Maks poeng i',
          'Imponerende! Du knuste',
          'Superstjerne! Du fullf\u00F8rte',
        ]
      : const [
          "Fantastic! You've mastered",
          'Incredible! Full score in',
          'Amazing! You got all points in',
          'Wow! All points collected in',
          "Brilliant! You're a master of",
          'Perfect! Max points in',
          'Impressive! You crushed',
          'Superstar! You completed',
        ];

  String get tapToContinue =>
      _nb ? 'Trykk for \u00E5 fortsette' : 'Tap to continue';

  // ── Store suggestion names & categories ──────────────────

  String get suggCatScreenTime => _nb ? 'Skjermtid' : 'Screen time';
  String get suggCatTreats => _nb ? 'Godteri' : 'Treats';
  String get suggCatActivities => _nb ? 'Aktiviteter' : 'Activities';
  String get suggCatMoney => _nb ? 'Penger' : 'Money';

  String get suggExtraBedtime => _nb ? 'Ekstra leggetid' : 'Extra bedtime';
  String get suggOneEpisode => _nb ? 'En episode' : 'One episode';
  String get suggMovieNight => _nb ? 'Filmkveld' : 'Movie night';
  String get suggIceCream => _nb ? 'Iskrem' : 'Ice cream';
  String get suggCandyBag => _nb ? 'Godtepose' : 'Candy bag';
  String get suggBakeCake => _nb ? 'Bake kake' : 'Bake a cake';
  String get suggPlayground => _nb ? 'Lekeplass' : 'Playground';
  String get suggChooseDinner => _nb ? 'Velge middag' : 'Choose dinner';
  String get suggSleepover => 'Sleepover';
  String get suggNewBook => _nb ? 'Ny bok' : 'New book';

  // ── Default store item names ─────────────────────────────

  String get defScreenTime15 => _nb ? '15 min skjermtid' : '15 min screen time';
  String get defScreenTime30 => _nb ? '30 min skjermtid' : '30 min screen time';
  String get defScreenTime60 => _nb ? '1 time skjermtid' : '1 hour screen time';
}
