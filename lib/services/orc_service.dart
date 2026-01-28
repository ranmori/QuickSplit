import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<List<Map<String, dynamic>>> scanReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    
    List<Map<String, dynamic>> foundItems = [];

    // Keywords to exclude from the bill items
    final ignoreKeywords = ["TOTAL", "SUBTOTAL", "TAX", "INVOICE", "DATE", "QTY", "PRICE", "AMOUNT", "DUE", "BALANCE"];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String text = line.text.trim();
        
        // Matches prices like 100.00, 1,250.50, or 5.00
        final RegExp priceRegex = RegExp(r'(\d+[.,]\d{2})');
        final Iterable<RegExpMatch> matches = priceRegex.allMatches(text);

        if (matches.isNotEmpty) {
          // On an invoice, the final 'Amount' is the LAST match on the line
          final lastMatch = matches.last;
          String price = lastMatch.group(0)!;
          
          // Everything to the left of the final price is our potential Item Name
          String name = text.substring(0, lastMatch.start).trim();
          
          // CLEANING: Remove leading Quantity (e.g., if line is "1 Brake Cable 100.00")
          name = name.replaceFirst(RegExp(r'^\d+(\.\d+)?\s+'), '');

          // VALIDATION: Ensure it's not a header/tax line and name isn't empty noise
          bool isNoise = ignoreKeywords.any((key) => name.toUpperCase().contains(key));
          
          if (name.length > 2 && !isNoise) {
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