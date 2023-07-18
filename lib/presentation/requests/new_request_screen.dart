// ? Fetch user points for activityType before selecting dropdown3 or after
// TODO: Add logic to show if user can apply for points from that activity type

// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:collevo/colors.dart';
import 'package:collevo/enums/status_enum.dart';
import 'package:collevo/helpers/loading/loading_screen.dart';
import 'package:collevo/models/request.dart';
import 'package:collevo/services/cloud/activity_points_service.dart';
import 'package:collevo/services/cloud/firebase_storage_service.dart';
import 'package:collevo/services/cloud/request_upload_service.dart';
import 'package:collevo/services/preferences/preferences_service.dart';
import 'package:collevo/utilities/dialogs/remove_image_dialog.dart';
import 'package:collevo/utilities/dialogs/upload_request_dialog.dart';
import 'package:collevo/utilities/snackbars/upload_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:collevo/data/activities_lists.dart';
import 'package:collevo/services/image/image_service.dart';

class NewRequest extends StatefulWidget {
  const NewRequest({Key? key}) : super(key: key);

  @override
  State<NewRequest> createState() => _NewRequestState();
}

class _NewRequestState extends State<NewRequest> {
  String? _imagePath;
  String? _selectedItem1;
  String? _selectedItem2;
  String? _selectedItem3;
  String? _activityId;

  int? _selectedIndex1;
  int? _selectedIndex2;
  int? _selectedIndex3;

  final List<String> _dropdownItems1 = dropdownItems1;
  final Map<String, List<String>> _dropdownItems2 = dropdownItems2;
  final Map<String, List<String>> _dropdownItems3 = dropdownItems3;

  bool canUploadRequest = false;

  final ActivityPointsService _activityPointsService = ActivityPointsService();

  Future<void> getImageFromCamera() async {
    await ImageService.getImageFromCamera((String? imagePath) {
      setState(() {
        _imagePath = imagePath;
      });
    });
  }

  Future<void> getImageFromGallery() async {
    await ImageService.getImageFromGallery((String? imagePath) {
      setState(() {
        _imagePath = imagePath;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("New Request"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Activity Type',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text('Select Activity Type'),
                      value: _selectedItem1,
                      isExpanded: true,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedItem1 = newValue;
                          _selectedIndex1 = _dropdownItems1.indexOf(newValue!);
                          _selectedItem2 = null;
                          _selectedIndex2 = null;
                          _selectedItem3 = null;
                          _selectedIndex3 = null;
                          _activityId = null;
                        });
                      },
                      items: _dropdownItems1.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: Theme.of(context).textTheme.headlineSmall,
                            overflow: TextOverflow.visible,
                          ),
                        );
                      }).toList(),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Visibility(
                  visible: _selectedItem1 != null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Activity',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text('Select Activity'),
                            value: _selectedItem2,
                            isExpanded: true,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedItem2 = newValue;
                                _selectedIndex2 =
                                    _dropdownItems2[_selectedItem1]
                                        ?.indexOf(newValue!);
                                _selectedItem3 = null;
                                _selectedIndex3 = null;
                                _activityId = null;
                              });
                            },
                            items: _dropdownItems2[_selectedItem1]
                                ?.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.visible,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              );
                            }).toList(),
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Visibility(
                  visible: _selectedItem2 != null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Activity Level',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text('Select Activity Level'),
                            value: _selectedItem3,
                            isExpanded: true,
                            onChanged: (newValue) async {
                              setState(() {
                                _selectedItem3 = newValue;
                                _selectedIndex3 =
                                    _dropdownItems3[_selectedItem2]
                                        ?.indexOf(newValue!);
                                _activityId =
                                    '${_selectedIndex1}_${_selectedIndex2}_$_selectedIndex3';
                              });

                              canUploadRequest = await _activityPointsService
                                  .checkIfCanInsertActivityPoints(_activityId!);

                              setState(() {
                                canUploadRequest = canUploadRequest;
                              });
                            },
                            items: _dropdownItems3[_selectedItem2]
                                ?.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.visible,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              );
                            }).toList(),
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Visibility(
                  visible: _selectedItem3 != null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'Selected Activity Type: $_selectedItem1',
                        // ),
                        // Text(
                        //   'Selected Activity: $_selectedItem2',
                        // ),
                        // Text(
                        //   'Selected Activity Level: $_selectedItem3',
                        // ),
                        // const SizedBox(height: 16.0),
                        // Text(
                        //   'Activity ID: $_activityId',
                        // ),
                        // const SizedBox(height: 32.0),
                        Visibility(
                          visible: canUploadRequest,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: getImageFromCamera,
                                child: const Text('Take Photo'),
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: getImageFromGallery,
                                child: const Text('Upload Photo'),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: !canUploadRequest,
                          child: const Text(
                            'Cannot upload request of this type as you have exceeded the points that you can get from this activity type.',
                          ),
                        ),
                        Visibility(
                          visible: _imagePath != null,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 32.0, 8.0, 16.0),
                                child: Image.file(
                                  File(_imagePath ?? ''),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  bool? confirm =
                                      await showRemoveImageDialog(context);
                                  if (confirm == true) {
                                    setState(() {
                                      _imagePath = null;
                                    });
                                  }
                                },
                                child: const Text('Remove Photo'),
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () async {
                                  bool? confirm =
                                      await showUploadRequestDialog(context);
                                  if (confirm == true) {
                                    LoadingScreen().show(
                                        context: context,
                                        text: 'Uploading Request...');
                                    final preferencesService =
                                        PreferencesService();
                                    final requestUploadService =
                                        RequestUploadService();
                                    final uid =
                                        await preferencesService.getUid();
                                    final tid =
                                        await preferencesService.getTid();

                                    try {
                                      String imageUrl =
                                          await FirebaseStorageService
                                              .uploadImage(
                                        uid!,
                                        _imagePath!,
                                      );
                                      final String requestId =
                                          await generateRequestId();
                                      final Request request = Request(
                                        activityId: _activityId!,
                                        assignedTo: tid!,
                                        createdAt: DateTime.now(),
                                        createdBy: uid,
                                        imageUrl: imageUrl,
                                        requestId: requestId,
                                        status: Status.pending,
                                        activityType: _selectedItem1!,
                                        activity: _selectedItem2!,
                                        activityLevel: _selectedItem3!,
                                      );
                                      await requestUploadService
                                          .uploadRequest(request);
                                      showUploadSuccessSnackbar(context);
                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        Navigator.pop(context);
                                      });
                                    } catch (e) {
                                      // print('Error: $e');
                                      showUploadFailedSnackbar(context);
                                    }
                                    LoadingScreen().hide();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColors.giga,
                                ),
                                child: const Text(
                                  'Upload Request',
                                  style: TextStyle(
                                    color: CustomColors.blueGray,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<String> generateRequestId() async {
  var dateTime = DateTime.now();
  PreferencesService preferencesService = PreferencesService();
  var name = await preferencesService.getName();
  var formattedDateTime = dateTime.toString().replaceAll(RegExp(r'[-:. ]'), '');
  return 'req_${name}_$formattedDateTime';
}
