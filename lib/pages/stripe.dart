import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nes/emulator/rom.dart';

class StripePageWidget extends StatefulWidget {
  @override
  _StripePageState createState() => _StripePageState();
}

class _StripePageState extends State<StripePageWidget> {
  Widget build(BuildContext context) {
    Uint8List romBytes = ModalRoute.of(context).settings.arguments;
    var rom = Rom(romBytes);

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: GridView.builder(
            itemCount: _getSpriteCount(rom),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 32),
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: _convertSpritePixelsToImage(getSpriteImage(rom, index)),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RawImage(image: snapshot.data);
                  } else {
                    return Text("Could not create a mage");
                  }  
                },
              );
            }, 
          )
        )
      ),
    );
  }
}

int _getSpriteCount(Rom rom) {
  return (rom.chrRom.length / 0x10).round();
}

Uint8List getSpriteImage(Rom rom, int number) {
  final spriteByte = rom.chrRom.sublist(0x10 * number, 0x10 * (number + 1));

  final data = new Uint8List(8 * 8);
  for (int i = 0; i < 8; i++) {
    final byte1 = spriteByte[i]; 
    final byte2 = spriteByte[i + 8];
    for (int j = 0; j < 8; j++) {
      data[i * 8 + j] = ((byte1 >> (8 - j)) & 1) + ((byte2 >> (8 - j)) & 1) * 2;
    }
  }

  // Create RGBA pixesl array
  var pixels = new Uint8List(8 * 8 * 4);
  for (int i = 0; i < 64; i++) {
    final flag = data[i];
    switch(flag) {
      case 0:
        pixels[4 * i] = 0;
        pixels[4 * i + 1] = 0;
        pixels[4 * i + 2] = 0;
        pixels[4 * i + 3] = 255;
        break;
      case 1:
        pixels[4 * i] = 85;
        pixels[4 * i + 1] = 85;
        pixels[4 * i + 2] = 85;
        pixels[4 * i + 3] = 255;
        break;
      case 2:
        pixels[4 * i] = 170;
        pixels[4 * i + 1] = 170;
        pixels[4 * i + 2] = 170;
        pixels[4 * i + 3] = 255;
        break;
      case 3:
        pixels[4 * i] = 255;
        pixels[4 * i + 1] = 255;
        pixels[4 * i + 2] = 255;
        pixels[4 * i + 3] = 255;
        break;
    }
  }

  return pixels;
}

Future<ui.Image> _convertSpritePixelsToImage(Uint8List pixels) {
  final c = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    8,
    8,
    ui.PixelFormat.rgba8888,
    c.complete,
  );
  return c.future;
}
