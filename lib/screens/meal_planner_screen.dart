import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealPlannerScreen extends StatefulWidget {
  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _mealController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedMealType;
  final List<Map<String, dynamic>> _mealPlans = [];

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  @override
  void initState() {
    super.initState();
    _fetchMealPlans();
  }

  // Fetch meal plans from Firestore
  Future<void> _fetchMealPlans() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('mealplan').where('user', isEqualTo: user?.email).get();
    setState(() {
      _mealPlans.clear();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _mealPlans.add({
          'user':user?.email,
          'date': (data['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
          'mealType': data['mealType'],
          'mealPlan': data['mealPlan'],
        });
      }
      _mealPlans.sort((a, b) {
        int dateComparison = a['date'].compareTo(b['date']);
        if (dateComparison != 0) return dateComparison;
        return _mealTypes.indexOf(a['mealType']).compareTo(_mealTypes.indexOf(b['mealType']));
      });
    });
  }

  // Save meal plan to Firestore
  Future<void> _saveMealPlan(Map<String, dynamic> mealPlan) async {
    await FirebaseFirestore.instance.collection('mealplan').add(mealPlan);
  }

  // Delete meal plan from Firestore
  Future<void> _deleteMealPlanFromFirestore(int index) async {
    String date = DateFormat('yyyy-MM-dd').format(_mealPlans[index]['date']);
    String mealType = _mealPlans[index]['mealType'];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('mealplan')
      .where('user', isEqualTo: user?.email)
      .where('date', isEqualTo: date)
      .where('mealType', isEqualTo: mealType)
      .get();
    for (var doc in querySnapshot.docs) {
      await FirebaseFirestore.instance.collection('mealplan').doc(doc.id).delete();
    }
  }

  void _submitMealPlan() {
    if (_selectedDate == null || _selectedMealType == null || _mealController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    bool mealExists = _mealPlans.any((meal) =>
        meal['date'] == _selectedDate && meal['mealType'] == _selectedMealType);

    if (mealExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This meal type already exists for the selected date')),
      );
      return;
    }

    Map<String, dynamic> newMealPlan = {
      'user':user?.email,
      'date': _selectedDate!,
      'mealType': _selectedMealType!,
      'mealPlan': _mealController.text,
    };

    setState(() {
      _mealPlans.add(newMealPlan);
      _mealPlans.sort((a, b) {
        int dateComparison = a['date'].compareTo(b['date']);
        if (dateComparison != 0) return dateComparison;
        return _mealTypes.indexOf(a['mealType']).compareTo(_mealTypes.indexOf(b['mealType']));
      });
    });

    _saveMealPlan(newMealPlan);
    _mealController.clear();
    _selectedDate = null;
    _selectedMealType = null;
  }

  void _deleteMealPlan(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Meal Plan'),
        content: Text('Are you sure you want to delete this meal plan?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteMealPlanFromFirestore(index);
              setState(() {
                _mealPlans.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Colors.orange[200]!;
      case 'Lunch':
        return Colors.green[200]!;
      case 'Dinner':
        return Colors.blue[200]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Planner'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a new meal plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(_selectedDate == null
                        ? 'Select Date'
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedMealType,
              hint: Text('Select Meal Type'),
              items: _mealTypes.map((String mealType) {
                return DropdownMenuItem<String>(
                  value: mealType,
                  child: Text(mealType),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedMealType = newValue;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _mealController,
              decoration: InputDecoration(
                labelText: 'Enter your meal plan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitMealPlan,
              child: Text('Submit'),
            ),
            SizedBox(height: 24),
            Text(
              'Your Meal Plans',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _mealPlans.isEmpty
                  ? Text('No meal plans yet.')
                  : ListView.builder(
                      itemCount: _mealPlans.length,
                      itemBuilder: (context, index) {
                        final mealPlan = _mealPlans[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                    '${DateFormat('yyyy-MM-dd').format(mealPlan['date'])} (${mealPlan['mealType']})'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Meal: ${mealPlan['mealPlan']}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Close'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteMealPlan(index);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Card(
                            color: _getMealTypeColor(mealPlan['mealType']),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                '${DateFormat('yyyy-MM-dd').format(mealPlan['date'])} (${mealPlan['mealType']})',
                              ),
                              subtitle: Text(mealPlan['mealPlan']),
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