import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QRCodeDialog extends StatefulWidget {
  final String url;
  final String title;

  const QRCodeDialog({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  State<QRCodeDialog> createState() => _QRCodeDialogState();
}

class _QRCodeDialogState extends State<QRCodeDialog> {
  final GlobalKey qrKey = GlobalKey();
  bool isLoading = false;

  Future<void> _shareQRCode() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Find the QR code image widget using the global key
      final boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Convert the widget to an image
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      // Save the image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Share the image file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QR Code for ${widget.title}\n${widget.url}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing QR code: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            RepaintBoundary(
              key: qrKey,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: QrImageView(
                  data: widget.url,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _shareQRCode,
                  icon: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.share),
                  label: Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
