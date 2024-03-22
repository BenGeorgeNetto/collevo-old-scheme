import 'dart:async';
import 'dart:io';
import 'package:collevo/colors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  static String? imagePath;

  static Future<void> getImageFromCamera(
      void Function(String?) setImagePath) async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }

    if (!isCameraGranted) {
      setImagePath(null);
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      setImagePath(null);
      return;
    }

    await _cropAndCompressImage(pickedFile.path, setImagePath);
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

    await _cropAndCompressImage(pickedFile.path, setImagePathCallback);
  }

  static Future<void> _cropAndCompressImage(
      String imagePath, void Function(String?) setImagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
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
      ],
    );

    if (croppedFile == null) {
      setImagePath(null);
      return;
    }

    // Check the file size and decide the compression quality
    final fileSize = await File(croppedFile.path).length();
    int quality;
    if (fileSize <= 1024 * 1024) {
      // for images less than 1MB
      quality = 90;
    } else if (fileSize <= 2 * 1024 * 1024) {
      // for images less than 2MB
      quality = 80;
    } else {
      // for images larger than 2MB
      quality = 70;
    }

    // Compress the cropped image dynamically based on its size
    final dir = await getTemporaryDirectory();
    final targetPath =
        join(dir.path, "${DateTime.now().millisecondsSinceEpoch}.jpeg");
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      croppedFile.path,
      targetPath,
      quality: quality,
    );

    final String? finalImagePath = compressedImage?.path;
    imagePath = finalImagePath!;
    setImagePath(finalImagePath);
  }
}
