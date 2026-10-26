import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:book_nest/main.dart';
import 'package:book_nest/models/book.dart';
import 'package:book_nest/providers/book_api_provider.dart';
import 'package:book_nest/providers/reading_list_provider.dart';
import 'package:book_nest/repositories/book_repository.dart';
import 'package:book_nest/services/open_library_service.dart';

class FakeBookRepository extends BookRepository {
  FakeBookRepository() : super(service: OpenLibraryService());

  @override
  Future<List<Book>> fetchBooks({
    String query = 'fiction',
    int limit = 20,
  }) async {
    return [];
  }
}

void main() {
  testWidgets('BookNest menampilkan halaman beranda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ReadingListProvider()),
          ChangeNotifierProvider(
            create: (_) => BookApiProvider(repository: FakeBookRepository()),
          ),
        ],
        child: const BookNestApp(),
      ),
    );

    await tester.pump();

    expect(find.text('BookNest'), findsOneWidget);
    expect(find.textContaining('Halo, pembaca!'), findsOneWidget);
    expect(find.text('Jelajahi Buku'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('My Library'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
