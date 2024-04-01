import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/Data/categories.dart';
import 'package:shopping_app/Models/grocery_item.dart';
import 'package:shopping_app/Widget/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? error;
  @override
  void initState() {
    //It works when this class created for the first time
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'shopping-app-589c4-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url);
      if (response.body == 'null') {
        //Check at beggining when there is no data in the firebase //if there is an error ex internet disconnect
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (response.statusCode >= 400) {
        //There is an error here
        setState(() {
          error = 'Failed to fetch data. Please try again later';
        });
      }

      final Map<String, dynamic> listData =
          json.decode(response.body); //convert it to list of grocery items

      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        //Check the item title because that what has been sent to the firebase, firstwhere ==first match
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Somthing went wrong, Please try again later';
      });
    }

    //throw Exception('An erroe occurred');
  }

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

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('shopping-app-589c4-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url); //Check if the url is correct
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    Widget contect = const Center(
      child: Text('Nothing here yet!'),
    );
    if (_isLoading) {
      contect = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      contect = Center(
        child: Text(error!),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: contect);
  }
}
