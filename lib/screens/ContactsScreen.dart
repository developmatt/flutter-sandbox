import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {

  PermissionStatus _permissionStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _permissionStatus == PermissionStatus.granted
          ? FutureBuilder(
              future: _getContacts(),
              builder: (BuildContext context, AsyncSnapshot<List<Contact>> contacts) {
                switch(contacts.connectionState) {
                  case ConnectionState.done:
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: contacts.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: Text(contacts.data[index].displayName ?? 'Nome não encontrado'),
                        );
                      }
                    );

                  default:
                    return CircularProgressIndicator();
                }
              },
          )
          : CupertinoButton.filled(
            onPressed: () => _requestPermission(context),
            child: Container(child: Text('See Contacts')),
          ),
      )
    );
  }

  Future<void> _requestPermission(context) async {
    await [Permission.contacts].request();
    _permissionStatus = await _getPermission();
    setState(() {
      _permissionStatus = _permissionStatus;
    });
    if (_permissionStatus != PermissionStatus.granted) {
      //We can now access our contacts here
      showPermissionsErrorAlert(context);
    }
  }

  //Check contacts permission
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted && permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus = await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }

  void showPermissionsErrorAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text('Permissions error'),
          content: Text('Please enable contacts access permission in system settings'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
      ));
  }

  Future<List<Contact>> _getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    return contacts.toList();
  }
}