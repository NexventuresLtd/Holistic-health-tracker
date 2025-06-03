// ignore: file_names
import 'package:flutter/material.dart';
import 'package:client/globals.dart';

class Splash1curve extends StatefulWidget {
  const Splash1curve({super.key});

  @override
  State<Splash1curve> createState() => _Splash1curveState();
}

class _Splash1curveState extends State<Splash1curve> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Background curved container
              Positioned(
                width: 700,
                height: 550,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(
                    color: primaryGreen, // Teal green color
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(800),
                      bottomRight: Radius.circular(800),
                    ),
                  ),
                ),
              ),
              // Centered image
              Image.asset(
                'assets/images/main.png',
                height: 200, // Adjust the height as needed
              ),
            ],
          ),

          const SizedBox(height: 200),
          // Fade-in animation
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 5),
            builder: (_, double opacity, __) {
              return Opacity(
                opacity: opacity,
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'HOLISTIC',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          ' TRACKER',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: secondaryGreen,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 100),
                    Text(
                      'FAMILY CAREGIVERS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 50),
          //loading indicator
          const Center(
            child: CircularProgressIndicator(
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
