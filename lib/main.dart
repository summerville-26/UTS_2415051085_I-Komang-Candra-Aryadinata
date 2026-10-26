import 'package:flutter/material.dart';

void main() {
  runApp(const BookNestApp());
}

class BookNestApp extends StatelessWidget {
  const BookNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4169E1)),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      ),
      home: const BookNestHomePage(),
    );
  }
}

class BookNestHomePage extends StatelessWidget {
  const BookNestHomePage({super.key});

  static const Color primaryBlue = Color(0xFF4169E1);
  static const Color pageBackground = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: primaryBlue),
            SizedBox(width: 10),
            Text('BookNest', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () {},
            icon: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isTablet = screenWidth >= 600;
          final isDesktop = screenWidth >= 900;

          final horizontalPadding = isDesktop
              ? 32.0
              : isTablet
              ? 24.0
              : 16.0;

          final contentMaxWidth = isDesktop ? 1100.0 : 900.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, Pembaca!',
                      style: TextStyle(
                        fontSize: isTablet ? 30 : 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Temukan buku yang ingin kamu baca hari ini.',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    // Banner menyesuaikan ukuran layar.
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isTablet ? 32 : 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4169E1), Color(0xFF7191F2)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: isTablet ? 48 : 42,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Temukan Cerita Favoritmu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 28 : 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Jelajahi berbagai buku dan mulai perjalanan '
                            'membacamu bersama BookNest.',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Jelajahi BookNest',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // HP: vertikal. Tablet/desktop: berdampingan.
                    if (!isTablet)
                      const Column(
                        children: [
                          _FeatureCard(
                            icon: Icons.explore_outlined,
                            title: 'Katalog Buku',
                            subtitle: 'Jelajahi koleksi',
                          ),
                          SizedBox(height: 12),
                          _FeatureCard(
                            icon: Icons.bookmark_outline,
                            title: 'Perpustakaan',
                            subtitle: 'Buku tersimpan',
                          ),
                        ],
                      )
                    else
                      const Row(
                        children: [
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.explore_outlined,
                              title: 'Katalog Buku',
                              subtitle: 'Jelajahi koleksi',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.bookmark_outline,
                              title: 'Perpustakaan',
                              subtitle: 'Buku tersimpan',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            label: 'Perpustakaan',
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EAF2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: const Color(0xFF4169E1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
