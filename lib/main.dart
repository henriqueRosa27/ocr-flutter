import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter OCR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'OCR - Flutter - Tesseract'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File imageFile;
  bool imageLoaded = false;
  bool textLoaded = false;
  String textExtracted;

  openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (picture != null) {
      this.setState(() {
        imageFile = picture;
        imageLoaded = true;
      });
    }
    Navigator.of(context).pop();
  }

  openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      this.setState(() {
        imageFile = picture;
        imageLoaded = true;
      });
    }
    Navigator.of(context).pop();
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
          title: const Text('Escolha sua opção'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('Galeria'),
              onPressed: () {
                openGallery(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Camera'),
              onPressed: () {
                openCamera(context);
              },
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, 'Cancelar');
            },
          )),
    );
  }

  Function buttonDisbled() {
    if (!imageLoaded) {
      return null;
    } else {
      return () {
        _extractText();
      };
    }
  }

  void _extractText() async {
    String text;

    try {
      text = await TesseractOcr.extractText(imageFile.path, language: "por");
    } on Exception {
      text = 'Falha ao extrair texto!';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      textExtracted = text;
      textLoaded = true;
    });
  }

  Widget _imageView() {
    if (imageFile == null) {
      return Text(
        "Nenhuma Imagem Selecionada",
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Raleway',
          fontSize: 22.0,
        ),
      );
    } else {
      return Image.file(imageFile, height: 300, fit: BoxFit.fill);
    }
  }

  Widget _textView() {
    if (textLoaded) {
      return Card(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Texto Extraído",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Raleway',
                fontSize: 25.0,
              ),
            ),
            Text(
              textExtracted,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Raleway',
                fontSize: 20.0,
              ),
            )
          ]));
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      child: FlatButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        onPressed: () {
                          _showActionSheet(context);
                        },
                        color: Colors.blue,
                        child: Text(
                          "Selecionar Imagem",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Raleway',
                            fontSize: 22.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          onPressed: buttonDisbled(),
                          color: Colors.blue,
                          child: Text(
                            "Extrair Texto",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontSize: 22.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: _imageView(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: _textView(),
                    ),
                  ],
                )
              ),
            )
        )
    );
  }
}
