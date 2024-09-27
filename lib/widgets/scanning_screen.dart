import 'dart:io';
import 'package:farmshield/pages/detection_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({Key? key, required this.image, required this.results})
      : super(key: key);

  final File image;
  final List results;

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToDetectionDetails();
  }

  void _navigateToDetectionDetails() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        print(widget.results);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DetectionDeteils(
              image: widget.image,
              results: widget.results,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LottieBuilder.asset('assets/json/scan.json'),
      ),
    );
  }
}
