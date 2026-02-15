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
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashPage(),
    );
  }
}

/// ================= SPLASH / AUTO LOGIN =================
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

    if(!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const SoilInputPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// ================= LOGIN PAGE =================
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
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              const Icon(Icons.agriculture,size:80,color:Colors.green),
              const SizedBox(height:20),

              const Text(
                "Smart Crop Recommendation",
                style: TextStyle(fontSize:22,fontWeight:FontWeight.bold),
              ),

              const SizedBox(height:30),

              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText:"Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height:15),

              TextField(
                controller: passCtrl,
                obscureText:true,
                decoration: InputDecoration(
                  labelText:"Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height:25),

              SizedBox(
                width:double.infinity,
                height:50,
                child: ElevatedButton(
                  onPressed: loading ? null : () async {

                    if(emailCtrl.text.isEmpty || passCtrl.text.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content:Text("Enter email & password")),
                      );
                      return;
                    }

                    setState(()=>loading=true);

                    try{

                      await api.login(
                        email: emailCtrl.text.trim(),
                        password: passCtrl.text.trim(),
                      );

                      if(!mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:(_)=>const SoilInputPage(),
                        ),
                      );

                    }catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content:Text(e.toString())),
                      );
                    }

                    setState(()=>loading=false);
                  },
                  child: loading
                      ? const CircularProgressIndicator(color:Colors.white)
                      : const Text("Login"),
                ),
              ),

              const SizedBox(height:15),

              TextButton(
                onPressed:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder:(_)=>const SignupPage()),
                  );
                },
                child:const Text("New user? Sign up"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

/// ================= SIGNUP PAGE =================
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState()=>_SignupPageState();
}

class _SignupPageState extends State<SignupPage>{

  final userCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading=false;

  @override
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children:[

            TextField(
              controller:userCtrl,
              decoration:InputDecoration(
                labelText:"Username",
                prefixIcon: const Icon(Icons.person),
                border:OutlineInputBorder(
                  borderRadius:BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height:15),

            TextField(
              controller:emailCtrl,
              decoration:InputDecoration(
                labelText:"Email",
                prefixIcon: const Icon(Icons.email),
                border:OutlineInputBorder(
                  borderRadius:BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height:15),

            TextField(
              controller:passCtrl,
              obscureText:true,
              decoration:InputDecoration(
                labelText:"Password",
                prefixIcon: const Icon(Icons.lock),
                border:OutlineInputBorder(
                  borderRadius:BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height:25),

            SizedBox(
              width:double.infinity,
              height:50,
              child:ElevatedButton(
                onPressed:loading?null:() async {

                  if(userCtrl.text.isEmpty ||
                     emailCtrl.text.isEmpty ||
                     passCtrl.text.isEmpty){

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content:Text("Fill all fields")),
                    );
                    return;
                  }

                  setState(()=>loading=true);

                  try{

                    await api.register(
                      username:userCtrl.text.trim(),
                      email:emailCtrl.text.trim(),
                      password:passCtrl.text.trim(),
                    );

                    if(!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content:Text("Signup successful")),
                    );

                    Navigator.pop(context);

                  }catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content:Text(e.toString())),
                    );
                  }

                  setState(()=>loading=false);
                },
                child:loading
                    ? const CircularProgressIndicator(color:Colors.white)
                    : const Text("Create Account"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

/// ================= SOIL INPUT PAGE =================
class SoilInputPage extends StatefulWidget {
  const SoilInputPage({super.key});

  @override
  State<SoilInputPage> createState()=>_SoilInputPageState();
}

class _SoilInputPageState extends State<SoilInputPage>{

  final nCtrl=TextEditingController();
  final pCtrl=TextEditingController();
  final kCtrl=TextEditingController();
  final tCtrl=TextEditingController();
  final hCtrl=TextEditingController();
  final phCtrl=TextEditingController();

  bool loading=false;

  Widget soilField(String label,TextEditingController ctrl){
    return Padding(
      padding:const EdgeInsets.only(bottom:12),
      child:TextField(
        controller:ctrl,
        keyboardType:TextInputType.number,
        decoration:InputDecoration(
          labelText:label,
          filled:true,
          fillColor:Colors.white,
          border:OutlineInputBorder(
            borderRadius:BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor:Colors.green[50],
      appBar:AppBar(
        title:const Text("Soil Parameters"),
        actions:[

          IconButton(
            icon:const Icon(Icons.history),
            onPressed:(){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:(_)=>const HistoryPage(),
                ),
              );
            },
          ),

          IconButton(
            icon:const Icon(Icons.logout),
            onPressed:() async {
              await api.logout();

              if(!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder:(_)=>const LoginPage()),
                (route)=>false,
              );
            },
          ),
        ],
      ),

      body:SingleChildScrollView(
        padding:const EdgeInsets.all(20),
        child:Column(
          children:[

            soilField("Nitrogen (N)",nCtrl),
            soilField("Phosphorus (P)",pCtrl),
            soilField("Potassium (K)",kCtrl),
            soilField("Temperature (°C)",tCtrl),
            soilField("Humidity (%)",hCtrl),
            soilField("pH",phCtrl),

            const SizedBox(height:25),

            SizedBox(
              width:double.infinity,
              height:55,
              child:ElevatedButton(
                onPressed:loading?null:() async {

                  if(nCtrl.text.isEmpty||
                     pCtrl.text.isEmpty||
                     kCtrl.text.isEmpty||
                     tCtrl.text.isEmpty||
                     hCtrl.text.isEmpty||
                     phCtrl.text.isEmpty){

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content:Text("Fill all fields")),
                    );
                    return;
                  }

                  setState(()=>loading=true);

                  try{

                    final results=await api.predictCrop(
                      n:double.parse(nCtrl.text),
                      p:double.parse(pCtrl.text),
                      k:double.parse(kCtrl.text),
                      temperature:double.parse(tCtrl.text),
                      humidity:double.parse(hCtrl.text),
                      ph:double.parse(phCtrl.text),
                    );

                    if(!mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:(_)=>ResultPage(results:results),
                      ),
                    );

                  }catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content:Text("Error: $e")),
                    );
                  }

                  setState(()=>loading=false);
                },
                child:loading
                    ? const CircularProgressIndicator(color:Colors.white)
                    : const Text("Predict Crop"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

/// ================= RESULT PAGE =================
class ResultPage extends StatelessWidget{

  final List<CropRecommendation> results;

  const ResultPage({super.key,required this.results});

  @override
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor:Colors.green[50],
      appBar:AppBar(title:const Text("Recommendation Result")),
      body:ListView.builder(
        padding:const EdgeInsets.all(16),
        itemCount:results.length,
        itemBuilder:(context,index){

          final r=results[index];

          return Card(
            margin:const EdgeInsets.only(bottom:16),
            child:Padding(
              padding:const EdgeInsets.all(16),
              child:Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children:[

                  Text(
                    r.crop,
                    style:const TextStyle(
                      fontSize:20,
                      fontWeight:FontWeight.bold,
                      color:Colors.green,
                    ),
                  ),

                  const SizedBox(height:10),

                  const Text("Deficiency (kg/ha):"),
                  ...r.deficiency.entries
                      .map((e)=>Text("${e.key}: ${e.value}")),

                  const SizedBox(height:10),

                  const Text("Organic Fertilizer (kg/acre):"),
                  ...r.fertilizers.map((f)=>Text("• $f")),

                ],
              ),
            ),
          );
        },
      ),
    );
  }