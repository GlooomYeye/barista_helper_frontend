enum BrewingStepType {
  heatEquipment(
    title: 'Нагреть оборудование',
    iconPath: 'lib/assets/icons/steps/heat.svg',
    enumName: 'HEAT_EQUIPMENT',
  ),
  grindCoffee(
    title: 'Смолоть кофе',
    iconPath: 'lib/assets/icons/steps/grind.svg',
    enumName: 'GRIND_COFFEE',
  ),
  prepareFilter(
    title: 'Подготовить фильтр',
    iconPath: 'lib/assets/icons/steps/filter.svg',
    enumName: 'PREPARE_FILTER',
  ),
  weighCoffee(
    title: 'Взвесить кофе',
    iconPath: 'lib/assets/icons/steps/scale.svg',
    enumName: 'WEIGH_COFFEE',
  ),
  distributeGrounds(
    title: 'Распределить кофе',
    iconPath: 'lib/assets/icons/steps/distribute.svg',
    enumName: 'DISTRIBUTE_GROUNDS',
  ),
  tamp(
    title: 'Утрамбовать',
    iconPath: 'lib/assets/icons/steps/tamp.svg',
    enumName: 'TAMP',
  ),
  bloom(
    title: 'Пролить для цветения',
    iconPath: 'lib/assets/icons/steps/bloom.svg',
    enumName: 'BLOOM',
  ),
  brew(
    title: 'Заварить',
    iconPath: 'lib/assets/icons/steps/brew.svg',
    enumName: 'BREW',
  ),
  pourWater(
    title: 'Налить воду',
    iconPath: 'lib/assets/icons/steps/pour.svg',
    enumName: 'POUR_WATER',
  ),
  stir(
    title: 'Помешать',
    iconPath: 'lib/assets/icons/steps/stir.svg',
    enumName: 'STIR',
  ),
  press(
    title: 'Прижать',
    iconPath: 'lib/assets/icons/steps/press.svg',
    enumName: 'PRESS',
  ),
  wait(
    title: 'Подождать',
    iconPath: 'lib/assets/icons/steps/wait.svg',
    enumName: 'WAIT',
  ),
  removeGrounds(
    title: 'Удалить жмых',
    iconPath: 'lib/assets/icons/steps/remove.svg',
    enumName: 'REMOVE_GROUNDS',
  ),
  transfer(
    title: 'Перелить',
    iconPath: 'lib/assets/icons/steps/transfer.svg',
    enumName: 'TRANSFER',
  ),
  dilute(
    title: 'Разбавить',
    iconPath: 'lib/assets/icons/steps/dilute.svg',
    enumName: 'DILUTE',
  ),
  decorate(
    title: 'Украсить',
    iconPath: 'lib/assets/icons/steps/decorate.svg',
    enumName: 'DECORATE',
  ),
  serve(
    title: 'Подать',
    iconPath: 'lib/assets/icons/steps/serve.svg',
    enumName: 'SERVE',
  ),
  custom(
    title: 'Кастомный',
    iconPath: 'lib/assets/icons/steps/custom.svg',
    enumName: 'CUSTOM',
  );

  final String title;
  final String iconPath;
  final String enumName;

  const BrewingStepType({
    required this.title,
    required this.iconPath,
    required this.enumName,
  });
}
