import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class SmsAuthenticationScreen extends StatefulWidget {
  @override
  _SmsAuthenticationScreenState createState() => _SmsAuthenticationScreenState();
}

class _SmsAuthenticationScreenState extends State<SmsAuthenticationScreen> {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  BuildContext _context;
  PhoneNumber _internationalPhoneNumberInput = PhoneNumber(isoCode: 'BR');
  String _fullNumber = '';
  final TextEditingController _internationalPhoneNumberInputController = new MaskedTextController(mask: '(00) 00000-0000');


  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _initialization,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (value) => _fullNumber = value.toString(),
                          ignoreBlank: false,
                          autoValidate: false,
                          selectorTextStyle: TextStyle(color: Colors.black),
                          textFieldController: _internationalPhoneNumberInputController,
                          inputBorder: OutlineInputBorder(),
                          initialValue: _internationalPhoneNumberInput,
                        ),
                      ),
                      CupertinoButton.filled(child: Text('Enviar código'), onPressed: () => _sendCodeHandler())
                    ],
                  ),
                ),
              );
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<void> _sendCodeHandler() async {
    print(_fullNumber);
    return false;

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

  Future<void> _smsVerificationFailedHandler(FirebaseAuthException e) {

  }

  Future<void> _showErrorMessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Desculpe, encontramos um erro.'),
        content: Text(errorMessage),
        actions: [
          CupertinoDialogAction(
            child: Text('Ok'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      )
    );
  }

  @override
  void dispose() {
    _internationalPhoneNumberInputController?.dispose();
    super.dispose();
  }
}