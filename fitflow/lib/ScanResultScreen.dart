import 'package:flutter/material.dart';

class ScanResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final int totalCalories;

  const ScanResultScreen({
    super.key,
    required this.results,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Results"),
        backgroundColor: Colors.green, // Matches app theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalCaloriesCard(),
            const SizedBox(height: 20),
            Expanded(
              child:
                  results.isNotEmpty
                      ? ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final item = results[index];
                          return _buildFoodItemCard(item);
                        },
                      )
                      : _buildNoFoodDetected(),
            ),
          ],
        ),
      ),
    );
  }

  // **Total Calories Card**
  Widget _buildTotalCaloriesCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[600], // Theme Color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            "Total Calories: $totalCalories kcal",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // **Food Item Card**
  Widget _buildFoodItemCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const Icon(Icons.fastfood, color: Colors.green, size: 30),
        title: Text(
          item["food"],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          "Quantity: ${item["quantity"]}\n"
          "Calories per 100g: ${item["calories_per_100g"]} kcal\n"
          "Total: ${item["total_calories"]} kcal",
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  // **No Food Detected UI**
  Widget _buildNoFoodDetected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, color: Colors.grey[500], size: 60),
          const SizedBox(height: 10),
          const Text(
            "No food items detected!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
