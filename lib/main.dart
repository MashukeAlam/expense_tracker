import 'package:expense_tracker/components/Bar.dart';
import 'package:expense_tracker/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:slide_to_act/slide_to_act.dart';

const String boxName = 'expenses';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Add this line to ensure bindings are initialized
  await Hive.initFlutter();
  await Hive.openBox(boxName);
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<double> expenseListForWeek = [];
  double maxExpenseForWeek = 60;
  late Box expenseBox;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    expenseBox = Hive.box(boxName);
    expenseListForWeek = getWeeklyExpenses();
    maxExpenseForWeek = expenseListForWeek
        .reduce((current, next) => current > next ? current : next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });
  }

  // Function to scroll to the end
  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, // Scroll to the max extent
      duration: const Duration(milliseconds: 500), // Set animation duration
      curve: Curves.easeOut, // Set easing curve
    );
  }

  /// Returns a list of all dates for the current week (Sunday to Saturday).
  List<DateTime> getDatesForThisWeek() {
    DateTime now = DateTime.now();
    int firstDayOfWeek = 0; // 0 for Sunday, 1 for Monday
    int daysToSubtract = now.weekday == 7 ? 0 : now.weekday - firstDayOfWeek;
    DateTime startOfWeek = now.subtract(Duration(days: daysToSubtract));
    List<DateTime> weekDates = [];

    for (int i = 0; i < 7; i++) {
      weekDates.add(startOfWeek.add(Duration(days: i)));
    }

    return weekDates;
  }

  /// Returns a list of total expenses for each day of the current week (Sunday to Saturday).
  List<double> getWeeklyExpenses() {
    List<DateTime> weekDates = getDatesForThisWeek();
    List<double> weeklyExpenses = [];

    for (int i = 0; i < weekDates.length; i++) {
      weeklyExpenses.add(getExpenseByDate(weekDates[i]));
    }

    return weeklyExpenses;
  }

  double getExpenseByDate(DateTime date) {
    String targetDate = date.toIso8601String().substring(0, 10);

    int expenseBoxLength = expenseBox.length;
    double sum = 0;

    for (int i = 0; i < expenseBoxLength; i++) {
      if (expenseBox.getAt(i)['date'].substring(0, 10) == targetDate) {
        sum += expenseBox.getAt(i)['amount'];
      }
    }

    return sum;
  }

  Future<void> _showAddExpenseDialog() async {
    String title = '';
    String amountStr = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Expense",
            style: TextStyle(color: Colors.black45),
          ),
          backgroundColor: Colors.deepPurple[50],
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    decoration: const InputDecoration(
                        hintText: "spent on?",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                        ),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "and how much?",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      amountStr = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
                  child: SlideAction(
                    borderRadius: 18,
                    innerColor: Colors.deepPurple[400],
                    outerColor: Colors.deepPurple[100],
                    sliderButtonIcon: const Icon(
                      Icons.add,
                      color: Colors.white60,
                    ),
                    text: '    Slide to add...',
                    textStyle: const TextStyle(
                      color: Colors.white60,
                      fontSize: 18,
                    ),
                    onSubmit: () {
                      if (title.isNotEmpty && amountStr.isNotEmpty) {
                        final double? amount = double.tryParse(amountStr);
                        if (amount != null) {
                          final newExpense = ExpenseItem(
                            title: title,
                            amount: amount,
                            date: DateTime.now(),
                          );
                          expenseBox.add(newExpense.toMap());
                          setState(() {
                            expenseListForWeek = getWeeklyExpenses();
                            maxExpenseForWeek = expenseListForWeek.reduce(
                                (current, next) =>
                                    current > next ? current : next);
                          });
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.deepPurple[50],
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Bar(
                        amount: expenseListForWeek[0],
                        max: maxExpenseForWeek,
                        text: 'S',
                      ),
                      Bar(
                        amount: expenseListForWeek[1],
                        max: maxExpenseForWeek,
                        text: 'M',
                      ),
                      Bar(
                        amount: expenseListForWeek[2],
                        max: maxExpenseForWeek,
                        text: 'T',
                      ),
                      Bar(
                        amount: expenseListForWeek[3],
                        max: maxExpenseForWeek,
                        text: 'W',
                      ),
                      Bar(
                        amount: expenseListForWeek[4],
                        max: maxExpenseForWeek,
                        text: 'T',
                      ),
                      Bar(
                        amount: expenseListForWeek[5],
                        max: maxExpenseForWeek,
                        text: 'F',
                      ),
                      Bar(
                        amount: expenseListForWeek[6],
                        max: maxExpenseForWeek,
                        text: 'S',
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(15.0), // Set rounded corners
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.grey.withOpacity(0.2), // Add shadow effect
                        spreadRadius: 1,
                        blurRadius: 30,
                        offset:
                            const Offset(0, -1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: expenseBox.length,
                    itemBuilder: (context, index) {
                      final expense = expenseBox.getAt(index);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 10.0), // Add margin between items
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[100], // Set background color
                          borderRadius: BorderRadius.circular(
                              15.0), // Set rounded corners
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 0.0),
                          child: ListTile(
                            title: Text(expense['title']),
                            titleTextStyle: const TextStyle(
                              fontSize: 25,
                              color: Colors.black38,
                            ),
                            subtitle: Text(expense['date'].substring(0, 10) ==
                                    DateTime.now()
                                        .toIso8601String()
                                        .substring(0, 10)
                                ? "Today"
                                : expense['date']
                                    .toIso8601String()
                                    .substring(0, 10)),
                            subtitleTextStyle: const TextStyle(
                              color: Colors.black26,
                            ), // Formatting amount
                            trailing: Text(
                              '৳${expense['amount'].toString()}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black38),
                            ), // Display the date
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(""),
                  ],
                ),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddExpenseDialog,
            tooltip: 'Add Expense',
            child: const Icon(
              Icons.add,
            ),
          ),
        ),
      ),
    );
  }
}
