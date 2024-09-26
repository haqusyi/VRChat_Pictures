import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

import 'package:vrchat_pictures_web/FirebaseStorage.dart'; // Web用のバイトデータ

class MultiFilePickerExample extends StatefulWidget {
  @override
  _MultiFilePickerExampleState createState() => _MultiFilePickerExampleState();
}

class _MultiFilePickerExampleState extends State<MultiFilePickerExample> {
  List<PlatformFile> selectedFiles = [];
  bool isUploading = false;
  String? uploadStatus;
  final FirebaseStorageService _firebaseStorageService =
      FirebaseStorageService(); // Firebase Storageサービスのインスタンス
  final TextEditingController _pathController =
      TextEditingController(); // パスを入力するためのコントローラー

  // 複数ファイルを選択する関数
  Future<void> pickMultipleFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image, // 画像ファイルのみ選択
      withData: true, // Webでバイトデータを取得する
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
      });
    } else {
      print('No files selected');
    }
  }

  // 選択した画像をFirebase Storageにアップロード
  Future<void> uploadFilesToFirebase() async {
    if (selectedFiles.isEmpty) {
      setState(() {
        uploadStatus = "No files selected for upload";
      });
      return;
    }

    String uploadPath = _pathController.text.isNotEmpty
        ? _pathController.text
        : 'uploads'; // パスが指定されていない場合のデフォルト

    setState(() {
      isUploading = true;
      uploadStatus = "Uploading...";
    });

    try {
      for (PlatformFile file in selectedFiles) {
        if (file.bytes != null) {
          // Firebase Storageにファイルをアップロード
          await _firebaseStorageService.uploadFile(
              file.bytes!, '$uploadPath/${file.name}'); // パスを指定してアップロード

          setState(() {
            uploadStatus = "Uploaded: ${file.name}";
          });
        }
      }
    } catch (e) {
      setState(() {
        uploadStatus = "Upload failed: $e";
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  // 選択されたファイルをクリア
  void clearSelectedFiles() {
    setState(() {
      selectedFiles.clear();
      _pathController.clear(); // テキストフィールドをクリア
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi Image Picker & Firebase Storage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pathController,
              decoration: InputDecoration(
                labelText: 'Upload Path',
                hintText: 'e.g. uploads/images',
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: pickMultipleFiles,
                  child: Text('Pick Images'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isUploading ? null : uploadFilesToFirebase,
                  child: isUploading
                      ? Text('Uploading...')
                      : Text('Upload Images'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: clearSelectedFiles,
                  child: Text('Clear Images'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (uploadStatus != null) Text(uploadStatus!),
            Expanded(
              child: selectedFiles.isNotEmpty
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = selectedFiles[index];

                        if (file.bytes != null) {
                          return Image.memory(
                            file.bytes!,
                            fit: BoxFit.cover,
                          );
                        } else {
                          return Center(
                            child: Text('Cannot display file'),
                          );
                        }
                      },
                    )
                  : Center(
                      child: Text('No images selected'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
