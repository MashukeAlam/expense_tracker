class ExpenseItem {
  String title;
  DateTime date;
  double amount;

  ExpenseItem({
    required this.title,
    required this.date,
    required this.amount,
  });

  @override
  String toString() {
    return 'ExpenseItem(title: $title, date: $date, amount: $amount)';
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
