import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/format.dart';

void main() {
  test('parseNoteId membaca id dari string', () {
    expect(parseNoteId('42'), 42);
  });

  test('tabIndexForLocation memilih tab Posts untuk rute /posts', () {
    expect(tabIndexForLocation('/posts'), 1);
    expect(tabIndexForLocation('/'), 0);
  });
}