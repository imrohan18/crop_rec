import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResultPage extends StatelessWidget {
  final List<CropRecommendation> results;
  const ResultPage({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recommendation Result")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final r = results[i];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r.crop,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE9DC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Recommended',
                        style: TextStyle(
                          color: Color(0xFFEC5B13),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Deficiency (kg/ha):"),
                ...r.deficiency.entries.map((e) => Text("${e.key}: ${e.value}")),
                const SizedBox(height: 10),
                const Text("Organic Fertilizers:"),
                ...r.fertilizers.map((f) => Text("• $f")),
              ],
            ),
          );
        },
      ),
    );
  }
}
