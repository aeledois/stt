import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reconhecimento de fala',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _speechEnabled = false;
  String _fala = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    List<stt.LocaleName> locales = await _speechToText.locales();
    bool isPtBrAvailable =
        locales.any((locale) => locale.localeId.toLowerCase() == 'pt_br');

    setState(() {
      if (!isPtBrAvailable) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Português Brasileiro não está disponível.')));
        }
      }
    });
  }

  void _escuta() async {
    await _speechToText.listen(onResult: _capturaFala);
    setState(() {});
  }

  void _paraEscuta() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _capturaFala(result) {
    setState(() {
      _fala = "${result.recognizedWords}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        backgroundColor: Colors.blue,
        title:
        const Text( 'Reconhecimento de fala',
          style: TextStyle(color: Colors.white,),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              _speechToText.isListening
                  ? "Escutando..."
                  : _speechEnabled
                      ? "Toque no microfone para falar..."
                      : "Escuta não disponível",
              style: const TextStyle(fontSize: 20.0),
            ),
            const Divider(thickness: 5,color: Colors.black, ),
            Text(
              _fala,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w400,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isListening ? _paraEscuta : _escuta,
        tooltip: 'Escutar',
        backgroundColor: Colors.green,
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }
}
