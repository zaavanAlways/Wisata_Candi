import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/candi.dart';

class DetailScreen extends StatefulWidget {
  final Candi candi;

  const DetailScreen({super.key, required this.candi});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  bool isSignedIn = false; // Menyimpan status sign in

  @override
  void initState() {
    super.initState();
    _checkSignInStatus(); // Memeriksa status sign in saat layar dimuat
    _loadFavoriteStatus(); // Memeriksa status favorit saat layar dimuat
  }

  // Memeriksa status sign in
  void _checkSignInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool signedIn = prefs.getBool('isSignedIn') ?? false;
    setState(() {
      isSignedIn = signedIn;
    });
  }

  // Memeriksa status favorit
  void _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool favorite = prefs.getBool('favorite_${widget.candi.name}') ?? false;
    setState(() {
      isFavorite = favorite;
    });
  }

  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Memeriksa apakah pengguna sudah sign in
    if (!isSignedIn) {
      // Jika belum sign in, arahkan ke SignInScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/signin');
      });
      return;
    }

    bool favoriteStatus = !isFavorite;
    prefs.setBool('favorite_${widget.candi.name}', favoriteStatus);

    setState(() {
      isFavorite = favoriteStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // image utama
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      widget.candi.imageAsset,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[100]?.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // info atas (nama candi dan tombol favorit)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.candi.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            _toggleFavorite();
                          },
                          icon: Icon(
                            isSignedIn && isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isSignedIn && isFavorite ? Colors.red : null,
                          )),
                    ],
                  ),
                  // info tengah (lokasi, dibangun, tipe)
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.place,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 70,
                        child: Text(
                          'Lokasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        ': ${widget.candi.location}',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 70,
                        child: Text(
                          'Dibangun',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        ': ${widget.candi.built}',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.house,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 70,
                        child: Text(
                          'Tipe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        ': ${widget.candi.type}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: Colors.deepPurple.shade100,
                  ),
                  const SizedBox(height: 16),
                  // info bawah (deskripsi)
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.candi.description,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  // DetailGallery
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Colors.deepPurple.shade100,
                        ),
                        const Text(
                          'Galeri',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.candi.imageUrls.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.deepPurple.shade100,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              widget.candi.imageUrls[index],
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            width: 120,
                                            height: 120,
                                            color: Colors.deepPurple[50],
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        const Text(
                          'Tap untuk memperbesar',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
