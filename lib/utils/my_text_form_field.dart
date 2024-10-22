// import 'package:flutter/material.dart';
//
// class MyTextFormField extends StatefulWidget {
//   const MyTextFormField({super.key});
//
//   @override
//   State<MyTextFormField> createState() => _MyTextFormFieldState();
// }
//
// class _MyTextFormFieldState extends State<MyTextFormField> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: TextFormField(
//         validator: (value) {
//           if (value == null || value.length == 0) {
//             return "Vui lòng điền mật khẩu!";
//           }
//           return null;
//         },
//         onFieldSubmitted: (_) {
//           if (_key.currentState!.validate()) {
//             print("Da xu ly");
//           } else {
//             print("loi roi ma");
//           }
//         },
//         obscureText: _hienThiMatKhau,
//         decoration: InputDecoration(
//           labelText: 'Mật khẩu',
//           hintText: 'Hãy nhập mật khẩu',
//           hintStyle: TextStyle(color: Colors.grey),
//           labelStyle: TextStyle(color: Colors.black),
//           prefixIcon:
//           Icon(Icons.lock, color: Colors.black),
//           suffixIcon: IconButton(
//             icon: Icon(
//                 _hienThiMatKhau
//                     ? Icons.visibility_off
//                     : Icons.visibility,
//                 color: Colors.black),
//             onPressed: () {
//               setState(() {
//                 _hienThiMatKhau = !_hienThiMatKhau;
//               });
//             },
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//                 color: Colors.black, width: 2),
//             borderRadius: BorderRadius.circular(30),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//                 color: Colors.black, width: 2),
//             borderRadius: BorderRadius.circular(30),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//                 color: Colors.red, width: 2),
//             borderRadius: BorderRadius.circular(30),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//                 color: Colors.redAccent, width: 2),
//             borderRadius: BorderRadius.circular(30),
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: EdgeInsets.symmetric(
//               vertical: 15, horizontal: 20),
//         ),
//         style: TextStyle(fontSize: 18),
//       ),
//     );
//   }
// }
