import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';


void main() {
  runApp(const CropApp());
}

class CropApp extends StatelessWidget {
  const CropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Crop Recommendation',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SoilInputPage(),
    );
  }
}

// ---------------- SOIL INPUT PAGE ----------------
class SoilInputPage extends StatefulWidget {
  const SoilInputPage({super.key});

  @override
  State<SoilInputPage> createState() => _SoilInputPageState();
}

class _SoilInputPageState extends State<SoilInputPage> {
  final nCtrl = TextEditingController();
  final pCtrl = TextEditingController();
  final kCtrl = TextEditingController();
  final tCtrl = TextEditingController();
  final hCtrl = TextEditingController();
  final phCtrl = TextEditingController();

  bool loading = false;

  Widget soilField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(title: const Text("Soil Parameters")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            soilField("Nitrogen (N)", nCtrl),
            soilField("Phosphorus (P)", pCtrl),
            soilField("Potassium (K)", kCtrl),
            soilField("Temperature (°C)", tCtrl),
            soilField("Humidity (%)", hCtrl),
            soilField("pH", phCtrl),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics),
                label: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Predict Crop"),
                onPressed: loading
                    ? null
                    : () async {
                        setState(() => loading = true);

                        try {
                          final api = ApiService();
                          final results = await api.predictCrop(
                            n: double.parse(nCtrl.text),
                            p: double.parse(pCtrl.text),
                            k: double.parse(kCtrl.text),
                            temperature: double.parse(tCtrl.text),
                            humidity: double.parse(hCtrl.text),
                            ph: double.parse(phCtrl.text),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ResultPage(results: results),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }

                        setState(() => loading = false);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- RESULT PAGE ----------------
class ResultPage extends StatelessWidget {
  final List<CropRecommendation> results;

  const ResultPage({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(title: const Text("Recommendation Result")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final r = results[index];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop name
                  Text(
                    r.crop,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Deficiency
                  const Text(
                    "Nutrient Deficiency (kg/ha)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...r.deficiency.entries.map(
                    (e) => Text("${e.key} : ${e.value}"),
                  ),

                  const SizedBox(height: 10),

                  // Fertilizers
                  const Text(
                    "Organic Fertilizer (kg/acre)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...r.fertilizers.map((f) => Text("• $f")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

