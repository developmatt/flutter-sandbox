import 'package:flutter/material.dart';
import 'package:flutterSandbox/widgets/ColoredButtonsList.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> buttonsList = [{
        'text': 'Listando os contatos',
        'icon': Icons.account_circle,
        'onTap': () => Navigator.of(context).pushNamed('contacts')
    }];

    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: ColoredButtonsList(buttonsList.map((buttonItem) => ColoredButtonsListButton(
        onTap: buttonItem['onTap'],
        icon: Icons.account_circle,
        text: buttonItem['text'],
      )).toList()),
    );
  }
}