import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/saved_book.dart';
import 'book_card.dart';

/// Grid responsif yang menampilkan daftar buku dengan adaptive layout
/// untuk ponsel kecil (320px), standar (375-430px), tablet (600-768px), dan desktop (1024-1440px+).
class BookGrid extends StatelessWidget {
  const BookGrid({
    super.key,
    required this.books,
    required this.savedBooks,
    required this.onQuickSave,
    required this.onCardTap,
  });

  final List<Book> books;
  final List<SavedBook> savedBooks;
  final void Function(Book book) onQuickSave;
  final void Function(Book book) onCardTap;

  bool _isSaved(String title) {
    return savedBooks.any((saved) => saved.title == title);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final int columns;
        final double extent;
        final double spacing;

        if (width >= 1100) {
          columns = 5;
          extent = 270;
          spacing = 16;
        } else if (width >= 820) {
          columns = 4;
          extent = 265;
          spacing = 14;
        } else if (width >= 560) {
          columns = 3;
          extent = 260;
          spacing = 12;
        } else if (width < 350) {
          // Extra small mobile screens (e.g. 320px)
          columns = 2;
          extent = 240;
          spacing = 8;
        } else {
          // Standard mobile screens
          columns = 2;
          extent = 255;
          spacing = 12;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: books.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: extent,
          ),
          itemBuilder: (context, index) {
            final book = books[index];

            return BookCard(
              book: book,
              isSaved: _isSaved(book.title),
              onToggleSaved: () => onQuickSave(book),
              onOpen: () => onCardTap(book),
            );
          },
        );
      },
    );
  }
}
