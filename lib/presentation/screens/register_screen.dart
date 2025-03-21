import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/register_provider.dart';
import '../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register() async {
    final registerProvider = Provider.of<RegisterProvider>(context, listen: false);
    String? message = await registerProvider.register(_usernameController.text, _passwordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Lỗi không xác định')),
    );

    if (message == "Đăng ký thành công!") {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerProvider = Provider.of<RegisterProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text("Đăng ký")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: _usernameController, label: "Tên đăng nhập"),
            SizedBox(height: 10),
            CustomTextField(controller: _passwordController, label: "Mật khẩu", isPassword: true),
            SizedBox(height: 16),
            registerProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      child: Text("Đăng ký"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
