// import 'package:flutter/material.dart';

// class MealPlannerScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Meal Planner')),
//       body: Center(child: Text('Plan your meals here.')),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MealPlannerScreen extends StatefulWidget {
  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final TextEditingController _mealController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedMealType;
  final List<Map<String, dynamic>> _mealPlans = [];

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  void _submitMealPlan() {
    if (_selectedDate == null || _selectedMealType == null || _mealController.text.isEmpty) {
      // Add validation here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Validation: Prevent duplicate meal types for the same date
    bool mealExists = _mealPlans.any((meal) =>
        meal['date'] == _selectedDate && meal['mealType'] == _selectedMealType);

    if (mealExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This meal type already exists for the selected date')),
      );
      return;
    }

    setState(() {
      _mealPlans.add({
        'date': _selectedDate!,
        'mealType': _selectedMealType!,
        'mealPlan': _mealController.text,
      });
      _mealPlans.sort((a, b) {
        // Sort by date and then by meal type (Breakfast, Lunch, Dinner)
        int dateComparison = a['date'].compareTo(b['date']);
        if (dateComparison != 0) return dateComparison;

        return _mealTypes.indexOf(a['mealType']).compareTo(_mealTypes.indexOf(b['mealType']));
      });
    });

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
            onPressed: () {
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Add a new meal plan
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

            // Section 2: List of meal plans
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
                            // Show detailed view of the meal plan in a card
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
                                  '${DateFormat('yyyy-MM-dd').format(mealPlan['date'])} (${mealPlan['mealType']})'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteMealPlan(index);
                                },
                              ),
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

