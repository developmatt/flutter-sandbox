import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:pin_code_fields/pin_code_fields.dart';


class SmsAuthenticationScreen extends StatefulWidget {
  @override
  _SmsAuthenticationScreenState createState() => _SmsAuthenticationScreenState();
}

class _SmsAuthenticationScreenState extends State<SmsAuthenticationScreen> {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  PhoneNumber _internationalPhoneNumberInput = PhoneNumber(isoCode: 'BR');
  final TextEditingController _internationalPhoneNumberInputController = TextEditingController();
  final TextEditingController _smsCodeInputController = new TextEditingController();
  String _fullNumber = '';
  bool _smsCodeSent = false;
  bool _confirmSmsCodeButtonActive = false;

  String _verificationId;
  int _resendToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: !_smsCodeSent
        ? _getSendSmsScreen()
        : _getInsertSmsCodeScreen(context),
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
                      maxLength: 13,
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

  Widget _getInsertSmsCodeScreen(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('O código foi enviado para o número:'),
            Text(
              _fullNumber,
              style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              height: 2,
            )),
            Container(
              margin: EdgeInsets.only(top: 50.0, bottom: 20.0),
              child: PinCodeTextField(
                controller: _smsCodeInputController,
                keyboardType: TextInputType.number,
                appContext: context,
                length: 6,
                onChanged: (value) => setState(() {
                  _confirmSmsCodeButtonActive = value.length > 5;
                }),
                backgroundColor: Colors.transparent,
                pinTheme: PinTheme(
                  inactiveColor: Color(0x330088FF),
                  activeColor: Color(0xFF0088FF)
                ),
              ),
            ),
            CupertinoButton.filled(
              disabledColor: Color(0x330088FF),
              child: Text('Confirmar código'),
              onPressed: _confirmSmsCodeButtonActive
              ? _confirmCodeButtonHandler:
              null,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _sendCodeToNumber() async {
    if(!_isPhoneNumberValid()) {
      return _showErrorMessage('O número de telefone é inválido', 'Verifique os dados');
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _fullNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        UserCredential _credential;
        try {
          _credential = await FirebaseAuth.instance.signInWithCredential(credential);
          print(">>>>>>>>>>>> Login executado com sucesso");
          print(_credential);
        } catch(e) {
          print(e.toString());
          _showErrorMessage('Não foi possível autenticar automaticamente. Digite o código de 6 dígitos enviado via SMS para o número informado');
        }
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
        _smsCodeSentHandler(verificationId, resendToken);
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

  bool _isPhoneNumberValid() {
    final pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    final regExp = RegExp(pattern);

    return (_fullNumber != null && !_fullNumber.isEmpty && _fullNumber.length > 13 && regExp.hasMatch(_fullNumber));
  }

  void _smsCodeSentHandler(String verificationId, int resendToken) {
    _verificationId = verificationId;
    _resendToken = resendToken;
  }

  void _confirmCodeButtonHandler() async {
    print(_verificationId);
    print(_resendToken);

    // Update the UI - wait for the user to enter the SMS code
    String smsCode = _smsCodeInputController.text;

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: smsCode);

    UserCredential credential;

    try {
      // Sign the user in (or link) with the credential
      credential = await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      print(credential);
    } catch(e) {
      print("Erro ao tentar fazer login");
      print(e.toString());
      _showErrorMessage('Código inválido ou expirado', 'Erro ao autenticar');
    }
  }

  @override
  void dispose() {
    _internationalPhoneNumberInputController?.dispose();
    super.dispose();
  }
}