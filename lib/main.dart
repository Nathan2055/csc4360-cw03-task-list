import 'package:flutter/material.dart';
import 'database_helper.dart';

// Here we are using a global variable. You can use something like
// get_it in a production app.
final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the database
  await dbHelper.init();
  runApp(MaterialApp(home: DatabaseApp()));
}

class DatabaseApp extends StatefulWidget {
  @override
  _DatabaseAppState createState() => _DatabaseAppState();
}

class _DatabaseAppState extends State<DatabaseApp> {
  // Theme control variables
  ThemeMode _themeMode = ThemeMode.light;
  bool darkMode = false;

  // Text box control variables
  late TextEditingController _controller;
  String inputString = '';

  @override
  void initState() {
    super.initState();

    // Initialize controller for the text field
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: 'Bob',
      DatabaseHelper.columnAge: 23,
    };
    final id = await dbHelper.insert(row);
    debugPrint('inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    debugPrint('query all rows:');
    for (final row in allRows) {
      debugPrint(row.toString());
    }
  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnName: 'Mary',
      DatabaseHelper.columnAge: 32,
    };
    final rowsAffected = await dbHelper.update(row);
    debugPrint('updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    debugPrint('deleted $rowsDeleted row(s): row $id');
  }

  void _deleteAll() async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.deleteAllRows();
    debugPrint('deleted all $rowsDeleted row(s)');
  }

  void _acceptInput() async {
    setState(() {
      inputString = _controller.text;
    });

    int? idTest = int.tryParse(inputString);
    if (idTest == null) {
      debugPrint('invalid input');
    } else {
      int id = int.parse(inputString);
      var row = await dbHelper.querySpecificRow(id);
      debugPrint('query row $id:');
      debugPrint(row.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('sqflite'),
          actions: <Widget>[
            IconButton(
              // if dark mode, show sun; if light mode, show moon
              icon: darkMode
                  ? const Icon(Icons.sunny)
                  : const Icon(Icons.mode_night),
              // same idea for the tooltip text
              tooltip: darkMode ? 'Light Mode' : 'Dark Mode',
              onPressed: () {
                setState(() {
                  // if on, switch to light mode; if off, switch to dark mode
                  _themeMode = darkMode ? ThemeMode.light : ThemeMode.dark;
                  darkMode = !darkMode;
                });
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(64.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _query,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Query all rows'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Row id to query',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: _acceptInput,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      child: Text('Query'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _insert,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Add a new row'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _update,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Update row 1'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _delete,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete last row'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _deleteAll,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete all rows'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
