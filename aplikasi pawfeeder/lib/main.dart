import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

const String ipAddress = '192.168.25.240';
const String port = '3000';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawFeeder',
      theme: ThemeData(primarySwatch: Colors.pink),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/input_data': (context) => InputDataScreen(),
        '/home': (context) => HomeScreen(),
        '/history': (context) => HistoryScreen(),
        '/submenu': (context) => SubmenuScreen(),
        '/penjadwalan_pawfeeder': (context) => PenjadwalanPawFeederScreen(),
        '/discussion': (context) => DiscussionScreen(),
        '/status': (context) => StatusScreen(),
        '/Artikel': (context) => ArtikelScreen(),
        '/adopsi_kucing': (context) => AdoptionScreen(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Both fields are required.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://$ipAddress:$port/pengguna'), // Same endpoint as sign-up
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password_hash': password, // Password sent as plaintext or hashed
        }),
      );

      if (response.statusCode == 200) {
        // Login successful
        final responseData = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${responseData['name']}!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the home screen or next screen
        Navigator.pushNamed(
            context, '/input_data'); // Replace with your desired route
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Invalid email or password.';
        });
      } else {
        setState(() {
          errorMessage = 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'lib/assets/logo.png',
                width: 200, // Atur lebar sesuai kebutuhan
                height: 200, // Atur tinggi sesuai kebutuhan
              ),
              const SizedBox(height: 16), // Spasi antara logo dan teks
              // Error Message
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              // Input Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              // Tombol Log In
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Log In',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
              // Text Sign Up
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text(
                  "Don't have an account? Create one",
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//sign up

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> signUp() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate inputs
    if (name.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        errorMessage = 'All fields are required.';
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:$port/pengguna'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_lengkap': name,
          'username': username,
          'email': email,
          'password_hash': password, // Replace with hashed password if required
        }),
      );

      if (response.statusCode == 201) {
        // Successfully added
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Sign-up successful! ID: ${responseData['id_pengguna']}'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(
            context); // Return to previous screen (e.g., login screen)
      } else if (response.statusCode == 400) {
        final errors = jsonDecode(response.body)['errors'];
        setState(() {
          errorMessage = errors.map((e) => e['msg']).join(', ');
        });
      } else {
        setState(() {
          errorMessage = 'Sign-up failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign Up',
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Layar Input Data Kucing // disimpan ke database kucing (pengguna)

class InputDataScreen extends StatefulWidget {
  const InputDataScreen({super.key});

  @override
  State<InputDataScreen> createState() => _InputDataScreenState();
}

class _InputDataScreenState extends State<InputDataScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _usiaController = TextEditingController();
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;
  XFile? _pickedFile;
  Uint8List? _webImage; // Tambahkan untuk menyimpan image bytes di web

  // Replace this with the actual user ID for the logged-in user
  final int idPengguna = 1;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Resize the image width to a maximum of 800px
        maxHeight: 800, // Resize the image height to a maximum of 800px
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Untuk web, baca file sebagai bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _pickedFile = pickedFile;
            _webImage = bytes;
          });
        } else {
          setState(() {
            _pickedFile = pickedFile;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image selected successfully')),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred while picking the image: $e';
      });
    }
  }

  Future<void> submitData() async {
    final nama = _namaController.text.trim();
    final jenis = _jenisController.text.trim();
    final usia = _usiaController.text.trim();
    final berat = _beratController.text.trim();
    final gender = _genderController.text.trim();

    // Validate inputs
    if (nama.isEmpty ||
        jenis.isEmpty ||
        usia.isEmpty ||
        berat.isEmpty ||
        gender.isEmpty) {
      setState(() {
        errorMessage = 'All fields are required.';
      });
      return;
    }

    if (gender != 'jantan' && gender != 'betina') {
      setState(() {
        errorMessage = 'Gender must be either "jantan" or "betina".';
      });
      return;
    }

    if (_pickedFile == null) {
      setState(() {
        errorMessage = 'Please upload a photo of your cat.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$ipAddress:$port/kucing'), //ux
      );

      request.fields['nama'] = nama;
      request.fields['jenis'] = jenis;
      request.fields['tipe_kucing'] = 'pengguna';
      request.fields['usia'] = usia;
      request.fields['berat'] = berat;
      request.fields['gender'] = gender;
      request.fields['id_pengguna'] = idPengguna.toString();

      // Attach the selected image
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto_kucing', // Field name in the backend
          _webImage!,
          filename: _pickedFile!.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'foto_kucing', // Field name in the backend
          _pickedFile!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kucing berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamed(context, '/home');
      } else {
        setState(() {
          errorMessage = 'Failed to add kucing. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> skipToNextPage() async {
    Navigator.pushNamed(context, '/home'); // Ganti dengan halaman yang sesuai
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Masukkan data diri kucing kesayangan Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kucing',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _jenisController,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kucing',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender (jantan/betina)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usiaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Usia Kucing (tahun)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _beratController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Berat Kucing (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                onPressed: pickImage,
                label: const Text(
                  'Upload Foto Kucing',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              if (_pickedFile != null)
                kIsWeb
                    ? Image.memory(
                        _webImage!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_pickedFile!.path),
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                onPressed: isLoading ? null : submitData,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Data',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: skipToNextPage,
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//home

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> riwayat = [];
  bool isLoading = true;
  String errorMessage = '';
  String kapasitas = "Loading..."; // Display the kapasitas value
  String feederStatus = "OFF"; // Display the status of the feeder
  Timer? _timer; // Timer for polling

  // Async function to fetch data
  Future<void> getData() async {
    try {
      final response =
          await http.get(Uri.parse('http://$ipAddress:$port/riwayat-makan'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Sort data berdasarkan waktu_makan (tanggal terbaru di atas)
        data.sort((a, b) {
          DateTime aDate = DateTime.parse(a['waktu_makan']);
          DateTime bDate = DateTime.parse(b['waktu_makan']);
          return bDate.compareTo(aDate); // Mengurutkan dari yang terbaru
        });

        setState(() {
          riwayat = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Error: $e';
      });
    }
  }

  String formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return 'Invalid Date'; // Jika null atau kosong, kembalikan teks yang menunjukkan error
    }

    try {
      final dateTime = DateTime.parse(timestamp); // Parse timestamp yang valid
      final formattedDate =
          DateFormat('yyyy-MM-dd').format(dateTime); // Format tanggal
      final formattedTime =
          DateFormat('HH:mm').format(dateTime); // Format waktu
      return 'Tanggal: $formattedDate, Jam: $formattedTime';
    } catch (e) {
      return 'Invalid Date'; // Jika terjadi error saat parsing
    }
  }

  // Function to start polling for kapasitas every 5 seconds
  void startPolling() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      getKapasitas(); // Fetch kapasitas every 5 seconds
    });
  }

  // Stop polling when the screen is disposed
  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer when the screen is disposed
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
    startPolling(); // Start polling for kapasitas updates
  }

  // Async function to fetch kapasitas data from the server
  Future<void> getKapasitas() async {
    try {
      final response =
          await http.get(Uri.parse('http://$ipAddress:$port/kapasitas'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          kapasitas = data['kapasitas']?.toString() ??
              'Error fetching kapasitas'; // Safely handle null kapasitas
        });
      } else {
        setState(() {
          kapasitas = 'Error fetching kapasitas';
        });
      }
    } catch (e) {
      setState(() {
        kapasitas = 'Error fetching kapasitas';
      });
    }
  }

  // Async function to post status ON/OFF to the backend
  Future<void> postStatus(String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:$port/status'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        setState(() {
          feederStatus = status; // Update the feeder status
        });
        print('Perintah $status berhasil dikirim ke feeder');
      } else {
        print('Gagal mengirim perintah ke feeder: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('PawFeeder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/submenu');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Tag Collar
            const Card(
              child: ListTile(
                title: Text('Status Tag Collar'),
                subtitle: Text('Tersambung'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            const SizedBox(height: 10),

            // Ketersediaan Makanan
            Card(
              child: ListTile(
                title: Text('Ketersediaan Makanan'),
                subtitle: Text('$kapasitas%'), // Show kapasitas from polling
                trailing: const Icon(Icons.fastfood, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 20),

            // Riwayat Pemberian Makanan
            const Text('Riwayat Pemberian Makanan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Menampilkan riwayat makanan yang terbaru
            isLoading
                ? const CircularProgressIndicator()
                : errorMessage.isNotEmpty
                    ? Text(errorMessage)
                    : Column(
                        children: [
                          // Menampilkan 3 riwayat makanan terbaru
                          for (var item in riwayat.take(3))
                            ListTile(
                              leading: const Icon(Icons.history),
                              title: Text(formatTimestamp(item['waktu_makan'])),
                            ),
                          const SizedBox(height: 10),
                          // Tombol untuk melihat selengkapnya
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/history');
                            },
                            child: const Text('Lihat Selengkapnya'),
                          ),
                        ],
                      ),

            const Spacer(),

            // ON / OFF Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    postStatus('ON'); // Send ON status to the backend
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('ON'),
                ),
                ElevatedButton(
                  onPressed: () {
                    postStatus('OFF'); // Send OFF status to the backend
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('OFF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Riwayat Makanan // beri api untuk backend app get riwayat pemberian makan

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> riwayat = [];
  bool isLoading = true;
  String errorMessage = '';

  // Async function to fetch data
  Future<void> getData() async {
    try {
      final response =
          await http.get(Uri.parse('http://$ipAddress:$port/riwayat-makan'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Mengurutkan data berdasarkan waktu_makan (tanggal terbaru di atas)
        data.sort((a, b) {
          DateTime aDate = DateTime.parse(a['waktu_makan']);
          DateTime bDate = DateTime.parse(b['waktu_makan']);
          return bDate.compareTo(aDate); // Mengurutkan dari yang terbaru
        });

        setState(() {
          riwayat = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Error: $e';
      });
    }
  }

  // Helper function to format the timestamp
  String formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp); // Parse the ISO8601 string
      final formattedDate =
          DateFormat('yyyy-MM-dd').format(dateTime); // Format date
      final formattedTime = DateFormat('HH:mm').format(dateTime); // Format time
      return 'Tanggal: $formattedDate, Jam: $formattedTime';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Riwayat Pemberian Makanan'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: riwayat.length,
                  itemBuilder: (context, index) {
                    final user = riwayat[index];

                    // Ensure that data is cast to String if needed
                    final waktuMakan = user['waktu_makan']?.toString() ?? 'N/A';
                    final jumlahPemberian =
                        user['jumlah_pemberian']?.toString() ?? 'N/A';

                    // Format the timestamp
                    final formattedWaktuMakan = formatTimestamp(waktuMakan);

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.pink),
                        title: Text(formattedWaktuMakan),
                        subtitle:
                            Text('Jumlah pemberian: $jumlahPemberian kalori'),
                      ),
                    );
                  },
                ),
    );
  }
}

//Sub Menu
class SubmenuScreen extends StatelessWidget {
  const SubmenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Menu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          ListTile(
            leading: const Icon(Icons.home, color: Colors.pink),
            title: const Text('HOME'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety, color: Colors.pink),
            title: const Text('Diskusi Kesehatan dan Makanan'),
            onTap: () {
              Navigator.pushNamed(context, '/discussion');
            },
          ),
          ListTile(
            leading: const Icon(Icons.article, color: Colors.pink),
            title: const Text('Artikel'),
            onTap: () {
              Navigator.pushNamed(
                  context, '/Artikel'); // Navigasi ke ArtikelScreen
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets, color: Colors.pink),
            title: const Text('Adopsi Kucing'),
            onTap: () {
              Navigator.pushNamed(context, '/adopsi_kucing');
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.calendar_view_day_rounded, color: Colors.pink),
            title: const Text('Penjadwalan Pawfeeder'),
            onTap: () {
              Navigator.pushNamed(context, '/penjadwalan_pawfeeder');
            },
          ),
          ListTile(
            leading: const Icon(Icons.power_settings_new, color: Colors.red),
            title: const Text('Log out'),
            onTap: () {
              _logout(context); // Panggil fungsi logout dengan context
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    // Fungsi untuk logout dan kembali ke halaman login
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}

//jadwal
class PenjadwalanPawFeederScreen extends StatefulWidget {
  const PenjadwalanPawFeederScreen({super.key});

  @override
  State<PenjadwalanPawFeederScreen> createState() =>
      _PenjadwalanPawFeederScreenState();
}

class _PenjadwalanPawFeederScreenState
    extends State<PenjadwalanPawFeederScreen> {
  dynamic jadwal;
  bool isLoading =
      false; // Start with false, since the app is not loading initially
  bool isSuccess = false; // Add a success flag to show successful message
  String errorMessage = '';
  String idKucing = ''; // Variable for the id_kucing
  String kebutuhanKalori = ''; // Variable for kebutuhan_kalori

  // List to hold the feeding times
  List<String> waktuMakan = [];

  // Controller for the TextField input
  final TextEditingController jamController = TextEditingController();

  // Async function to send data to the backend
  Future<void> postData() async {
    setState(() {
      isLoading = true; // Set loading to true when sending request
      isSuccess = false; // Reset success status before sending request
    });

    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:$port/jadwal-makan'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'id_kucing': idKucing,
          'waktu_makan': waktuMakan,
          'berapa_kali_makan':
              waktuMakan.length, // Number of feedings based on selected times
          'kebutuhan_kalori':
              kebutuhanKalori.isEmpty ? null : int.parse(kebutuhanKalori),
        }),
      );

      setState(() {
        isLoading = false; // Set loading to false once the response is received
      });

      if (response.statusCode == 200) {
        setState(() {
          jadwal = json.decode(response.body);
          isSuccess = true; // Mark as success when data is saved
          errorMessage = ''; // Clear any previous error message
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Error: $e';
      });
    }
  }

  // Function to add time to the list
  void addTimeToList() {
    String time = jamController.text;
    if (time.isNotEmpty && !waktuMakan.contains(time)) {
      setState(() {
        waktuMakan
            .add(time); // Add the time to the list if it's not already present
      });
      jamController.clear(); // Clear the input field after adding the time
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjadwalan Pawfeeder'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Penjadwalan (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'ID Kucing'),
              onChanged: (value) {
                setState(() {
                  idKucing = value;
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Kebutuhan Kalori'),
              onChanged: (value) {
                setState(() {
                  kebutuhanKalori = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: jamController,
              decoration:
                  const InputDecoration(labelText: 'Masukkan Jam Makan'),
              keyboardType: TextInputType.number,
              onSubmitted: (_) =>
                  addTimeToList(), // Add time when user presses enter
            ),
            ElevatedButton(
              onPressed: addTimeToList,
              child: const Text('Tambah Jam Makan'),
            ),
            const SizedBox(height: 16),
            Text('Jam Makan yang Dipilih:'),
            for (var time in waktuMakan)
              Text(time), // Display all selected feeding times
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: postData,
              child: const Text('Simpan Jadwal Makan'),
            ),
            if (isLoading)
              const CircularProgressIndicator() // Show loading indicator while waiting for response
            else if (isSuccess)
              const Text(
                'Jadwal berhasil disimpan!',
                style: TextStyle(color: Colors.green),
              ) // Show success message when data is successfully saved
            else if (errorMessage.isNotEmpty)
              Text(errorMessage,
                  style: const TextStyle(
                      color: Colors.red)) // Show error message if any
          ],
        ),
      ),
    );
  }
}

//diskusi
class DiscussionScreen extends StatefulWidget {
  @override
  _DiscussionScreenState createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  List<dynamic> diskusi = [];
  bool isLoading = true;
  String errorMessage = '';
  Map<int, TextEditingController> _balasanControllers =
      {}; // Controller per topik

  // Function to fetch discussions (diskusi)
  Future<void> getDiskusi() async {
    try {
      final response =
          await http.get(Uri.parse('http://$ipAddress:$port/diskusi'));

      if (response.statusCode == 200) {
        setState(() {
          diskusi =
              json.decode(response.body); // Parsing the list of discussions
          isLoading = false;
          // Initialize controller untuk setiap topik
          for (var topik in diskusi) {
            _balasanControllers[topik['id_topik']] = TextEditingController();
          }
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Error: $e';
      });
    }
  }

  // Function to post a reply (balasan)
  Future<void> postBalasan(
      int idTopik, String kontenBalasan, int idPengguna) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:$port/balasan'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'id_topik': idTopik,
          'id_parent_balasan': null,
          'konten_balasan': kontenBalasan,
          'waktu_balasan': DateTime.now().toIso8601String(),
          'id_pengguna': idPengguna,
        }),
      );

      if (response.statusCode == 201) {
        // Update the discussion with the new reply locally
        setState(() {
          var topik = diskusi.firstWhere((t) => t['id_topik'] == idTopik);
          if (topik['balasan'] == null) topik['balasan'] = [];
          topik['balasan'].add({
            'id_balasan': json.decode(response.body)['id_balasan'],
            'konten_balasan': kontenBalasan,
            'waktu_balasan': DateTime.now().toIso8601String(),
            'id_pengguna': idPengguna,
          });
        });
        print('Balasan berhasil disimpan');
      } else {
        print('Gagal menyimpan balasan: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getDiskusi(); // Fetch the discussions when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diskusi'),
        backgroundColor: Colors.pink[400],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: diskusi.length,
                  itemBuilder: (context, index) {
                    var item = diskusi[index];
                    return ExpansionTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/cat1.png'),
                      ),
                      title: Text(item['konten_topik']),
                      subtitle: Text('Posted at: ${item['waktu_post']}'),
                      children: [
                        // Render seluruh balasan
                        if (item['balasan'] != null &&
                            item['balasan'].isNotEmpty)
                          ...item['balasan'].map<Widget>((balasan) {
                            return ListTile(
                              leading: Icon(Icons.reply, color: Colors.grey),
                              title: Text(balasan['konten_balasan']),
                              subtitle:
                                  Text('Reply at: ${balasan['waktu_balasan']}'),
                            );
                          }).toList(),
                        // Form untuk menambah balasan
                        ListTile(
                          leading: Icon(Icons.add_comment, color: Colors.pink),
                          title: TextField(
                            controller: _balasanControllers[item['id_topik']],
                            decoration: InputDecoration(
                              hintText: 'Tulis balasan...',
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                postBalasan(item['id_topik'], value, 1);
                                _balasanControllers[item['id_topik']]?.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool shouldRefresh =
              await Navigator.pushNamed(context, '/status') as bool;
          if (shouldRefresh) {
            getDiskusi(); // Refresh the discussion list if new discussion was posted
          }
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}

//status
class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController _kontenController = TextEditingController();

  // Fungsi untuk mengambil status (diskusi)
  // Function to post a discussion
  Future<void> postDiskusi(String kontenDiskusi) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:$port/diskusi'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'konten_topik': kontenDiskusi,
          'waktu_post': DateTime.now().toIso8601String(),
          'id_pengguna': 1, // Assuming user id is 1, change accordingly
        }),
      );

      if (response.statusCode == 201) {
        print('Diskusi berhasil disimpan');
        Navigator.pop(context,
            true); // Go back to DiskusiScreen and pass 'true' to refresh the diskusi list
      } else {
        print('Gagal menyimpan diskusi: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('PawFeeder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/submenu');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'What\'s happening?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _kontenController,
              decoration: InputDecoration(
                labelText: 'Tulis diskusi...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                if (_kontenController.text.isNotEmpty) {
                  postDiskusi(_kontenController.text); // Kirim diskusi
                }
              },
              child: Text('Post Diskusi'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.pink, // Use backgroundColor instead of primary
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// layar artikel // beri api untuk backend app get dari database artikel
class ArtikelScreen extends StatefulWidget {
  const ArtikelScreen({super.key});

  @override
  State<ArtikelScreen> createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<ArtikelScreen> {
  List<dynamic> artikel = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> getArtikel() async {
    try {
      final response =
          await http.get(Uri.parse('http://$ipAddress:$port/artikel'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Mengurutkan data berdasarkan tanggal_publikasi (tanggal terbaru di atas)
        data.sort((a, b) {
          DateTime aDate = DateTime.parse(a['tanggal_publikasi']);
          DateTime bDate = DateTime.parse(b['tanggal_publikasi']);
          return bDate.compareTo(aDate); // Mengurutkan dari yang terbaru
        });

        setState(() {
          artikel = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Error: $e';
      });
    }
  }

  // Fungsi untuk format timestamp
  String formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp); // Parse dari ISO8601 string
      final formattedDate =
          DateFormat('yyyy-MM-dd').format(dateTime); // Format tanggal
      final formattedTime =
          DateFormat('HH:mm').format(dateTime); // Format waktu
      return '$formattedDate, Jam: $formattedTime';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  void initState() {
    super.initState();
    getArtikel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Artikel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ))
                : ListView.builder(
                    itemCount: artikel.length,
                    itemBuilder: (context, index) {
                      final article = artikel[index];

                      // Ambil dan format tanggal_publikasi
                      final tanggalPublikasi =
                          article['tanggal_publikasi']?.toString() ?? 'N/A';
                      final formattedTanggalPublikasi =
                          formatTimestamp(tanggalPublikasi);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Navigasi ke halaman detail artikel
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailArtikelScreen(article: article),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article['judul']!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Ditulis oleh ${article['penulis']!}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Tanggal: $formattedTanggalPublikasi",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

//detail artikel
class DetailArtikelScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const DetailArtikelScreen({super.key, required this.article});

  // Helper function to format the timestamp
  String formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp); // Parse the ISO8601 string
      final formattedDate =
          DateFormat('yyyy-MM-dd').format(dateTime); // Format date
      final formattedTime = DateFormat('HH:mm').format(dateTime); // Format time
      return 'Tanggal: $formattedDate, Jam: $formattedTime';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the date for display
    final formattedTanggalPublikasi =
        formatTimestamp(article['tanggal_publikasi'] ?? '');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(article['judul'] ?? 'Artikel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Artikel
              Text(
                article['judul'] ?? 'Judul tidak tersedia',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Informasi Penulis dan Tanggal
              Text(
                "Ditulis oleh ${article['penulis'] ?? 'Penulis tidak tersedia'}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedTanggalPublikasi,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              // Konten Artikel
              Text(
                article['konten'] ?? 'Konten tidak tersedia',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//adopsi
class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  List<dynamic> kucing = [];
  bool isLoading = true;
  String errorMessage = '';

  // Function to fetch cats from the backend
  Future<void> getKucing() async {
    try {
      final response =
          await http.get(Uri.parse('http://$ipAddress:$port/adopsi'));

      if (response.statusCode == 200) {
        setState(() {
          kucing =
              json.decode(response.body)['data']; // Parsing the response data
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getKucing(); // Fetch data when the screen is first loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adopsi Kucing'),
        backgroundColor: Colors.pink,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/submenu');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kucing.length,
                  itemBuilder: (context, index) {
                    final cat = kucing[index];

                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama Kucing
                            Text(
                              'Nama: ${cat['nama'] ?? 'Tidak tersedia'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Jenis Kucing
                            Text(
                              'Jenis: ${cat['jenis'] ?? 'Tidak tersedia'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),

                            // Usia
                            Text(
                              'Usia: ${cat['usia'] ?? 'Tidak tersedia'} tahun',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),

                            // Berat
                            Text(
                              'Berat: ${cat['berat'] ?? 'Tidak tersedia'} kg',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),

                            // Gender
                            Text(
                              'Gender: ${cat['gender'] ?? 'Tidak tersedia'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),

                            // Kesehatan
                            Text(
                              'Kesehatan: ${cat['kesehatan'] ?? 'Tidak tersedia'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),

                            // Lokasi Penampungan
                            Text(
                              'Lokasi Penampungan: ${cat['lokasi_penampungan'] ?? 'Tidak tersedia'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),

                            // Deskripsi
                            Text(
                              'Deskripsi: ${cat['deskripsi'] ?? 'Tidak tersedia'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),

                            // Kontak Penampungan
                            Text(
                              'Kontak Penampungan: ${cat['kontak_penampungan'] ?? 'Tidak tersedia'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
