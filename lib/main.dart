import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const TaskList());
}

class TaskList extends StatefulWidget {
  const TaskList({super.key});
  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  // Theme control variables
  ThemeMode _themeMode = ThemeMode.light;
  bool darkMode = false;

  // Database and text editor control variables
  final dbHelper = DBHelper.instance;
  final TextEditingController nameController = TextEditingController();
  List<Item> items = [];

  void _addItem() async {
    final newItem = Item(name: nameController.text, completed: 0);
    await dbHelper.insertItem(newItem);
    _refreshItems();
    _clearTextFields();
  }

  void _refreshItems() async {
    final data = await dbHelper.getItems();
    setState(() {
      items = data;
    });
  }

  void _clearTextFields() {
    nameController.clear();
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
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
          title: const Text('Task List'),
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Item Name'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addItem,
                      child: const Text('Add Item'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _refreshItems,
                      child: const Text('Refresh List'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Items List:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    Text name = Text(item.name);
                    if (item.completed == 1) {
                      name = Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      );
                    }
                    return ListTile(
                      title: name,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check_box,
                              color: Colors.green,
                            ),
                            onPressed: () async {
                              await dbHelper.markComplete(item);
                              _refreshItems();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await dbHelper.deleteItem(item.id!);
                              _refreshItems();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
