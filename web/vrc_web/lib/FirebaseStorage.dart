import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'dart:typed_data'; // Web用のバイトデータ

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Firebase Storageに画像をアップロードする関数
  Future<void> uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      // アップロード先のリファレンスを作成
      Reference ref = _storage.ref().child('uploads/$fileName');

      // Firebase Storageにファイルをアップロード
      UploadTask uploadTask = ref.putData(fileBytes);

      // アップロード完了を待つ
      await uploadTask.whenComplete(() {
        print('Uploaded: $fileName');
      });
    } catch (e) {
      print('Upload failed: $e');
      throw e; // 呼び出し元でエラー処理ができるように投げる
    }
  }
}
