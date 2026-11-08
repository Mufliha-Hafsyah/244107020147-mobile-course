import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:campus_notify/data/token_store.dart';

class FakeSecureStorage extends FlutterSecureStoragePlatform {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({required String key, required Map<String, String> options}) async =>
      _data[key];

  @override
  Future<void> write({required String key, required String value, required Map<String, String> options}) async {
    _data[key] = value;
  }

  @override
  Future<void> delete({required String key, required Map<String, String> options}) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async => _data.clear();

  @override
  Future<bool> containsKey({required String key, required Map<String, String> options}) async =>
      _data.containsKey(key);

  @override
  Future<Map<String, String>> readAll({required Map<String, String> options}) async =>
      Map.from(_data);
}

void main() {
  test('TokenStore menyimpan dan membaca access/refresh token', () async {
    FlutterSecureStoragePlatform.instance = FakeSecureStorage();
    final store = TokenStore();

    await store.save(access: 'abc', refresh: 'xyz');

    expect(await store.readAccess(), 'abc');
    expect(await store.readRefresh(), 'xyz');
  });

  test('TokenStore.clear menghapus semua token', () async {
    FlutterSecureStoragePlatform.instance = FakeSecureStorage();
    final store = TokenStore();
    await store.save(access: 'abc', refresh: 'xyz');

    await store.clear();

    expect(await store.readAccess(), isNull);
  });
}