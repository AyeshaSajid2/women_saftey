import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyContactsScreen extends StatefulWidget {
  const MyContactsScreen({Key? key}) : super(key: key);

  @override
  _MyContactsScreenState createState() => _MyContactsScreenState();
}

class _MyContactsScreenState extends State<MyContactsScreen> {
  late List<String> contacts;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      contacts = prefs.getStringList("numbers") ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFCFE),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "SOS Contacts",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Image.asset("assets/phone_red.png"),
          onPressed: () {},
        ),
      ),
      body: contacts.isEmpty
          ? Center(child: Text("No Contacts found!"))
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(contacts[index]),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirm"),
                    content: Text(
                        "Are you sure you want to delete ${contacts[index].split("***")[0]}?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("CANCEL"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text("DELETE"),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              setState(() {
                Fluttertoast.showToast(
                  msg: "${contacts[index].split("***")[0]} removed!",
                );
                contacts.removeAt(index);
                updateNewContactList(contacts);
              });
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                backgroundImage: AssetImage("assets/user.png"),
              ),
              title: Text(contacts[index].split("***")[0] ?? "No Name"),
              subtitle:
              Text(contacts[index].split("***")[1] ?? "No Contact"),
            ),
          );
        },
      ),
    );
  }

  Future<void> updateNewContactList(List<String> contacts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("numbers", contacts);
  }
}
