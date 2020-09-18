import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmsAuthenticationScreen extends StatefulWidget {
  @override
  _SmsAuthenticationScreenState createState() => _SmsAuthenticationScreenState();
}

class _SmsAuthenticationScreenState extends State<SmsAuthenticationScreen> {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _initialization,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: CupertinoButton.filled(child: Text('Enviar código'), onPressed: _sendCode),
              );
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    print("Enviando código");
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+5531993473620',
      verificationCompleted: (PhoneAuthCredential credential) {
        print("Verificacao completa");
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verificação falha");
        print(e);
      },
      codeSent: (String verificationId, int resendToken) {
        print("Código enviado");
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}