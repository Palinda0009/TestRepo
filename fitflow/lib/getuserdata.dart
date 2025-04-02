import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mealresultscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInputScreen extends StatefulWidget {
  const UserInputScreen({super.key});

  @override
  _UserInputScreenState createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double _bmi = 0.0;
  double _caloricIntake = 0.0;
  String _selectedGender = "Male";
  String _selectedActivityLevel = "Moderate";

  void _calculateBMI() {
    double height = double.tryParse(_heightController.text) ?? 0.0;
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    if (height > 0 && weight > 0) {
      setState(() {
        _bmi = weight / ((height / 100) * (height / 100));
      });
      _calculateCaloricIntake();
    }
  }

  void _calculateCaloricIntake() {
    if (_bmi > 0) {
      double weight = double.tryParse(_weightController.text) ?? 0.0;
      double activityFactor =
          _selectedActivityLevel == "Active"
              ? 1.55
              : _selectedActivityLevel == "Light"
              ? 1.2
              : 1.375;

      setState(() {
        _caloricIntake =
            (_selectedGender == "Male"
                ? (10 * weight +
                    6.25 * (double.tryParse(_heightController.text) ?? 0.0) -
                    5 * (int.tryParse(_ageController.text) ?? 0) +
                    5)
                : (10 * weight +
                    6.25 * (double.tryParse(_heightController.text) ?? 0.0) -
                    5 * (int.tryParse(_ageController.text) ?? 0) -
                    161)) *
            activityFactor;
      });
    }
  }

  Future<void> _saveUserInputToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('user_inputs')
            .doc(user.uid)
            .set({
              "Age": _ageController.text,
              "Gender": _selectedGender,
              "Weight_kg": _weightController.text,
              "Height_cm": _heightController.text,
              "BMI": _bmi,
              "Activity_Level": _selectedActivityLevel,
              "Daily_Caloric_Intake": _caloricIntake,
            });
      } catch (e) {
        _showError("Error saving data: $e");
      }
    }
  }

  Future<void> _getMealPlan() async {
    await _saveUserInputToFirebase(); // Save user data before fetching meal plan

    final String apiUrl = "http://192.168.1.176:8001/predict";

    Map<String, dynamic> requestData = {
      "Age": int.tryParse(_ageController.text) ?? 0,
      "Gender": _selectedGender,
      "Weight_kg": double.tryParse(_weightController.text) ?? 0.0,
      "Height_cm": double.tryParse(_heightController.text) ?? 0.0,
      "BMI": _bmi,
      "Physical_Activity_Level": _selectedActivityLevel,
      "Daily_Caloric_Intake": _caloricIntake,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealResultScreen(mealPlan: responseData),
          ),
        );
      } else {
        _showError("Failed to fetch meal plan. Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Error connecting to API: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      onPressed: _getMealPlan, // Ensure _getMealPlan() exists
      child: const Text(
        "Get Meal Plan",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Enter Your Details"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInputFields(),
            const SizedBox(height: 20),
            _buildInfoFields(),
            const SizedBox(height: 25),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNumberField(_ageController, "Age", Icons.cake),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildNumberField(
                _heightController,
                "Height (cm)",
                Icons.height,
                onChanged: _calculateBMI,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildNumberField(
          _weightController,
          "Weight (kg)",
          Icons.fitness_center,
          onChanged: _calculateBMI,
        ),
        const SizedBox(height: 10),
        _buildDropdown(
          "Gender",
          ["Male", "Female"],
          _selectedGender,
          (value) => setState(() => _selectedGender = value!),
        ),
        const SizedBox(height: 10),
        _buildDropdown(
          "Activity Level",
          ["Active", "Light", "Moderate"],
          _selectedActivityLevel,
          (value) => setState(() => _selectedActivityLevel = value!),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items:
          options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    IconData icon, {
    VoidCallback? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) => onChanged?.call(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildInfoFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _buildInfoTile("BMI", _bmi.toStringAsFixed(2))),
        const SizedBox(width: 10),
        Expanded(
          child: _buildInfoTile("Calories", _caloricIntake.toStringAsFixed(2)),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
