import 'package:flutter/material.dart';
import 'package:project_39_fe/rpc.dart';
import 'package:project_39_fe/src/generated/project_39/v1/project_39.pbgrpc.dart';

const _horizontalPadding = 24.0;

final TextEditingController userNameTextEditingController =
    TextEditingController();
final TextEditingController passwordTextEditingController =
    TextEditingController();

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 2 * _horizontalPadding,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShrineLogo(),
                  SizedBox(height: 40),
                  _UsernameTextField(),
                  SizedBox(height: 16),
                  _PasswordTextField(),
                  SizedBox(height: 24),
                  _RegisterAndNextButtons(),
                  SizedBox(height: 62),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShrineLogo extends StatelessWidget {
  const _ShrineLogo();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            '注册',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class _UsernameTextField extends StatelessWidget {
  const _UsernameTextField();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
        width: 480,
        child: TextField(
          controller: userNameTextEditingController,
          textInputAction: TextInputAction.next,
          restorationId: 'username_text_field',
          cursorColor: colorScheme.onSurface,
          decoration: const InputDecoration(
            labelText: '用户名',
            labelStyle: TextStyle(
              letterSpacing: 0.04,
            ),
          ),
        ));
  }
}

class _PasswordTextField extends StatelessWidget {
  const _PasswordTextField();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
        width: 480,
        child: TextField(
          controller: passwordTextEditingController,
          restorationId: 'password_text_field',
          cursorColor: colorScheme.onSurface,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '密码',
            labelStyle: TextStyle(
              letterSpacing: 0.04,
            ),
          ),
        ));
  }
}

class _RegisterAndNextButtons extends StatelessWidget {
  const _RegisterAndNextButtons();

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;

    const buttonTextPadding =
        EdgeInsets.symmetric(horizontal: 24, vertical: 16);

    return Padding(
        padding: EdgeInsets.zero,
        child: OverflowBar(
            spacing: 0,
            alignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 8,
                  shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                ),
                onPressed: () async {
                  final client = newRpcClient();

                  client
                      .putUserInfo(PutUserInfoRequest(
                    userName: userNameTextEditingController.text,
                    password: passwordTextEditingController.text,
                  ))
                      .then((x) async {
                    await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('注册成功'),
                        content: Text("请使用 uid ${x.userId} 登陆，即将返回登陆页面"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'OK');
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }).onError((error, stackTrace) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("注册失败"),
                            content: SelectableText("$error"),
                          );
                        });
                  });
                },
                child: const Padding(
                  padding: buttonTextPadding,
                  child: Text(
                    '下一步',
                    style: TextStyle(
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 200, vertical: 100))
            ]));
  }
}
