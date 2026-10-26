import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/book_api_provider.dart';
import 'providers/reading_list_provider.dart';
import 'repositories/book_repository.dart';
import 'screens/book_catalog_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_library_screen.dart';
import 'services/open_library_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReadingListProvider()),
        ChangeNotifierProvider(
          create: (_) => BookApiProvider(
            repository: BookRepository(service: OpenLibraryService()),
          ),
        ),
      ],
      child: const BookNestApp(),
    ),
  );
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

/// Navigasi utama.
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: lightBlue,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'My Library',
          ),
        ],
      ),
    );
  }
}
