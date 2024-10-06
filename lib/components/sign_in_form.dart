// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:rive/rive.dart' as rive; // Alias added for the Rive package
import 'package:zenify/utils/database.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({
    super.key,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  ZenifyDatabase db = ZenifyDatabase();

  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  bool isShowLoading = false;
  bool isShowConfetti = false;
  late rive.SMITrigger error;
  late rive.SMITrigger success;
  late rive.SMITrigger reset;
  late rive.SMITrigger confetti;

  void _onCheckRiveInit(rive.Artboard artboard) {
    rive.StateMachineController? controller =
        rive.StateMachineController.fromArtboard(artboard, 'State Machine 1');

    artboard.addController(controller!);
    error = controller.findInput<bool>('Error') as rive.SMITrigger;
    success = controller.findInput<bool>('Check') as rive.SMITrigger;
    reset = controller.findInput<bool>('Reset') as rive.SMITrigger;
  }

  void _onConfettiRiveInit(rive.Artboard artboard) {
    rive.StateMachineController? controller =
        rive.StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);

    confetti =
        controller.findInput<bool>("Trigger explosion") as rive.SMITrigger;
  }

  void signIn(BuildContext context) {
    setState(() {
      isShowConfetti = true;
      isShowLoading = true;
    });
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (_signInFormKey.currentState!.validate()) {
          success.fire();
          Future.delayed(
            const Duration(seconds: 2),
            () {
              setState(() {
                isShowLoading = false;
              });
              confetti.fire();
              // Navigate & hide confetti
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pushNamed(context, "/home");
              });
            },
          );
        } else {
          error.fire();
          Future.delayed(
            const Duration(seconds: 2),
            () {
              setState(() {
                isShowLoading = false;
              });
              reset.fire();
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _signInFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Name",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  enabled: !isShowLoading,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {
                    db.userDetails['name'] = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 16,
                        child: Image.asset("assets/icons/user.png"),
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                "Password",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: TextFormField(
                  enabled: !isShowLoading,
                  obscureText: true,
                  onChanged: (value) {
                    db.userDetails['password'] = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 16,
                        child: Image.asset("assets/icons/security.png"),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    signIn(context);
                    if (!_signInFormKey.currentState!.validate()) {
                      return;
                    }
                    db.saveUserDetails();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor("#6721ff"),
                    minimumSize: const Size(double.infinity, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                  ),
                  icon: Icon(
                    CupertinoIcons.arrow_right,
                    color: HexColor("#f79729"),
                  ),
                  label: const Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        isShowLoading
            ? SizedBox(
                width: double.infinity,
                height: 200,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: const SizedBox(),
                      ),
                    ),
                    CustomPositioned(
                      child: rive.RiveAnimation.asset(
                        'assets/RiveAssets/check.riv',
                        onInit: _onCheckRiveInit,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
        isShowConfetti
            ? CustomPositioned(
                scale: 6,
                child: rive.RiveAnimation.asset(
                  "assets/RiveAssets/confetti.riv",
                  onInit: _onConfettiRiveInit,
                  fit: BoxFit.cover,
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({super.key, this.scale = 1, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: 100,
            width: 100,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
