import 'package:flutter/material.dart';

void main() {
  runApp(BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/expenses': (context) => ExpenseScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 188, 125, 251),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 188, 125, 251),
        title: Text('Budget Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 40),
            ),
            SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(maxWidth: 300),
             
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50)
              ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              'Total:                \$1000', // Replace with actual expense total
              style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8,),
              IconButton(
                onPressed: (){
                Navigator.pushNamed(context, '/expenses');
              }, 
              icon: Icon(Icons.keyboard_double_arrow_down_rounded),
              ),

              ],
            
            )
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 188, 125, 251),
        title: Text('Expenses'),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with actual number of expenses
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Expense ${index + 1}'),
            subtitle: Text('Category'), // Replace with actual category
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$100'), // Replace with actual expense value
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Delete expense logic
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddExpenseDialog(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddExpenseDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Expense Value'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save expense logic
            Navigator.of(context).pop();
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
