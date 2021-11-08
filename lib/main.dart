import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Picker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ImagePickerApp(title: 'Image Picker'),
    );
  }
}

class ImagePickerApp extends StatefulWidget {
  ImagePickerApp({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ImagePickerAppState createState() => _ImagePickerAppState();
}

class _ImagePickerAppState extends State<ImagePickerApp> {
  PickedFile _imageFile;
  bool imagePicked = false;
 
  final String postUrl = 'https://codelime.in/api/remind-app-token';
  final ImagePicker _picker = ImagePicker();

  Future<String> uploadImage(filepath, url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('image', filepath));
    var res = await request.send();
    print("Image Uploaded");
    setState(() {
      imagePicked= false;
    });
    showDialog(
      context: context,
      builder: (_) {
        return  AlertDialog(
          title: Text("Success!"),
          content: Text("Image is uploaded."),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () { 
                Navigator.pop(context, false);
              },
            )
          ],
        );
      },
    );
    return res.reasonPhrase;
  }

  Future<void> retriveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      print('Retrieve error ' + response.exception.code);
    }
  }

  Widget showImage() {
    if (_imageFile != null && imagePicked) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.file(File(_imageFile.path)),
            SizedBox(
              height: 100,
            ),
            RaisedButton(
              onPressed: () async {
                var res = await uploadImage(_imageFile.path, postUrl);
                print(res);
              },
              child: const Text('Upload Image'),
            )
          ],
        ),
      ) 
      );
    }
     else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  void pickImage() async {
    try {
      final pickedFile = await _picker.getImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile;
        imagePicked = true;
      });
    } catch (e) {
      print("Image picker error " + e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: FutureBuilder<void>(
        future: retriveLostData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Text('Picked an image');
            case ConnectionState.done:
              return showImage();
            default:
              return const Text('Picked an image');
          }
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: 'Pick Image from gallery',
        child: Icon(Icons.photo_library),
      ),
    );
  }
}
