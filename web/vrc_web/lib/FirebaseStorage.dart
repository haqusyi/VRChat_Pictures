import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data'; // Web用のバイトデータ

class FirebaseStorageService {
  final FirebaseStorage _storage =
      FirebaseStorage.instanceFor(bucket: 'gs://vrchat-pictures.appspot.com');

  // Firebase Storageにファイルをアップロード
  Future<void> uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      // 固定バケットパスにアップロード
      Reference ref = _storage.ref().child(fileName);
      await ref.putData(fileBytes);
      print('File uploaded: $fileName');
    } catch (e) {
      print('Error during file upload: $e');
      throw e;
    }
  }
}
