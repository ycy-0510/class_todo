// import 'dart:async';
// import 'dart:typed_data';

// import 'package:class_todo_list/provider.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class FileNotifier extends StateNotifier<FileState> {
//   late FirebaseStorage storage;
//   Ref _ref;
//   FileNotifier(this._ref) : super(FileState([])) {
//     storage = FirebaseStorage.instance;
//     getFilesList();
//   }

//   Future<void> getFilesList() async {
//     state = FileState([], loading: true);
//     final storageRef = storage.ref().child('share');
//     try {
//       final listResult = await storageRef.listAll();
//       state = FileState(listResult.items);
//     } catch (e) {
//       _showError(e.toString());
//     }
//   }

//   void uploadFile(Uint8List file, String name) {
//     try {
//       storage
//           .ref()
//           .child('share/${DateTime.now().toIso8601String()}_$name')
//           .putData(
//             file,
//             SettableMetadata(
//               customMetadata: {'userId': _ref.read(authProvider).user!.uid},
//             ),
//           )
//           .snapshotEvents
//           .listen((event) {
//         switch (event.state) {
//           case TaskState.success:
//             _showError('上傳完成');
//             getFilesList();
//             break;
//           case TaskState.error:
//             _showError('發生錯誤');
//             break;
//           default:
//             break;
//         }
//       });
//     } catch (e) {
//       _showError(e.toString());
//     }
//   }

//   void _showError(String error) {
//     Fluttertoast.showToast(
//       msg: error,
//       timeInSecForIosWeb: 1,
//       webShowClose: true,
//     );
//   }
// }

// class FileState {
//   List<Reference> files;
//   bool loading;
//   FileState(this.files, {this.loading = false});
// }
