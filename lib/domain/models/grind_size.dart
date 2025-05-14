enum GrindSizeType {
  FINE(title: "Тонкий"),
  MEDIUMFINE(title: "Средне-тонкий"),
  MEDIUM(title: "Средний"),
  MEDIUMCOARSE(title: "Средне-крупный"),
  COARSE(title: "Крупный"),
  NONE(title: "Не выбрано");

  final String title;
  const GrindSizeType({required this.title});
}
