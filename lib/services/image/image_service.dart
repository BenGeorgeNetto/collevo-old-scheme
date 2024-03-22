import 'dart:async';
import 'dart:io';
import 'package:collevo/colors.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  static String? imagePath;

  static Future<void> getImageFromCamera(
      void Function(String?) setImagePath) async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      setImagePath(null);
      return;
    }

    final List<String>? pictures =
        await CunningDocumentScanner.getPictures(true);
    if (pictures == null || pictures.isEmpty) {
      setImagePath(null);
      return;
    }

    String scannedImagePath = pictures.first;
    await _compressImage(scannedImagePath, setImagePath);
  }

  static Future<void> getImageFromGallery(
      void Function(String?) setImagePathCallback) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      setImagePathCallback(null);
      return;
    }

    final CroppedFile? croppedFile = await ImageCropper()
        .cropImage(sourcePath: pickedFile.path, aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ], uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: darkColorScheme.primary,
        toolbarWidgetColor: darkColorScheme.onPrimary,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      IOSUiSettings(
        title: 'Crop Image',
      ),
    ]);

    if (croppedFile == null) {
      setImagePathCallback(null);
      return;
    }

    await _compressImage(croppedFile.path, setImagePathCallback);
  }

  static Future<void> _compressImage(
      String imagePath, void Function(String?) setImagePath) async {
    final fileSize = await File(imagePath).length();
    int quality = _determineQuality(fileSize);

    final dir = await getTemporaryDirectory();
    final targetPath =
        join(dir.path, "${DateTime.now().millisecondsSinceEpoch}.jpeg");
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      targetPath,
      quality: quality,
    );

    final String? finalImagePath = compressedImage?.path;
    ImageService.imagePath = finalImagePath;
    setImagePath(finalImagePath);
  }

  static int _determineQuality(int fileSize) {
    if (fileSize <= 1024 * 1024) {
      // less than or equal to 1MB
      return 90;
    } else if (fileSize <= 2 * 1024 * 1024) {
      // less than or equal to 2MB
      return 75;
    } else {
      // larger than 2MB
      return 60;
    }
  }
}
