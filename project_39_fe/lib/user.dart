// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:project_39_fe/rpc.dart';
// import 'package:project_39_fe/src/generated/project_39/v1/project_39.pb.dart';

// class UserPage extends StatefulWidget {
//   const UserPage({super.key});

//   @override
//   State<UserPage> createState() => _UserPageState();
// }

// class _UserPageState extends State<UserPage> {
//   File? _pickedFile;
//   String? _userId;
//   String? _userName;
//   String? _userEmail;

//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();

//     if (result != null) {
//       setState(() {
//         _pickedFile = File(result.files.single.path!);
//       });
//     }
//   }

//   Future<void> _uploadData() async {
//     final client = newRpcClient();
//     try {
//       final ret = client.putUserInfo(null);

//       // ignore: use_build_context_synchronously
//       await showDialog<String>(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//           title: const Text('上传成功'),
//           content: Text("待领养宠物编号 ${ret.objId}"),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, 'OK');
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } catch (err) {
//       // ignore: use_build_context_synchronously
//       await showDialog<String>(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//           title: const Text('上传失败'),
//           content: Text("Error: $err"),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, 'OK');
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(32.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           ElevatedButton(
//             onPressed: _pickFile,
//             child: const Text('选择宠物照片'),
//           ),
//           const SizedBox(height: 20),
//           TextField(
//             onChanged: (value) => _objName = value,
//             decoration: const InputDecoration(labelText: '宠物昵称'),
//           ),
//           TextField(
//             onChanged: (value) => _category = value,
//             decoration: const InputDecoration(labelText: '宠物类别'),
//           ),
//           TextField(
//             onChanged: (value) => _desc = value,
//             decoration: const InputDecoration(labelText: '宠物描述'),
//           ),
//           TextField(
//             onChanged: (value) => _location = value,
//             decoration: const InputDecoration(labelText: '宠物位置'),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _uploadData,
//             child: const Text('上传待领养宠物信息'),
//           ),
//         ],
//       ),
//     );
//   }
// }
