import 'package:flutter/material.dart';
import 'package:shopping_app/Models/grocery_item.dart';
import 'package:shopping_app/Widget/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    //We added pop and it return the object
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

void _removeItem (GroceryItem item){
  setState(() {
    _groceryItems.remove(item);
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: _groceryItems.isEmpty
            ? const Center(
                child: Text('Nothing here yet!'),
              )
            : ListView.builder(
                itemCount: _groceryItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible( //To delete it takes the ListTile as child, and has onDismissed for removing 
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete),
                      ),
                      onDismissed: (direction) => _removeItem(_groceryItems[index]),
                      key: ValueKey(_groceryItems[index].id),
                      child: ListTile(
                        title: Text(_groceryItems[index].name),
                        leading: Container(
                          color: _groceryItems[index].category.color,
                          height: 30,
                          width: 30,
                        ),
                        trailing: Text(
                          _groceryItems[index].quantity.toString(),
                        ),
                      ));
                }));
  }
}
