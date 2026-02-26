import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'result_page.dart';
import 'login_page.dart';
import 'fields_page.dart';

class SoilInputPage extends StatefulWidget {
  const SoilInputPage({super.key});
  @override
  State<SoilInputPage> createState() => _SoilInputPageState();
}

class _SoilInputPageState extends State<SoilInputPage> {
  final api = ApiService();
  double n = 50, p = 30, k = 40, temp = 25, humidity = 60, ph = 7;
  String selectedSeason = "Kharif";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crop Analysis'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await api.logout();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Analysis', icon: Icon(Icons.analytics_outlined)),
              Tab(text: 'Fields', icon: Icon(Icons.grass)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  title: 'Soil Parameters',
                  child: Column(
                    children: [
                      _SliderRow(
                        label: 'Nitrogen (N)',
                        value: n,
                        unit: 'mg/kg',
                        color: Colors.orange,
                        onChanged: (v) => setState(() => n = v),
                      ),
                      const SizedBox(height: 8),
                      _SliderRow(
                        label: 'Phosphorus (P)',
                        value: p,
                        unit: 'mg/kg',
                        color: Colors.deepOrange,
                        onChanged: (v) => setState(() => p = v),
                      ),
                      const SizedBox(height: 8),
                      _SliderRow(
                        label: 'Potassium (K)',
                        value: k,
                        unit: 'mg/kg',
                        color: Colors.blue,
                        onChanged: (v) => setState(() => k = v),
                      ),
                      const SizedBox(height: 8),
                      _SliderRow(
                        label: 'pH Level',
                        value: ph,
                        min: 0,
                        max: 14,
                        unit: 'pH',
                        color: Colors.purple,
                        onChanged: (v) => setState(() => ph = v),
                      ),
                      const SizedBox(height: 12),
                      _SliderRow(
                        label: 'Temperature',
                        value: temp,
                        min: 0,
                        max: 50,
                        unit: '°C',
                        color: Colors.orange,
                        onChanged: (v) => setState(() => temp = v),
                      ),
                      const SizedBox(height: 8),
                      _SliderRow(
                        label: 'Humidity',
                        value: humidity,
                        min: 0,
                        max: 100,
                        unit: '%',
                        color: Colors.cyan,
                        onChanged: (v) => setState(() => humidity = v),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedSeason,
                        decoration: const InputDecoration(labelText: "Season"),
                        items: ["Kharif", "Rabi", "Annual"]
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedSeason = v!),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () async {
                                  setState(() => loading = true);
                                  try {
                                    final results = await api.predictCrop(
                                      n: n,
                                      p: p,
                                      k: k,
                                      temperature: temp,
                                      humidity: humidity,
                                      ph: ph,
                                      season: selectedSeason,
                                    );
                                    if (!mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ResultPage(results: results),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("$e")),
                                    );
                                  }
                                  setState(() => loading = false);
                                },
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("GET CROP RECOMMENDATION"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const FieldsPage(),
          ],
        ),
      ),
    );
  }
}


class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final ValueChanged<double> onChanged;
  const _SliderRow({
    required this.label,
    required this.value,
    this.min = 0,
    this.max = 100,
    required this.unit,
    required this.color,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.spa, color: color),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Text(
                '${value.toStringAsFixed(0)} $unit',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({super.key, required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
