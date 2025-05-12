enum BrewingMethod {
  favorites(
    title: 'Избранное',
    iconPath: 'lib/assets/icons/methods/favorites',
    enumName: 'FAVORITES',
  ),
  created(
    title: 'Мои рецепты',
    iconPath: 'lib/assets/icons/methods/myrecipes',
    enumName: 'CREATED',
  ),
  aeropress(
    title: 'Аэропресс',
    iconPath: 'lib/assets/icons/methods/aeropress',
    enumName: 'AEROPRESS',
  ),
  frenchPress(
    title: 'Френч-пресс',
    iconPath: 'lib/assets/icons/methods/frenchpress',
    enumName: 'FRENCH_PRESS',
  ),
  pourover(
    title: 'Пуровер',
    iconPath: 'lib/assets/icons/methods/pourover',
    enumName: 'POUR_OVER',
  ),
  moka(
    title: 'Мока',
    iconPath: 'lib/assets/icons/methods/mokapot',
    enumName: 'MOKA',
  ),
  dzhezva(
    title: 'Турка',
    iconPath: 'lib/assets/icons/methods/dzhezva',
    enumName: 'DZHEZVA',
  ),
  espresso(
    title: 'Эспрессо',
    iconPath: 'lib/assets/icons/methods/espresso',
    enumName: 'ESPRESSO',
  ),
  custom(
    title: 'Свой метод',
    iconPath: 'lib/assets/icons/methods/custom',
    enumName: 'CUSTOM',
  );

  final String title;
  final String iconPath;
  final String enumName;

  const BrewingMethod({
    required this.title,
    required this.iconPath,
    required this.enumName,
  });

  String getIconPath(bool isDark) {
    return '$iconPath${isDark ? '_dark' : '_light'}.svg';
  }
}
