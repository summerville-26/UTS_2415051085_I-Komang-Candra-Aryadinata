import 'package:flutter_test/flutter_test.dart';
import 'package:book_nest/main.dart';

void main() {
  testWidgets('BookNest menampilkan halaman beranda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BookNestApp());

    expect(find.text('BookNest'), findsOneWidget);
    expect(find.text('Halo, Pembaca!'), findsOneWidget);
    expect(find.text('Jelajahi BookNest'), findsOneWidget);
    expect(find.text('Katalog Buku'), findsOneWidget);
    expect(find.text('Perpustakaan'), findsNWidgets(2));
  });
}
