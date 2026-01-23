import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  // Initialize the OCR engine
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<Map<String, dynamic>>> scanReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    
    List<Map<String, dynamic>> foundItems = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String text = line.text;
        
        // This regex looks for prices like 10.99 or 5.00
        final RegExp priceRegex = RegExp(r'(\d+[.,]\d{2})');
        final match = priceRegex.firstMatch(text);

        if (match != null) {
          String price = match.group(0)!;
          // The name is usually everything before the price on that line
          String name = text.replaceFirst(price, '').trim();
          
          if (name.length > 2) { // Filter out random noise
            foundItems.add({
              'name': name,
              'price': price.replaceAll(',', '.'), 
            });
          }
        }
      }
    }
    return foundItems;
  }

  void dispose() {
    _textRecognizer.close();
  }
}