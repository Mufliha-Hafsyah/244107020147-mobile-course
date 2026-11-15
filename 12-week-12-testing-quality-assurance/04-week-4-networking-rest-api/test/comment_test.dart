import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('fromJson berhasil parsing comment lengkap', () {
    final json = {
      'postId': 1,
      'id': 1,
      'name': 'Test Name',
      'email': 'test@example.com',
      'body': 'Ini komentar test',
    };
    final comment = Comment.fromJson(json);
    expect(comment.postId, 1);
    expect(comment.name, 'Test Name');
    expect(comment.body, 'Ini komentar test');
  });
}