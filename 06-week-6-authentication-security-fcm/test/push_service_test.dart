import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/messaging/push_service.dart';

void main() {
  test('routeFromMessage mengembalikan route dari data', () {
    final route = routeFromMessage({'route': '/pengumuman/3'});
    expect(route, '/pengumuman/3');
  });

  test('routeFromMessage menormalkan route tanpa garis miring di awal', () {
    final route = routeFromMessage({'route': 'pengumuman/5'});
    expect(route, '/pengumuman/5');
  });

  test('routeFromMessage default ke "/" jika data kosong', () {
    final route = routeFromMessage({});
    expect(route, '/');
  });
}