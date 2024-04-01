import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart'
    as http; //All contents by this import statement should be warpped by http
import 'package:shopping_app/Data/categories.dart';
import 'package:shopping_app/Models/category.dart';
import 'package:shopping_app/Models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey =
      GlobalKey<FormState>(); //To access the widget from anywhere in the tree

  var _enteredName = '';
  var _quantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!
        .validate()) //Return true if all validator functions pass
    {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final url = Uri.https('shopping-app-589c4-default-rtdb.firebaseio.com',
          'shopping-list.json'); //'shopping-list.json' will create sub folder in firebase
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json' //the format of data
          },
          body: json.encode({
            // We should add encoding to the data
            'name': _enteredName,
            'quantity': _quantity,
            'category': _selectedCategory
                .title //we should spacify the type because object may fail in encoding
          }));

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (!context.mounted) {
        //check if the context change
        return;
      }
      Navigator.of(context).pop(GroceryItem(
          id: responseData['name'],
          name: _enteredName,
          quantity: _quantity,
          category: _selectedCategory)); //Context may change because of async
      // Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _formKey, //To tell flutter to access the validators
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length >= 50) {
                      return 'Must be between 1 and 50 characters';
                    } //If there is an error return this to the user
                    return null;
                  },
                  onSaved: (value) {
                    _enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      //Textfield doesn't work with row so we need expanded widget
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) ==
                                  null || //If it's not a valid number or string it will return null, Parse return the value
                              int.tryParse(value)! <= 0) {
                            return 'Must be a valid, positive number.';
                          } //If there is an error return this to the user
                          return null;
                        },
                        onSaved: (value) {
                          _quantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      //Same above
                      child: DropdownButtonFormField(
                          value: _selectedCategory,
                          items: [
                            for (final category
                                in categories.entries) // Access the items
                              DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(category.value.title)
                                  ],
                                ),
                              )
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          }),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _isSending
                            ? null
                            : () {
                                _formKey.currentState!.reset();
                              },
                        child: const Text('Reset')),
                    ElevatedButton(
                        onPressed: _isSending ? null : _saveItem,
                        child: _isSending
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Add item'))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
