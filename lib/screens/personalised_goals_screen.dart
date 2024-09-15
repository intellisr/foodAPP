import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersonalGoalScreen extends StatefulWidget {
  @override
  _PersonalGoalScreenState createState() => _PersonalGoalScreenState();
}

class _PersonalGoalScreenState extends State<PersonalGoalScreen> {
  final TextEditingController _goalController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGoalType;
  final List<Map<String, dynamic>> _goalPlans = [];

  final List<String> _goalTypes = ['Weight loss', 'Mucscle Gain', 'General'];

  void _submitGoalPlan() {
    if (_selectedDate == null || _selectedGoalType == null || _goalController.text.isEmpty) {
      // Add validation here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Validation: Prevent duplicate goal types for the same date
    bool goalExists = _goalPlans.any((goal) =>
        goal['date'] == _selectedDate && goal['goalType'] == _selectedGoalType);

    if (goalExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This goal type already exists for the selected date')),
      );
      return;
    }

    setState(() {
      _goalPlans.add({
        'date': _selectedDate!,
        'goalType': _selectedGoalType!,
        'goalPlan': _goalController.text,
      });
      _goalPlans.sort((a, b) {
        // Sort by date and then by goal type (Weight loss, Mucscle Gain, General)
        int dateComparison = a['date'].compareTo(b['date']);
        if (dateComparison != 0) return dateComparison;

        return _goalTypes.indexOf(a['goalType']).compareTo(_goalTypes.indexOf(b['goalType']));
      });
    });

    _goalController.clear();
    _selectedDate = null;
    _selectedGoalType = null;
  }

  void _deleteGoalPlan(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Goal Plan'),
        content: Text('Are you sure you want to delete this goal plan?'),
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
                _goalPlans.removeAt(index);
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

  Color _getGoalTypeColor(String goalType) {
    switch (goalType) {
      case 'Weight loss':
        return const Color.fromARGB(255, 175, 255, 128)!;
      case 'Mucscle Gain':
        return const Color.fromARGB(255, 245, 184, 184)!;
      case 'General':
        return Colors.blue[200]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition Goals'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Add a new goal plan
            Text(
              'Add a new goal',
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
              value: _selectedGoalType,
              hint: Text('Select Goal Type'),
              items: _goalTypes.map((String goalType) {
                return DropdownMenuItem<String>(
                  value: goalType,
                  child: Text(goalType),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGoalType = newValue;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _goalController,
              decoration: InputDecoration(
                labelText: 'Enter your goal plan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitGoalPlan,
              child: Text('Submit'),
            ),
            SizedBox(height: 24),

            // Section 2: List of goal plans
            Text(
              'Your Goals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _goalPlans.isEmpty
                  ? Text('No goals yet.')
                  : ListView.builder(
                      itemCount: _goalPlans.length,
                      itemBuilder: (context, index) {
                        final goalPlan = _goalPlans[index];
                        return GestureDetector(
                          onTap: () {
                            // Show detailed view of the goal plan in a card
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                    '${DateFormat('yyyy-MM-dd').format(goalPlan['date'])} (${goalPlan['goalType']})'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Goal: ${goalPlan['goalPlan']}'),
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
                                      _deleteGoalPlan(index);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Card(
                            color: _getGoalTypeColor(goalPlan['goalType']),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                  '${DateFormat('yyyy-MM-dd').format(goalPlan['date'])} (${goalPlan['goalType']})'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteGoalPlan(index);
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

