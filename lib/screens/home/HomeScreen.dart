import 'package:flutter/material.dart';
import 'package:flutterSandbox/widgets/ColoredButtonsList.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> buttonsList = [
    {
      'text': 'Conteúdo do botão 1',
      'icon': Icons.verified_user,
      'route': '/'
    },
    {
      'text': 'Conteúdo do botão 1',
      'icon': Icons.verified_user,
      'route': '/'
    },
    {
      'text': 'Conteúdo do botão 1',
      'icon': Icons.verified_user,
      'route': '/'
    },
    {
      'text': 'Conteúdo do botão 1',
      'icon': Icons.verified_user,
      'route': '/'
    },
    {
      'text': 'Conteúdo do botão 1',
      'icon': Icons.verified_user,
      'route': '/'
    },
    {
      'text': 'Conteúdo do botão 1',
      'icon': Icons.verified_user,
      'route': '/'
    },
    {
      'text': 'Conteúdo do botão 1',
      'icon': Icons.verified_user,
      'route': '/'
    },
    {
      'text': 'Conteúdo do botão 1',
      'icon': Icons.verified_user,
      'route': '/'
    },
    {
      'text': 'Conteúdo do botão 1',
      'icon': Icons.verified_user,
      'route': '/'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: ColoredButtonsList(buttonsList),
    );
  }
}