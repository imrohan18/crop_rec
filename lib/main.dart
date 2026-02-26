import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'history_page.dart';

void main() {
  runApp(const CropApp());
}

final api = ApiService();

class CropApp extends StatelessWidget {
  const CropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Crop Recommendation',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: const Color(0xFFF1F8E9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
        ),
      ),
      home: const SplashPage(),
    );
  }
}

/// ================= SPLASH =================
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    final loggedIn = await api.isLoggedIn();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const SoilInputPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// ================= LOGIN =================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.agriculture,
                        size: 80, color: Color(0xFF2E7D32)),
                    const SizedBox(height: 15),
                    const Text(
                      "Smart Crop Recommendation",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () async {
                                if (emailCtrl.text.isEmpty ||
                                    passCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Enter email & password")),
                                  );
                                  return;
                                }

                                setState(() => loading = true);

                                try {
                                  await api.login(
                                    email: emailCtrl.text.trim(),
                                    password: passCtrl.text.trim(),
                                  );

                                  if (!mounted) return;

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SoilInputPage(),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }

                                setState(() => loading = false);
                              },
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("LOGIN"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupPage()),
                        );
                      },
                      child: const Text("New user? Create account"),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () async {
                              await api.setGuest(true);
                              if (!mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SoilInputPage(),
                                ),
                              );
                            },
                      child: const Text("Continue as Guest"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ================= SIGNUP =================
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final userCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
                controller: userCtrl,
                decoration: const InputDecoration(labelText: "Username")),
            const SizedBox(height: 12),
            TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 12),
            TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (userCtrl.text.isEmpty ||
                            emailCtrl.text.isEmpty ||
                            passCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Fill all fields")));
                          return;
                        }

                        setState(() => loading = true);

                        try {
                          await api.register(
                            username: userCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text.trim(),
                          );

                          if (!mounted) return;
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text("$e")));
                        }

                        setState(() => loading = false);
                      },
                child: const Text("SIGN UP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= DASHBOARD / SOIL INPUT =================
class SoilInputPage extends StatefulWidget {
  const SoilInputPage({super.key});
  @override
  State<SoilInputPage> createState() => _SoilInputPageState();
}

class _SoilInputPageState extends State<SoilInputPage> {
  double n = 50, p = 30, k = 40, temp = 25, humidity = 60, ph = 7;
  String selectedSeason = "Kharif";
  bool loading = false;

  Widget sliderTile(
      String label, double value, double min, double max, Function(double) on) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$label  (${value.toStringAsFixed(1)})",
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Slider(value: value, min: min, max: max, onChanged: on),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          sliderTile("Nitrogen", n, 0, 140, (v) => setState(() => n = v)),
          sliderTile("Phosphorus", p, 0, 140, (v) => setState(() => p = v)),
          sliderTile("Potassium", k, 0, 200, (v) => setState(() => k = v)),
          sliderTile("Temperature", temp, 0, 50, (v) => setState(() => temp = v)),
          sliderTile(
              "Humidity", humidity, 0, 100, (v) => setState(() => humidity = v)),
          sliderTile("pH", ph, 0, 14, (v) => setState(() => ph = v)),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: selectedSeason,
            decoration: const InputDecoration(labelText: "Season"),
            items: ["Kharif", "Rabi", "Annual"]
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => selectedSeason = v!),
          ),

          const SizedBox(height: 20),

          SizedBox(
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("$e")));
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
    );
  }
}

/// ================= RESULT =================
class ResultPage extends StatelessWidget {
  final List<CropRecommendation> results;
  const ResultPage({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recommendation Result")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (_, i) {
          final r = results[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.crop,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32))),
                  const SizedBox(height: 10),
                  const Text("Deficiency (kg/ha):"),
                  ...r.deficiency.entries
                      .map((e) => Text("${e.key}: ${e.value}")),
                  const SizedBox(height: 10),
                  const Text("Organic Fertilizers:"),
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



