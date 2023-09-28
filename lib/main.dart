import 'dart:io';

import 'package:contact_book_using_sqflite/AddContact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ShowContact(),
  ));
}

class ShowContact extends StatefulWidget {
  const ShowContact({super.key});

  static Database? database;
  static var dbName = 'Contect Book.db';
  static var dbVersion = 1;
  static var dbTableName = 'Contects';

  @override
  State<ShowContact> createState() => _ShowContactState();
}

class _ShowContactState extends State<ShowContact> {
  List<dynamic> DataList = [];
  List<dynamic> foundUser = [];

  Future getDataBase() async {
    if (ShowContact.database != null) {
      return ShowContact.database;
    } else {
      var dbpath = await getDatabasesPath();
      String path = join(dbpath, ShowContact.dbName);
      ShowContact.database = await openDatabase(path,
          version: ShowContact.dbVersion, onCreate: (Database db, int version) {
        db.execute(
            '''CREATE TABLE ${ShowContact.dbTableName}(id INTEGER PRIMARY KEY AUTOINCREMENT , name TEXT NOT NULL,contact TEXT NOT NULL,gender TEXT , image TEXT)''');
      });
    }
  }

  getData() async {
    var getDataQuary =
        '''SELECT * FROM ${ShowContact.dbTableName} ORDER BY name ASC ''';
    DataList = await ShowContact.database!.rawQuery(getDataQuary);
    foundUser = DataList;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataBase().then((value) {
      getData();
    });
  }

  filter_user(String keyword) {
    List<dynamic> result = [];
    if (keyword.isEmpty) {
      result = foundUser;
    } else {
      result = foundUser
          .where((user) => user['name']
              .toString()
              .toLowerCase()
              .contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      DataList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Card(
            color: Colors.white54,
            shape: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height * 0.05)),
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.067,
              decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * 0.05)),
              child: TextField(
                  onChanged: (value) => filter_user(value),
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.search,
                          color: Colors.black87,
                          size: 30,
                        ),
                      ),
                      hintText: "Search Contects",
                      hintStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.height * 0.05)))),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: DataList.length,
            itemBuilder: (context, index) {
              return Slidable(
                  startActionPane:
                      ActionPane(motion: DrawerMotion(), children: [
                    SlidableAction(
                      onPressed: (context) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                          builder: (context) {
                            return AddContact(DataList[index]);
                          },
                        ), (route) => true);
                      },
                      backgroundColor: Colors.green,
                      icon: Icons.edit,
                    ),
                  ]),
                  endActionPane: ActionPane(motion: DrawerMotion(), children: [
                    SlidableAction(
                      onPressed: (context) async {
                        var DeleteQuary =
                            """DELETE FROM ${ShowContact.dbTableName} WHERE id=${DataList[index]['id']};""";
                        await ShowContact.database!
                            .rawDelete(DeleteQuary)
                            .then((value) => getData());
                      },
                      icon: Icons.delete,
                      backgroundColor: Colors.red,
                    )
                  ]),
                  child: ListTile(
                    leading: (DataList[index]['image'] != "")
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: FileImage(
                                          File(DataList[index]['image'])))),
                            ),
                          )
                        : Icon(Icons.account_circle, size: 60),
                    title: Text(
                      "${DataList[index]['name']}",
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text("+91 ${DataList[index]['contact']}"),
                  ));
            },
          ))
        ],
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        isExtended: true,
        elevation: 10,
        onPressed: () {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) {
              return AddContact();
            },
          ), (route) => true);
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }
}
