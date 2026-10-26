import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:book_nest/main.dart';
import 'package:book_nest/providers/reading_list_provider.dart';

void main() {
  testWidgets('BookNest menampilkan halaman beranda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ReadingListProvider(),
        child: const BookNestApp(),
      ),
    );

    expect(find.text('BookNest'), findsOneWidget);
    expect(find.textContaining('Halo, pembaca!'), findsOneWidget);
    expect(find.text('Jelajahi Buku'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('My Library'), findsOneWidget);
  });
}
