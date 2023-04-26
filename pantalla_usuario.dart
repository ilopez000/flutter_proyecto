import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserScreen extends StatefulWidget {
  final String email;

  UserScreen({required this.email});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  TextEditingController _descripcionController = TextEditingController();

  Future<Uint8List> _getImageByEmail(String email) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/proyecto_flutter/getImageByEmail'),
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Error al cargar la imagen');
    }
  }

  Future<String> getDescripcion(String email) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/proyecto_flutter/getDescripcion'),
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['descripcion'];
    } else {
      throw Exception('Error al obtener la descripción');
    }
  }

  Future<void> updateDescripcion(String email, String descripcion) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/proyecto_flutter/updateDescripcion'),
      body: jsonEncode({'email': email, 'descripcion': descripcion}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la descripción');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
        appBar: AppBar(
        title: Text('Datos Usuario'),
        automaticallyImplyLeading: false,
    ),
          body: Center(
          child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    FutureBuilder<Uint8List>(
    future: _getImageByEmail(widget.email),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return CircularProgressIndicator();
    } else if (snapshot.hasError) {
    return Text('Error al cargar la imagen');
    } else {
    return Image.memory(
    snapshot.data!,
    width: 200,
    height: 200,
    fit: BoxFit.cover,
      );
      }
      },
      ),
      SizedBox(height: 20),
      Text(
      'Correo electrónico:',
      style: TextStyle(fontSize: 24),
      ),
      SizedBox(height: 10),
      Text(
      widget.email,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 20),
      Text(
      'Descripción:',
      style: TextStyle(fontSize: 24),
      ),
      SizedBox(height: 10),
      FutureBuilder<String>(
      future: getDescripcion(widget.email),
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
      } else if (snapshot.hasError) {
      return Text('Error al obtener la descripción');
      } else {
      _descripcionController.text = snapshot.data!;
      return TextField(
      controller: _descripcionController,
        decoration: InputDecoration(
          labelText: 'Descripción',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
    );
    }
    },
    ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: () async {
          await updateDescripcion(widget.email, _descripcionController.text);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Descripción actualizada')));
        },
        child: Text('Actualizar descripción'),
      ),
    ],
    ),
    ),
    ),
        ),
    );
  }
}

