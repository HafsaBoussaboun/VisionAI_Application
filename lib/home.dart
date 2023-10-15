import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterTts ftts = FlutterTts();
  FlutterTts flutterTts = FlutterTts();
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
  String _scanBarcode = '';
  final picker = ImagePicker();

  Future _openCamera1() async {
    flutterTts.setLanguage('en');
    await flutterTts
        .speak("You clicked on the button that helps you to predict a person ");
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      _uploadImage_predict_person(_image!);
    }
  }

  Future<void> _openCamera2() async {
    flutterTts.setLanguage('en');
    await flutterTts
        .speak("You clicked on the button that helps you to red a short text ");
    final image = await _imagePicker.getImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });

      _uploadImage_extract_text(_image!);
    }
  }

  Future<void> _openCamera3() async {
    flutterTts.setLanguage('en');
    scanBarcodeNormal();
    await flutterTts.speak(
        "You clicked on the button that helps you to get a product informations from Barcode ");
  }

  Future<void> _openCamera4() async {
    flutterTts.setLanguage('en');
    await flutterTts.speak(
        "You clicked on the button that helps you to Predict a currency ");
    final image = await _imagePicker.getImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });

      _uploadImage_predict_currency(_image!);
    }
  }

  @override
  void initState() {
    super.initState();
    _speakWelcomeMessage();
  }

  Future<void> _speakWelcomeMessage() async {
    await ftts.awaitSpeakCompletion(true);
    await ftts.speak(
        'Welcome to our application. At the bottom, you will find four buttons. If you would like to read a short text, the text button is positioned on the left. Moving from left to right, you will find buttons for person detection, currency detection, and product detection from barcode.');
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _scanBarcode = barcodeScanRes;
      _sendBarcodeToAPI(_scanBarcode);
    });
  }

// envoyer le barcode à l'api
  Future<void> _sendBarcodeToAPI(String barcode) async {
    final url = Uri.parse('http://192.168.19.148:5000/query-database');
    final request = http.MultipartRequest('POST', url);
    request.fields['barcode'] = barcode;
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        await flutterTts.speak("Precessing, Please wait ");
        print("Envoyé avec succès");
        flutterTts.setLanguage('fr');
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> parsedResponse = json.decode(responseBody);
        String productName = parsedResponse['Title'];
        String commonname = parsedResponse['Common name'];
        String Quantity = parsedResponse['Quantity'];

        print(
            'Nom du produit: $productName, commonname: $commonname, Quantity: $Quantity');
        await flutterTts.speak(
            'Nom du produit: $productName, Nom Commun : $commonname, Quantité: $Quantity');
      } else {
        print(
            'Échec de l envoi du code-barres. Le serveur a répondu avec le code d état ${response.statusCode}');
        await flutterTts.speak('Failed to send barcode, please Try again');
      }
    } catch (e) {
      print('Erreur lors de lenvoi du code-barres: $e');
    }
  }

// Fonction pour envoyer l'image
  void _uploadImage_predict_person(File image) async {
    final url = Uri.parse('http://192.168.19.148:5000/predictPersons');
    final request = http.MultipartRequest('POST', url);
    List<int> imageBytes = await image.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'image',
      await image.readAsBytes(),
      filename: 'image.jpg',
    );
    request.files.add(multipartFile);

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        //print("succusfly sent")
        flutterTts.setLanguage('en');
        await flutterTts.speak('Processing Image , please wait ');
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> parsedResponse = json.decode(responseBody);
        String emotion = parsedResponse['emotion'];
        String age = parsedResponse['age'];
        String gender = parsedResponse['gender'];
        await flutterTts.speak(' $age year old  $gender looking $emotion : ');
      } else {
        print(
            'Failed to send image. Server responded with status code ${response.statusCode}');
        await flutterTts.speak('Failed to send image, please try again  ');
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }

// pour la prediction le l'argent
  void _uploadImage_predict_currency(File image) async {
    final url = Uri.parse('http://192.168.19.148:5000/CurrencyDetection');
    final request = http.MultipartRequest('POST', url);
    List<int> imageBytes = await image.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'image',
      await image.readAsBytes(),
      filename: 'image.jpg',
    );
    request.files.add(multipartFile);
    try {
      final response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        await flutterTts.speak('Processing Image , please wait ');
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> parsedResponse = json.decode(responseBody);
        String texte = parsedResponse["class"];
        print(texte);

        await flutterTts.setLanguage('fr');
        await flutterTts.speak('Vous avez  $texte Dirhams ');
      } else {
        flutterTts.setLanguage('en');
        await flutterTts.speak('Failed to send image, please Try again ');
        print(
            'Failed to send image. Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }

// Pour la prediction du Texte
  void _uploadImage_extract_text(File image) async {
    final url = Uri.parse('http://192.168.19.148:5000/extract-text');
    final request = http.MultipartRequest('POST', url);
    List<int> imageBytes = await image.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'image',
      await image.readAsBytes(),
      filename: 'image.jpg',
    );
    request.files.add(multipartFile);
    try {
      final response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        await flutterTts.speak('Processing Image , please wait ');
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> parsedResponse = json.decode(responseBody);
        String texte = parsedResponse["texte"];

        await langdetect.initLangDetect();
        String language = langdetect.detect(texte);
        print('langue detecté : $language');
        String config;
        if (language != null) {
          config = '-l $language';
        } else {
          // Langue par défaut si la détection de langue échoue
          config = '-l fra'; // Français
        }
        print(texte);

        await flutterTts.setLanguage('fr');
        await flutterTts.speak('Texte : $texte');
      } else {
        flutterTts.setLanguage('en');
        await flutterTts.speak('Failed to send image, please Try again ');
        print(
            'Failed to send image. Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 222, 224, 225),
        title: const Text('VISION-AI'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Handle menu button press
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              // Handle question mark button press
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Text(
              'No Such Image',
              style: TextStyle(fontSize: 10),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60,
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BottomButton(
                    icon: Icons.text_fields,
                    label: 'Text',
                    onPressed: _openCamera2,
                  ),
                  BottomButton(
                    icon: Icons.person,
                    label: 'Person',
                    onPressed: _openCamera1,
                  ),
                  BottomButton(
                    icon: Icons.attach_money,
                    label: 'Currency',
                    onPressed: _openCamera4,
                  ),
                  BottomButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Product',
                    onPressed: _openCamera3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const BottomButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
