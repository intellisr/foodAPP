import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _shoppingListController = TextEditingController();
  DateTime? _selectedDate;
  final List<Map<String, dynamic>> _shoppingLists = [];

  @override
  void initState() {
    super.initState();
    _fetchShoppingList();
  }

  Future<void> _fetchShoppingList() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('shopping_list')
        .where("userId", isEqualTo: user?.uid)
        .get();

    setState(() {
      _shoppingLists.clear();
      querySnapshot.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        _shoppingLists.add(data);
      });
    });
  }


  Future<void> _saveShoppingList() async {
    if (_titleController.text.isEmpty ||
        _shoppingListController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('shopping_list').add({
      'userId': user?.uid,
      'title': _titleController.text,
      'content': _shoppingListController.text,
      'date': _selectedDate,
      'createdAt': Timestamp.now(),
    });

    _titleController.clear();
    _shoppingListController.clear();
    _selectedDate = null;
    _fetchShoppingList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Shopping list saved successfully!")),
    );
  }

  Future<void> _deleteShoppingList(String id) async {
    await FirebaseFirestore.instance.collection('shopping_list').doc(id).delete();
    _fetchShoppingList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Shopping list deleted successfully!")),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  // Function to generate and download PDF
  Future<void> _downloadAsPDF(Map<String, dynamic> shoppingList) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                shoppingList['title'] ?? 'Shopping List',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                shoppingList['content'] ?? '',
                style: pw.TextStyle(fontSize: 18),
              ),
              if (shoppingList['date'] != null)
                pw.Text(
                  "Date: ${DateFormat.yMMMd().format((shoppingList['date'] as Timestamp).toDate())}",
                  style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600),
                ),
            ],
          );
        },
      ),
    );

    // Prompt the user to download or print the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shopping List"), backgroundColor: Colors.redAccent,), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),

            Text(
              'Add New Shopping List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Enter Shopping List Title",
              ),
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date selected'
                        : 'Date: ${DateFormat.yMMMd().format(_selectedDate!)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text("Select Date"),
                ),
              ],
            ),
            
            TextField(
              controller: _shoppingListController,
              decoration: InputDecoration(
                hintText: "Enter your shopping list",
                // labelText: "Enter your shopping list",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: _saveShoppingList,
              child: Text("Save Shopping List"),
            ),

            SizedBox(height: 16),

            Text(
              'Your Shopping Lists',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _shoppingLists.length,
                itemBuilder: (context, index) {
                  final shoppingList = _shoppingLists[index];
                  return Card(
                    color: const Color.fromARGB(255, 197, 248, 240),
                    child: ListTile(
                      title: Text(shoppingList['title'] ?? 'Untitled', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),), 
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(shoppingList['content'] ?? ''),
                          if (shoppingList['date'] != null)
                            Text(
                              "Date: ${DateFormat.yMMMd().format((shoppingList['date'] as Timestamp).toDate())}",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          Text(shoppingList['content'] ?? ''),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.download, color: Colors.blue),
                            onPressed: () => _downloadAsPDF(shoppingList),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteShoppingList(shoppingList['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

