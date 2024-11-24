import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawFeeder',
      theme: ThemeData(primarySwatch: Colors.pink),
      initialRoute: '/home',
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
      },
    );
  }
}

// Layar Login
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.pets,
                        size: 50,
                        color: Colors.white,
                      ),
                      Text(
                        "Pawfeeder",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Input Email
              TextField(
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
                  onPressed: () {
                    // Navigasi ke SignUpScreen
                    Navigator.pushNamed(context, '/input_data');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Log In'),
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

// Layar Sign Up
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

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
            TextField(
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Surname',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
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
                onPressed: () {
                  // Aksi Sign Up
                  Navigator.pop(context); // Contoh: kembali ke login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Sign Up', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Layar Input Data Kucing

class InputDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Masukkan data diri kucing kesayangan Anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Jenis Kucing', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Gender', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Usia Kucing', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Berat Kucing', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {},
              label: Text('Upload Foto Kucing',
                  style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {
                Navigator.pushNamed(
                    context, '/home'); // Mengarahkan ke halaman HomePage
              },
              child: Text('Next', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Page

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('PawFeeder'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
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
            Card(
              child: ListTile(
                title: Text('Status Tag Collar'),
                subtitle: Text('Tersambung'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                title: Text('Ketersediaan Makanan'),
                subtitle: Text('90%'),
                trailing: Icon(Icons.fastfood, color: Colors.orange),
              ),
            ),
            SizedBox(height: 20),
            Text('Riwayat Pemberian Makanan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Kemarin: 08.00, 12.00, 17.00'),
              trailing: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: Text('Lihat Selengkapnya'),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('ON'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('OFF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Riwayat Makanan

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Riwayat Pemberian Makanan'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.pink),
              title: Text('19 September 2024'),
              subtitle: Text('08.00, 12.00, 17.00'),
            ),
          );
        },
      ),
    );
  }
}

//Sub Menu

class SubmenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Menu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          ListTile(
            leading: Icon(Icons.home, color: Colors.pink),
            title: Text('HOME'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.health_and_safety, color: Colors.pink),
            title: Text('Diskusi Kesehatan dan Makanan'),
            onTap: () {
              Navigator.pushNamed(context, '/discussion');
            },
          ),
          ListTile(
            leading: Icon(Icons.article, color: Colors.pink),
            title: Text('Artikel'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.pets, color: Colors.pink),
            title: Text('Adopsi Kucing'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.calendar_view_day_rounded, color: Colors.pink),
            title: Text('Penjadwalan Pawfeeder'),
            onTap: () {
              Navigator.pushNamed(context, '/penjadwalan_pawfeeder');
            },
          ),
          ListTile(
            leading: Icon(Icons.power_settings_new, color: Colors.red),
            title: Text('OFF Paw Feeder'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// Penjadwalan Pawfeeder
class PenjadwalanPawFeederScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penjadwalan Pawfeeder'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Penjadwalan (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(labelText: 'Kebutuhan Kalori'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Jam Makan 1'),
              items: ['07:00', '12:00', '18:00']
                  .map((time) =>
                      DropdownMenuItem(value: time, child: Text(time)))
                  .toList(),
              onChanged: (value) {},
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Jam Makan 2'),
              items: ['07:00', '12:00', '18:00']
                  .map((time) =>
                      DropdownMenuItem(value: time, child: Text(time)))
                  .toList(),
              onChanged: (value) {},
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Jam Makan 3'),
              items: ['07:00', '12:00', '18:00']
                  .map((time) =>
                      DropdownMenuItem(value: time, child: Text(time)))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}

class DiscussionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diskusi'),
        backgroundColor: Colors.pink[400], // Warna AppBar
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/cat1.png'),
            ),
            title: const Text('Kittenchu'),
            subtitle: const Text(
              'Kucing suka bermain tapi tidak bisa jalan, apa yang harus saya lakukan?',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up, color: Colors.pink[400]),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.mode_comment, color: Colors.redAccent[100]),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/cat2.jpg'),
            ),
            title: const Text('BudiSukaMakan'),
            subtitle: const Text(
              'Sudah berapa lama bikin kucing susah makan? Apa solusinya ya?',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up, color: Colors.pink[400]),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.mode_comment, color: Colors.redAccent[100]),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/cat3.jpg'),
            ),
            title: const Text('JaneMeowmeow'),
            subtitle: const Text(
              'Permisi, apa menyoo log saat kucingku menyoo, di sekitar area kelincik biasa?',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up, color: Colors.pink[400]),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.mode_comment, color: Colors.redAccent[100]),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/status'); // Arahkan ke StatusScreen
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'What\'s happening?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pets,
                      size: 80,
                      color: Colors.pink,
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Pet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
