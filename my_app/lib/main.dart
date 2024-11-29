import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawFeeder',
      theme: ThemeData(primarySwatch: Colors.pink),
      initialRoute: '/home',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/input_data': (context) => const InputDataScreen(),
        '/home': (context) => const HomeScreen(),
        '/history': (context) => const HistoryScreen(),
        '/submenu': (context) => const SubmenuScreen(),
        '/penjadwalan_pawfeeder': (context) =>
            const PenjadwalanPawFeederScreen(),
        '/discussion': (context) => const DiscussionScreen(),
        '/status': (context) => const StatusScreen(),
        '/artikel': (context) => const ArtikelScreen(),
        '/adopsi_kucing': (context) => const AdoptionScreen(),
      },
    );
  }
}

// Layar Login
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
  const SignUpScreen({super.key});

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
                child: const Text('Sign Up',
                    style: TextStyle(color: Colors.white)),
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
  const InputDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Masukkan data diri kucing kesayangan Anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                  labelText: 'Jenis Kucing', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                  labelText: 'Gender', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                  labelText: 'Usia Kucing', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                  labelText: 'Berat Kucing', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {},
              label: const Text('Upload Foto Kucing',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {
                Navigator.pushNamed(
                    context, '/home'); // Mengarahkan ke halaman HomePage
              },
              child: const Text('Next', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Page

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            const Card(
              child: ListTile(
                title: Text('Status Tag Collar'),
                subtitle: Text('Tersambung'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            const SizedBox(height: 10),
            const Card(
              child: ListTile(
                title: Text('Ketersediaan Makanan'),
                subtitle: Text('90%'),
                trailing: Icon(Icons.fastfood, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Riwayat Pemberian Makanan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Kemarin: 08.00, 12.00, 17.00'),
              trailing: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: const Text('Lihat Selengkapnya'),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('ON'),
                ),
                ElevatedButton(
                  onPressed: () {},
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

// Halaman Riwayat Makanan

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Riwayat Pemberian Makanan'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return const Card(
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
                  context, '/artikel'); // Navigasi ke ArtikelScreen
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
            title: const Text('OFF Paw Feeder'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// Penjadwalan Pawfeeder
class PenjadwalanPawFeederScreen extends StatelessWidget {
  const PenjadwalanPawFeederScreen({super.key});

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
            const TextField(
              decoration: InputDecoration(labelText: 'Kebutuhan Kalori'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Jam Makan 1'),
              items: ['07:00', '12:00', '18:00']
                  .map((time) =>
                      DropdownMenuItem(value: time, child: Text(time)))
                  .toList(),
              onChanged: (value) {},
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Jam Makan 2'),
              items: ['07:00', '12:00', '18:00']
                  .map((time) =>
                      DropdownMenuItem(value: time, child: Text(time)))
                  .toList(),
              onChanged: (value) {},
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Jam Makan 3'),
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
  const DiscussionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diskusi'),
        backgroundColor: Colors.pink[400], // Warna AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/submenu');
            },
          ),
        ],
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
  const StatusScreen({super.key});

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
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const Center(
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

class ArtikelScreen extends StatelessWidget {
  const ArtikelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> articles = [
      {
        "title": "Ketahui 13 Jenis Kucing yang Paling Bersahabat",
        "source": "Halodoc",
        "date": "April 24",
        "image": "https://via.placeholder.com/150",
        "content":
            "Artikel ini membahas 13 jenis kucing yang memiliki sifat ramah dan bersahabat, cocok sebagai hewan peliharaan."
      },
      {
        "title": "7 Manfaat Memelihara Kucing di Rumah",
        "source": "detikcom",
        "date": "Aug 24",
        "image": "https://via.placeholder.com/150",
        "content":
            "Memelihara kucing di rumah dapat memberikan banyak manfaat, termasuk mengurangi stres dan memberikan kebahagiaan."
      },
      {
        "title": "Manfaat Memelihara Kucing dari Self Healing",
        "source": "CNN",
        "date": "Sep 26",
        "image": "https://via.placeholder.com/150",
        "content":
            "Artikel ini membahas bagaimana kucing dapat membantu manusia dalam proses penyembuhan diri atau self-healing."
      },
      {
        "title": "Perilaku dan Temperamen Kucing",
        "source": "Kumparan",
        "date": "Mei 24",
        "image": "https://via.placeholder.com/150",
        "content":
            "Perilaku dan temperamen kucing bervariasi tergantung pada jenis dan cara mereka dibesarkan. Artikel ini mengulasnya secara detail."
      },
      {
        "title": "Dari Ragdoll Hingga Sphynx: 10 Ras Kucing Populer",
        "source": "Kompas",
        "date": "Jan 15",
        "image": "https://via.placeholder.com/150",
        "content":
            "Kenali 10 ras kucing paling populer di dunia, mulai dari Ragdoll yang lembut hingga Sphynx yang unik."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Kucing'),
        backgroundColor: Colors.pink,
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ListTile(
            leading: Image.network(article['image']!),
            title: Text(article['title']!),
            subtitle: Text(article['source']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtikelDetailScreen(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ArtikelDetailScreen extends StatelessWidget {
  final Map<String, String> article;

  const ArtikelDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']!),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(article['image']!),
            const SizedBox(height: 16),
            Text(
              article['title']!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Sumber: ${article['source']} - ${article['date']}",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  article['content']!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () {
          final String shareText =
              'Baca artikel menarik: ${article['title']}\n\n${article['content']}';
          Share.share(shareText); // Pastikan package share_plus sudah diinstal
        },
        child: const Icon(Icons.share),
      ),
    );
  }
}

class AdoptionScreen extends StatelessWidget {
  const AdoptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> cats = [
      {"image": "assets/cat1.png", "name": "Persia"},
      {"image": "https://via.placeholder.com/150", "name": "Siamese"},
      {"image": "https://via.placeholder.com/150", "name": "Bengal"},
      {"image": "https://via.placeholder.com/150", "name": "Maine Coon"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adopsi Kucing'),
        backgroundColor: Colors.pink,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final cat = cats[index];
          return GestureDetector(
            onTap: () {
              // Bisa tambahkan aksi untuk detail adopsi
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      cat['image']!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.pink,
                    ),
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
