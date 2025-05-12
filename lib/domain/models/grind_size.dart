enum GrindSizeType {
  fine(title: "Тонкий"),
  mediumFine(title: "Средне-тонкий"),
  medium(title: "Средний"),
  mediumCoarse(title: "Средне-крупный"),
  coarse(title: "Крупный"),
  none(title: "Не выбрано");

  final String title;
  const GrindSizeType({required this.title});
}
