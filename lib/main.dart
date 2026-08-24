import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
     home: PerfilPage(),
        );
  }
}


class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {

  final ImagePicker picker = ImagePicker();

  File? fotoPerfil; 

  Future<void> escolherDaGaleria() async {
    final XFile? imagem = await picker.pickImage(
      source: ImageSource.gallery
      );

    if (imagem != null) {
      return;
      
      setState(() {
        fotoPerfil = File(imagem.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text ('Meu Perfil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: fotoPerfil != null ? FileImage(fotoPerfil!) : null,
              child: fotoPerfil == null ? const Icon(Icons.person, size: 60,) : null,
            ),

            const SizedBox(height: 20),

            const Text(
              'Vinicius Ribeiro',
                style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'vini@gmail.com',
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: escolherDaGaleria,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Alterar Foto'),
            ),
          ]
        ),
      ),
    );
  }
}