import 'package:Final/pages/login_register_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Final/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:open_file/open_file.dart';

class ExpenseEntry {
  final String category;
  final double price;
  ExpenseEntry(this.category, this.price);
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        primarySwatch: Colors.purple, // Change the primary color of the app
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  String category = '';
  double price = 0.0;
  double calculateTotal() {
    double total = 0.0;
    for (var entry in entries) {
      total += entry.price;
    }
    return total;
  }

  void navigateToExpenses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExpensesScreen()),
    );
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  void showAddExpensePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Text(
            'New Entry',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          content: Container(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  onChanged: (value) {
                    category = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Category',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  onChanged: (value) {
                    price = double.tryParse(value) ?? 0.0;
                  },
                  decoration: InputDecoration(
                    hintText: 'Price',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                onPressed: () {
                  if (category != null && price != null) {
                    Navigator.pop(context, ExpenseEntry(category, price));
                  }
                },
                icon: Icon(Icons.check),
                iconSize: 40,
                color: Colors.deepPurple,
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('expenses')
              .add({
            'category': value.category,
            'price': value.price,
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Color.fromARGB(
                255, 197, 132, 250), // Change the background color here
            padding: EdgeInsets.only(top: 40, left: 18, right: 43),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Budget Tracker',
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                IconButton(
                  onPressed: () async {
                    await Auth().signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
                  },
                  icon: Icon(Icons.logout),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Color.fromARGB(
                  255, 197, 132, 250), // Change the background color here
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Icon(
                        Icons.person,
                        size: 200,
                      ),
                    ),
                    Text(
                      'Welcome',
                      style: TextStyle(
                          fontSize: 44,
                          fontFamily: 'MyCustomFont',
                          letterSpacing: 1.0),
                    ),
                    Text(
                      'Back!',
                      style: TextStyle(
                          fontSize: 44,
                          fontFamily: 'MyCustomFont',
                          letterSpacing: 1.0),
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.attach_money),
                              SizedBox(width: 8),
                              Text(
                                'Total Savings',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50)),
                          child: IconButton(
                            icon:
                                Icon(Icons.keyboard_double_arrow_down_outlined),
                            onPressed: () => navigateToExpenses(context),
                            color: Colors.deepPurple,
                            iconSize: 30,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddExpensePopup(context),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        child: Icon(Icons.add, size: 40),
      ),
    );
  }
}

List<ExpenseEntry> entries = [];

class ExpensesScreen extends StatelessWidget {
  String category = '';
  double price = 0.0;
  void deleteEntry(ExpenseEntry entry) {
    entries.remove(entry);
  }

  double calculateTotal() {
    double total = 0.0;
    for (var entry in entries) {
      total += entry.price;
    }
    return total;
  }

  Stream<List<ExpenseEntry>> getExpenseEntriesStream() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return ExpenseEntry(data['category'], data['price']);
        }).toList();
      });
    } else {
      return Stream.value([]);
    }
  }

  Future<void> exportExpensesAsPDF(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'Expenses Report'),
          pw.Paragraph(text: 'Generated on: ${DateTime.now()}'),
          pw.SizedBox(height: 20),
          for (var entry in entries)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(entry.category),
                pw.Text('\$${entry.price.toStringAsFixed(2)}'),
              ],
            ),
        ],
      ),
    );

    final output = await getExternalStorageDirectory();
    final outputFile = File('${output?.path ?? ''}/expenses_report.pdf');

    await outputFile.writeAsBytes(await pdf.save());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export Complete'),
          content: Text('Expense report exported as PDF.'),
          actions: [
            TextButton(
              onPressed: () async {
                final result = await OpenFile.open(outputFile.path);
                print('Open file result: $result');
              },
              child: Text('Open File'),
            ),
          ],
        );
      },
    );
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ExpenseEntry>>(
      stream: getExpenseEntriesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          entries = snapshot.data!;

          return Scaffold(
            body: Column(
              children: [
                Container(
                  color: Color.fromARGB(255, 197, 132, 250),
                  padding: EdgeInsets.only(top: 40, left: 18, right: 43),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          print("IconButton pressed");
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        },
                      ),
                      Text(
                        'Budget Tracker',
                        style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                      IconButton(
                        onPressed: () async {
                          await Auth().signOut();
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ));
                        },
                        icon: Icon(Icons.logout),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Color.fromARGB(
                        255, 197, 132, 250), // Change the background color here
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 80),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 40),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.attach_money),
                                    SizedBox(width: 8),
                                    Text(
                                      'Total:  ${calculateTotal().toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                return ExpenseCard(entries[index], () {
                                  deleteEntry(entries[index]);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () => showAddExpensePopup(context),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  child: Icon(Icons.add, size: 40),
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () => exportExpensesAsPDF(context),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  child: Icon(Icons.picture_as_pdf, size: 30),
                ),
                SizedBox(height: 8),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void showAddExpensePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Text(
            'New Entry',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          content: Container(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  onChanged: (value) {
                    category = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Category',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  onChanged: (value) {
                    price = double.tryParse(value) ?? 0.0;
                  },
                  decoration: InputDecoration(
                    hintText: 'Price',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                onPressed: () {
                  if (category != null && price != null) {
                    Navigator.pop(context, ExpenseEntry(category, price));
                  }
                },
                icon: Icon(Icons.check),
                iconSize: 40,
                color: Colors.deepPurple,
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('expenses')
            .add({
          'category': value.category,
          'price': value.price,
        });
      }
    });
  }
}

class ExpenseCard extends StatelessWidget {
  final ExpenseEntry entry;
  final Function onDelete;
  ExpenseCard(this.entry, this.onDelete);

  Future<void> deleteEntry(BuildContext context) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('expenses')
            .where('category', isEqualTo: entry.category)
            .where('price', isEqualTo: entry.price)
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });
      }
      onDelete();
    } catch (e) {
      print('Error deleting entry: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.category),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        deleteEntry(context);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 300,
            child: Card(
              color: const Color.fromARGB(255, 245, 244, 243),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.category,
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      '\ ${entry.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: 'Budget Tracker',
    theme: ThemeData(
      primarySwatch: Colors.purple,
    ),
    home: HomePage(),
    routes: {
      '/expenses': (context) => ExpensesScreen(),
    },
  ));
}
