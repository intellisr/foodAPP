import 'package:flutter/material.dart';

class BMICalculatorScreen extends StatefulWidget {
  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  String result = '';
  Color resultColor = Colors.black;

  void calculateBMI() {
    double? weight = double.tryParse(weightController.text);
    double? height = double.tryParse(heightController.text);

    if (weight != null && height != null && weight > 0 && height > 0) {
      double bmi = weight / (height * height);
      setState(() {
        result = 'Your BMI is ${bmi.toStringAsFixed(2)}';
        resultColor = getColorForBMI(bmi);
      });
    } else {
      setState(() {
        result = 'Please enter valid, positive numbers for weight and height';
        resultColor = Colors.red;
      });
    }
  }

  Color getColorForBMI(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi >= 18.5 && bmi < 25) {
      return Colors.green;
    } else if (bmi >= 25 && bmi < 30) {
      return Colors.yellow[700]!; // Choose a dark enough yellow variant
    } else if (bmi >= 30 && bmi < 35) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: heightController,
                      decoration: InputDecoration(
                        labelText: 'Height (m)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: calculateBMI,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text('Calculate BMI', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            if (result.isNotEmpty)
              Column(
                children: [
                  Text(
                    result,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildBMIDetailsCard(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBMICategory('Underweight', '<18.5', Colors.blue),
            _buildBMICategory('Healthy weight', '18.5 - 24.9', Colors.green),
            _buildBMICategory('Overweight', '25 - 29.9', Colors.yellow[700]!),
            _buildBMICategory('Obese (Class 1)', '30 - 34.9', Colors.orange),
            _buildBMICategory('Obese (Class 2)', '>35', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICategory(String label, String range, Color bgColor) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      color: bgColor,
      padding: EdgeInsets.all(8),
      child: Text(
        '$range : $label',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}

