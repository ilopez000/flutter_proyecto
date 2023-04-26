import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pantalla_usuario.dart';

const apiUrl = 'http://localhost:3000/proyecto_flutter/login';
const apiUrlIncrementEntradas = 'http://localhost:3000/proyecto_flutter/incrementEntradas';

Future<String> login(GlobalKey<NavigatorState> navigatorKey, LoginData data) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    body: jsonEncode({'email': data.name, 'password': data.password}),
    headers: {'Content-Type': 'application/json'},
  );

  final jsonResponse = jsonDecode(response.body);

  if (response.statusCode == 200 && jsonResponse['success']) {
    // Incrementar las entradas para el usuario
    await incrementEntradas(data.name);
    // Login successful, navigate to UserScreen
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => UserScreen(email: data.name)),
    );
    return Future.value('');
  } else {
    return Future.value(jsonResponse['message'] ?? 'Ocurrió un error');
  }
}

Future<void> incrementEntradas(String email) async {
  final response = await http.post(
    Uri.parse(apiUrlIncrementEntradas),
    body: jsonEncode({'email': email}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode != 200) {
    print('Error incrementando las entradas para el correo electrónico $email');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: FlutterLogin(
          title: 'Proyecto Flutter',
          logo: 'assets/logo_flutter.png',
          onLogin: (loginData) => login(navigatorKey, loginData),
          onSignup: (_) => Future.value(null), // No implementamos el registro en este ejemplo
          onSubmitAnimationCompleted: () {},
          onRecoverPassword: (_) => Future.value(''), // No implementamos la recuperación de contraseña en este ejemplo
          messages: LoginMessages(
            userHint: 'Tu correo electrónico',
            passwordHint: 'Tu contraseña',
            confirmPasswordHint: 'Confirma tu contraseña',
            loginButton: 'INICIAR SESIÓN',
            signupButton: 'REGISTRARSE',
            forgotPasswordButton: '¿OLVIDASTE TU CONTRASEÑA?',
            recoverPasswordButton: 'RECUPERAR CONTRASEÑA',
            goBackButton: 'REGRESAR',
            confirmPasswordError: 'Las contraseñas no coinciden',
            recoverPasswordDescription:
            'Introduce tu correo electrónico para recibir un enlace y restablecer tu contraseña',
            recoverPasswordSuccess: 'Se ha enviado el enlace de recuperación a tu correo electrónico',
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String token;

  HomePage({required this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Página de inicio'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Token de autenticación:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                token,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Cerrar sesión y volver a la pantalla de inicio de sesión
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


