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
  PhoneNumber _internationalPhoneNumberInput = PhoneNumber(isoCode: 'BR');
  final TextEditingController _internationalPhoneNumberInputController = new MaskedTextController(mask: '(00) 00000-0000');
  String _fullNumber = '';
  bool _smsCodeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: !_smsCodeSent
        ? _getSendSmsScreen()
        : _getInsertSmsCodeScreen(),
      ),
    );
  }

  ///Tela de envio de sms
  Widget _getSendSmsScreen() {
    return FutureBuilder(
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
                  CupertinoButton.filled(child: Text('Enviar código'), onPressed: () => _sendCodeToNumber())
                ],
              ),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget _getInsertSmsCodeScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('O código foi enviado para o número:'),
          Text(_fullNumber, style: TextStyle(
           fontSize: 18.0,
           fontWeight: FontWeight.bold,
           height: 2,
          ))
        ],
      ),
    );
  }

  Future<void> _sendCodeToNumber() async {

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _fullNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        String _errorMessage = 'Não foi possível enviar o código';
        if (e.code == 'invalid-phone-number') {
          _errorMessage = 'O número de telefone é inválido';
        }
        _showErrorMessage(_errorMessage);
      },
      codeSent: (String verificationId, int resendToken) {
        print("Código enviado");
        setState(() {
          _smsCodeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _smsVerificationFailedHandler(FirebaseAuthException e) {

  }

  Future<void> _showErrorMessage(String errorMessage, [String title]) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? 'Desculpe, encontramos um erro.'),
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