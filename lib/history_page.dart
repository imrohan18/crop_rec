import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  final api = ApiService();
  List history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    try {
      final data = await api.getHistory();   // ✅ REMOVED userId
      setState(() => history = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(title: const Text("Prediction History")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(child: Text("No history yet"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (_, i){

                    final h = history[i];

                    // result stored as JSON string → decode if needed
                    final result = h["result"] is String
                        ? apiDecode(h["result"])
                        : h["result"];

                    return Card(
                      margin: const EdgeInsets.only(bottom:12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "N:${h["N"]}  P:${h["P"]}  K:${h["K"]}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height:6),

                            Text("Temp: ${h["Temperature"]}"),
                            Text("Humidity: ${h["Humidity"]}"),
                            Text("pH: ${h["pH"]}"),

                            const Divider(),

                            const Text("Result:"),

                            ...((result as List)
                                .map((r)=>Text("• ${r["crop"]}")))

                          ],
                        ),
                      ),
                    );
                  }),
    );
  }

  // helper for decoding JSON safely
  dynamic apiDecode(String s){
    try{
      return jsonDecode(s);
    }catch(_){
      return [];
    }
  }
}
