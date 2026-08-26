import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? fotoPerfil;

  Future<void> escolherDaGaleria() async {
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem == null) {
      return;
    }

    setState(() {
      fotoPerfil = File(imagem.path);
    });
  }

  Future<void> tirarFoto() async {
    final XFile? imagem = await picker.pickImage(source: ImageSource.camera);

    if (imagem == null) {
      return;
    }

    setState(() {
      fotoPerfil = File(imagem.path);
    });
  }

  void mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  escolherDaGaleria();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  tirarFoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File> guardarFoto(File foto) async {
    final pasta = await getApplicationDocumentsDirectory();

    final caminho = '${pasta.path}/foto_perfil.png';

    return foto.copy(caminho);
  }

  Future<void> salvarPerfil() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();

    if (nome.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nome', nome);
    await prefs.setString('email', email);

    if (fotoPerfil != null) {
      final fotoSalva = await guardarFoto(fotoPerfil!);

      await prefs.setString('foto', fotoSalva.path);

      if (mounted) {
        setState(() {
          fotoPerfil = fotoSalva;
        });
      }
    }

    if (!mounted) {
        return;
      }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil salvo com sucesso!'
    )
    ),
  );
}


Future<void> carregarPerfil() async {
  final prefs = await SharedPreferences.getInstance();

  final nome = prefs.getString('nome');
  final email = prefs.getString('email');
  final caminhoFoto = prefs.getString('foto');


  nomeController.text = nome ?? '';
  emailController.text = email ?? '';

  if (caminhoFoto != null) {
   final arquivo = File(caminhoFoto);

    if (await arquivo.exists()) {
        setState(() {
          fotoPerfil = arquivo;
        });
    }
  }
}

  @override
  void initState() {
    super.initState();
    carregarPerfil();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu Perfil")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: fotoPerfil != null
                    ? FileImage(fotoPerfil!)
                    : null,
                child: fotoPerfil == null
                    ? const Icon(Icons.person, size: 70)
                    : null,
              ),

              const SizedBox(height: 20),

              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: salvarPerfil,
                  icon: const Icon(Icons.save),
                  label: const Text("Salvar Perfil"),
                ),
              ),

              ElevatedButton.icon(
                onPressed: mostrarOpcoesFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Alterar Foto"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
