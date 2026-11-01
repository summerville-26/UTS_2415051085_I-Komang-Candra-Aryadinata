import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'providers/book_api_provider.dart';
import 'providers/reading_list_provider.dart';
import 'repositories/book_repository.dart';
import 'screens/book_catalog_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_library_screen.dart';
import 'services/open_library_service.dart';
import 'providers/reading_goal_provider.dart';
import 'providers/user_profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase dari file konfigurasi.
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabasePublishableKey,
    debug: true,
  );

  // Membuat sesi anonim jika belum ada sesi aktif.
  try {
    if (Supabase.instance.client.auth.currentSession == null) {
      await Supabase.instance.client.auth.signInAnonymously();
      debugPrint('SESSION SEBELUM ANON LOGIN:');
      debugPrint(
        'Current User: ${Supabase.instance.client.auth.currentUser?.id}',
      );
      debugPrint(
        'Current Session: ${Supabase.instance.client.auth.currentSession != null}',
      );
    }
  } catch (error, stackTrace) {
    debugPrint('Gagal membuat sesi anonim Supabase: $error');
    debugPrintStack(stackTrace: stackTrace);

    runApp(const SupabaseConnectionErrorApp());
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReadingListProvider()),
        ChangeNotifierProvider(
          create: (_) => ReadingGoalProvider(client: Supabase.instance.client),
        ),
        ChangeNotifierProvider(
          create: (_) => BookApiProvider(
            repository: BookRepository(service: OpenLibraryService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              UserProfileProvider(client: Supabase.instance.client)
                ..loadProfile(),
        ),
      ],
      child: const BookNestApp(),
    ),
  );
}

/// Ditampilkan jika Supabase gagal membuat sesi anonim.
class SupabaseConnectionErrorApp extends StatelessWidget {
  const SupabaseConnectionErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildBookNestTheme(),
      home: Scaffold(
        backgroundColor: pageBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(spacingMd),
                  decoration: BoxDecoration(
                    color: softPurple,
                    borderRadius: BorderRadius.circular(radiusMd),
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: primaryPurple,
                    size: 48,
                  ),
                ),
                const SizedBox(height: spacingMd),
                const Text(
                  'Koneksi Gagal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: spacingSm),
                const Text(
                  'Tidak dapat membuat sesi anonim Supabase.\n\n'
                  'Periksa koneksi internet, URL dan Publishable Key, '
                  'serta pengaturan Anonymous Sign-Ins di Supabase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryText, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget root aplikasi BookNest.
class BookNestApp extends StatelessWidget {
  const BookNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookNest',
      debugShowCheckedModeBanner: false,
      theme: buildBookNestTheme(),
      home: const MainNavigation(),
    );
  }
}

/// Navigasi utama BookNest.
/// State tab tetap lokal, sedangkan data dikelola oleh Provider.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final readingList = context.watch<ReadingListProvider>();
    final savedBooks = readingList.savedBooks;

    final pages = [
      HomeScreen(
        savedBooks: savedBooks,
        onOpenCatalog: () => setState(() => _selectedIndex = 1),
        onOpenLibrary: () => setState(() => _selectedIndex = 2),
        onQuickSave: readingList.toggleQuickSave,
        onAddBook: readingList.addBook,
        onDeleteBook: readingList.deleteBook,
      ),
      BookCatalogScreen(
        savedBooks: savedBooks,
        onQuickSave: readingList.toggleQuickSave,
        onAddBook: readingList.addBook,
        onDeleteBook: readingList.deleteBook,
      ),
      MyLibraryScreen(
        savedBooks: savedBooks,
        onUpdateBook: readingList.updateBook,
        onDeleteBook: readingList.deleteBook,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: borderColor),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          backgroundColor: Colors.transparent,
          indicatorColor: softPurple,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Catalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.collections_bookmark_outlined),
              selectedIcon: Icon(Icons.collections_bookmark_rounded),
              label: 'My Library',
            ),
          ],
        ),
      ),
    );
  }
}
