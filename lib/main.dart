import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MaterialApp(home: API()));
}

class API extends StatefulWidget {
  API({super.key});

  @override
  State<API> createState() => _APIState();
}

class _APIState extends State<API> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final api = 'http://192.168.100.21:3500/api/students';
  Future<dynamic> loadNames() async {
    var response = await get(Uri.parse(api));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadNames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List names = snapshot.data as List;

        return Scaffold(
          appBar: AppBar(
            title: Text("People Names"),
            actions: [
              IconButton(
                onPressed: () async {
                  var response = await post(
                    Uri.parse(api),
                    body: {
                      "first_name": "Godfrey",
                      "last_name": "Javier",
                      "age": "22",
                    },
                  );
                  if (response.statusCode != 201) {
                    return;
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(response.body)));
                  setState(() {});
                },
                icon: Icon(Icons.add),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.save)),
            ],
          ),
          body: ListView.builder(
            itemCount: names.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) async {
                  var response = await delete(
                    Uri.parse("$api/${names[index]['id']}"),
                  );

                  if (response.statusCode != 200) {
                    return;
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(response.body)));
                  setState(() {});
                },
                child: ListTile(
                  onTap: () async {
                    var response = await put(
                      Uri.parse("$api/${names[index]['id']}"),
                      body: {
                        "first_name": "Updated f",
                        "last_name": "Updated l",
                        "age": "22",
                      },
                    );
                    if (response.statusCode != 200) {
                      return;
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(response.body)));
                    setState(() {});
                  },
                  title: Text(names[index]["first_name"]),
                  leading: Text(names[index]["last_name"]),
                  trailing: Text(names[index]["age"].toString()),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
