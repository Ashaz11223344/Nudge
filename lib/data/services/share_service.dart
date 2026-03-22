import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nudge/data/models/quote_model.dart';
import 'package:nudge/core/constants/colors.dart';

class ShareService {
  /// Shares the quote as plain text.
  Future<void> shareAsText(QuoteModel quote) async {
    final text = '"${quote.text}"\n\n- Nudge';
    await Share.share(text);
  }

  /// Generates a card image programmatically and shares it.
  ///
  /// This uses [ui.PictureRecorder] + [Canvas] to paint the card directly,
  /// avoiding any dependency on the widget tree or RepaintBoundary.
  Future<void> shareAsCard({
    required QuoteModel quote,
    String? userName,
    bool isDark = false,
  }) async {
    try {
      // 1. Generate the image bytes (fully deterministic, no widget tree)
      final Uint8List? imageBytes = await _generateCardImage(
        quoteText: quote.text,
        userName: userName,
        isDark: isDark,
      );

      if (imageBytes == null || imageBytes.isEmpty) {
        throw Exception('Failed to generate card image.');
      }

      // 2. Write to a temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final File file = File('${tempDir.path}/nudge_quote_$timestamp.png');
      await file.writeAsBytes(imageBytes);

      // 3. Verify the file exists before sharing
      if (!await file.exists()) {
        throw Exception('Image file was not saved correctly.');
      }

      // 4. Share via share_plus
      final XFile xFile = XFile(file.path, mimeType: 'image/png');
      await Share.shareXFiles(
        [xFile],
        text: 'Motivation from Nudge App 💡',
        subject: 'Daily Inspiration',
      );
    } catch (e) {
      debugPrint('ShareService.shareAsCard error: $e');
      rethrow;
    }
  }

  /// Paints the quote card onto a Canvas and returns PNG bytes.
  ///
  /// No widget tree, no RepaintBoundary, no late variables.
  /// Every variable is final and null-checked.
  Future<Uint8List?> _generateCardImage({
    required String quoteText,
    String? userName,
    required bool isDark,
  }) async {
    // --- Constants ---
    const double cardWidth = 1080;
    const double cardHeight = 1080;
    const double padding = 100;
    const double contentWidth = cardWidth - (padding * 2);

    // --- Colors ---
    final Color bgColor =
        isDark ? AppColors.carbonBlack : AppColors.floralWhite;
    final Color textColor = AppColors.spicyPaprika;
    final Color subtleColor = Color.fromRGBO(
      textColor.r.toInt(),
      textColor.g.toInt(),
      textColor.b.toInt(),
      0.3,
    );

    // --- Record the picture ---
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // 1. Background
    final Paint bgPaint = Paint()..color = bgColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cardWidth, cardHeight),
      bgPaint,
    );

    // 2. Opening quotation mark
    final ui.ParagraphBuilder quoteMarkBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 140,
        fontWeight: FontWeight.bold,
      ),
    );
    quoteMarkBuilder.pushStyle(ui.TextStyle(
      color: subtleColor,
      fontSize: 140,
      fontWeight: FontWeight.bold,
    ));
    quoteMarkBuilder.addText('"');
    final ui.Paragraph quoteMarkParagraph = quoteMarkBuilder.build();
    quoteMarkParagraph.layout(ui.ParagraphConstraints(width: contentWidth));
    canvas.drawParagraph(
      quoteMarkParagraph,
      Offset(padding, padding + 20),
    );

    // 3. Quote text (auto word-wrapped by Paragraph)
    final double quoteTopY = padding + 160;
    final ui.ParagraphBuilder quoteBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 52,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        height: 1.5,
        maxLines: 12,
        ellipsis: '…',
      ),
    );
    quoteBuilder.pushStyle(ui.TextStyle(
      color: textColor,
      fontSize: 52,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      height: 1.5,
    ));
    quoteBuilder.addText(quoteText);
    final ui.Paragraph quoteParagraph = quoteBuilder.build();
    quoteParagraph.layout(ui.ParagraphConstraints(width: contentWidth));

    // Center the quote text vertically in the available space
    final double quoteAreaHeight = cardHeight - quoteTopY - 260; // space for bottom section
    final double quoteTextHeight = quoteParagraph.height;
    final double quoteOffsetY = quoteTopY +
        ((quoteAreaHeight - quoteTextHeight) / 2).clamp(0.0, quoteAreaHeight);

    canvas.drawParagraph(quoteParagraph, Offset(padding, quoteOffsetY));

    // 4. Divider line
    final double dividerY = cardHeight - 200;
    final Paint dividerPaint = Paint()
      ..color = subtleColor
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(padding, dividerY),
      Offset(cardWidth - padding, dividerY),
      dividerPaint,
    );

    // 5. "NUDGE" branding (bottom-left)
    final double brandingY = dividerY + 30;
    final ui.ParagraphBuilder brandBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
    );
    brandBuilder.pushStyle(ui.TextStyle(
      color: textColor,
      fontSize: 36,
      fontWeight: FontWeight.bold,
      letterSpacing: 4.0,
    ));
    brandBuilder.addText('NUDGE');
    final ui.Paragraph brandParagraph = brandBuilder.build();
    brandParagraph.layout(ui.ParagraphConstraints(width: contentWidth));
    canvas.drawParagraph(brandParagraph, Offset(padding, brandingY));

    // 6. Username (bottom-right, if provided)
    if (userName != null && userName.isNotEmpty) {
      final ui.ParagraphBuilder userBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.right,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      );
      userBuilder.pushStyle(ui.TextStyle(
        color: Color.fromRGBO(
          textColor.r.toInt(),
          textColor.g.toInt(),
          textColor.b.toInt(),
          0.6,
        ),
        fontSize: 24,
        letterSpacing: 2.0,
      ));
      userBuilder.addText(userName.toUpperCase());
      final ui.Paragraph userParagraph = userBuilder.build();
      userParagraph.layout(ui.ParagraphConstraints(width: contentWidth));
      canvas.drawParagraph(
        userParagraph,
        Offset(padding, brandingY + 10),
      );
    }

    // --- Convert to image ---
    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(
      cardWidth.toInt(),
      cardHeight.toInt(),
    );

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      return null;
    }

    return byteData.buffer.asUint8List();
  }
}
