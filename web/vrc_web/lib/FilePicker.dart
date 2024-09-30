import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  List<html.File>? _selectedFiles = [];
  List<String>? _selectedFilesNames = [];
  bool _isUploading = false; // アップロード中のフラグ
  int _uploadedCount = 0; // アップロード済みのファイル数

  /// ファイル選択処理
  Future<void> _pickImages() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.multiple = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        setState(() {
          _selectedFiles = files;
          _selectedFilesNames = files.map((file) => file.name).toList();
        });
      }
    });
  }

  /// 選択した画像をFirebase Storageにアップロード
  Future<void> _uploadImages() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) return;

    setState(() {
      _isUploading = true; // アップロード開始
      _uploadedCount = 0; // アップロード済みファイルのリセット
    });

    // 現在の日付を取得してフォルダ名に使う
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (var file in _selectedFiles!) {
      try {
        String fileName = file.name;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/$currentDate/$fileName');

        // アップロードタスク
        final uploadTask = storageRef.putBlob(file);

        // アップロードが完了するまで待機
        await uploadTask.whenComplete(() {
          setState(() {
            _uploadedCount++; // アップロード済みファイル数の更新
          });
        });

        String downloadURL = await storageRef.getDownloadURL();
        print("File uploaded successfully! URL: $downloadURL");
      } catch (e) {
        print("Error uploading file: $e");
      }
    }

    setState(() {
      _isUploading = false; // アップロード完了
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Multiple Images")),
      body: Column(
        children: [
          // ファイル選択ボタン
          ElevatedButton(
            onPressed: _pickImages,
            child: Text("Pick Images"),
          ),

          // 選択された画像名の表示
          _selectedFilesNames != null && _selectedFilesNames!.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _selectedFilesNames!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_selectedFilesNames![index]),
                      );
                    },
                  ),
                )
              : Text("No images selected"),

          // アップロードボタン（アップロード中は無効化）
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadImages,
            child: Text("Upload Images"),
          ),

          // アップロード中の画面（ローディングインジケーターと進捗）
          if (_isUploading)
            Column(
              children: [
                SizedBox(height: 20),
                CircularProgressIndicator(), // ローディングインジケーター
                SizedBox(height: 20),
                Text(
                    "Uploading ${_uploadedCount}/${_selectedFiles!.length} files..."), // アップロード進捗表示
              ],
            ),
        ],
      ),
    );
  }
}
