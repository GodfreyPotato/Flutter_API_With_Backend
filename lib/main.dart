// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart';

// void main() {
//   runApp(MaterialApp(home: API()));
// }

// class API extends StatefulWidget {
//   API({super.key});

//   @override
//   State<API> createState() => _APIState();
// }

// class _APIState extends State<API> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   final api = 'http://192.168.100.21:3500/api/students';
//   Future<dynamic> loadNames() async {
//     var response = await get(Uri.parse(api));

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: loadNames(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }

//         List names = snapshot.data as List;

//         return Scaffold(
//           appBar: AppBar(
//             title: Text("People Names"),
//             actions: [
//               IconButton(
//                 onPressed: () async {
//                   var response = await post(
//                     Uri.parse(api),
//                     body: {
//                       "first_name": "Godfrey",
//                       "last_name": "Javier",
//                       "age": "22",
//                     },
//                   );
//                   if (response.statusCode != 201) {
//                     return;
//                   }
//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text(response.body)));
//                   setState(() {});
//                 },
//                 icon: Icon(Icons.add),
//               ),
//               IconButton(onPressed: () {}, icon: Icon(Icons.save)),
//             ],
//           ),
//           body: ListView.builder(
//             itemCount: names.length,
//             itemBuilder: (BuildContext context, int index) {
//               return Dismissible(
//                 key: UniqueKey(),
//                 onDismissed: (direction) async {
//                   var response = await delete(
//                     Uri.parse("$api/${names[index]['id']}"),
//                   );

//                   if (response.statusCode != 200) {
//                     return;
//                   }
//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text(response.body)));
//                   setState(() {});
//                 },
//                 child: ListTile(
//                   onTap: () async {
//                     var response = await put(
//                       Uri.parse("$api/${names[index]['id']}"),
//                       body: {
//                         "first_name": "Updated f",
//                         "last_name": "Updated l",
//                         "age": "22",
//                       },
//                     );
//                     if (response.statusCode != 200) {
//                       return;
//                     }
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text(response.body)));
//                     setState(() {});
//                   },
//                   title: Text(names[index]["first_name"]),
//                   leading: Text(names[index]["last_name"]),
//                   trailing: Text(names[index]["age"].toString()),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MaterialApp(home: API()));
}

class API extends StatefulWidget {
  const API({super.key});

  @override
  State<API> createState() => _APIState();
}

class _APIState extends State<API> {
  final api_url = "http://192.168.100.21:3500/api/students";
  var firstNameCtrl = TextEditingController();
  var lastNameCtrl = TextEditingController();
  var ageCtrl = TextEditingController();

  Future<List> getAllStudent() async {
    Response res = await get(Uri.parse(api_url));
    return jsonDecode(res.body) as List;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Crud"),
        actions: [
          IconButton(
            onPressed: () {
              firstNameCtrl.clear();
              lastNameCtrl.clear();
              ageCtrl.clear();
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text("Edit User"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20,
                        children: [
                          TextField(
                            controller: firstNameCtrl,
                            decoration: InputDecoration(
                              labelText: "First Name",
                            ),
                          ),
                          TextField(
                            controller: lastNameCtrl,
                            decoration: InputDecoration(labelText: "Last Name"),
                          ),
                          TextField(
                            controller: ageCtrl,
                            decoration: InputDecoration(labelText: "Age"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await post(
                                Uri.parse(api_url),
                                body: {
                                  "first_name": firstNameCtrl.text,
                                  "last_name": lastNameCtrl.text,
                                  "age": ageCtrl.text,
                                },
                              );

                              Navigator.of(context).pop();
                              setState(() {});
                            },
                            child: Text("Update"),
                          ),
                        ],
                      ),
                    ),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getAllStudent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (BuildContext context, int index) {
              Map student = students[index];
              return Dismissible(
                key: UniqueKey(),
                onDismissed: (d) async {
                  await delete(Uri.parse("${api_url}/${student['id']}"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Deleted Successfully!")),
                  );
                  setState(() {});
                },
                child: ListTile(
                  onTap: () {
                    firstNameCtrl.text = student['first_name'];

                    lastNameCtrl.text = student['last_name'];

                    ageCtrl.text = student['age'].toString();
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text("Edit User"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 20,
                              children: [
                                TextField(
                                  controller: firstNameCtrl,
                                  decoration: InputDecoration(
                                    labelText: "First Name",
                                  ),
                                ),
                                TextField(
                                  controller: lastNameCtrl,
                                  decoration: InputDecoration(
                                    labelText: "Last Name",
                                  ),
                                ),
                                TextField(
                                  controller: ageCtrl,
                                  decoration: InputDecoration(labelText: "Age"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await put(
                                      Uri.parse("$api_url/${student['id']}"),
                                      body: {
                                        "first_name": firstNameCtrl.text,
                                        "last_name": lastNameCtrl.text,
                                        "age": ageCtrl.text,
                                      },
                                    );

                                    Navigator.of(context).pop();
                                    setState(() {});
                                  },
                                  child: Text("Update"),
                                ),
                              ],
                            ),
                          ),
                    );
                  },
                  title: Text(
                    "${student['first_name']} ${student['last_name']}",
                  ),
                  trailing: Text("${student['age']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
