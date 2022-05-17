import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './globals.dart';
import './results_route.dart';
import 'main.dart';

Future<List<Map<String, dynamic>>> fetchClasses(String raceid) async {
  final response = await http.get(Uri.parse('$apiUrl/list_classes?id=$raceid'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return List<Map<String, dynamic>>.from(
        jsonDecode(response.body)["race_classes"]);
  } else {
    // If the server did not return a 200 OK response,
    // then return an empty list
    return List.empty();
  }
}

class ClassesRoute extends StatefulWidget {
  final String raceid;
  final String racename;
  const ClassesRoute(this.raceid, this.racename, {Key? key}) : super(key: key);

  @override
  _ClassesRouteState createState() => _ClassesRouteState();
}

class _ClassesRouteState extends State<ClassesRoute> {
  late Future<List<Map<String, dynamic>>> futureClasses;

  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    futureClasses = fetchClasses(widget.raceid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.racename),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: SafeArea(
          top: true,
          bottom: true,
          left: true,
          right: true,
          minimum: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 5.0, bottom: 70.0),
          maintainBottomViewPadding: true,
          child: RefreshIndicator(
            key: refreshKey,
            color: Colors.amber,
            onRefresh: () async {
              final results = await fetchClasses(widget.raceid);
              setState(() {
                futureClasses = Future.value(results);
              });
            },
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureClasses,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> classes = snapshot.data!;
                  if (classes.isNotEmpty) {
                    return ListView.builder(
                        itemCount: classes.length,
                        itemBuilder: ((context, index) => ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ResultsRoute(
                                        widget.raceid.toString(),
                                        classes[index]["id"].toString(),
                                        classes[index]["name"].toString()),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.amber[800],
                                  textStyle:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              child: Text(classes[index]["name"]),
                            )));
                  } else {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                                fontSize: 30,
                              ),
                              "Something went wrong"),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ClassesRoute(
                                        widget.raceid, widget.racename)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.amber[800],
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            child: const Text("RELOAD"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyApp(),
                                  ));
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.amber[800],
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            child: const Text("HOME"),
                          ),
                        ]);
                  }
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber));
              },
            ),
          ),
        ),
      ),
      bottomSheet: Container(
          width: double.infinity,
          color: Colors.amber,
          child: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
              text: '\nTeamPelle - ',
              children: <TextSpan>[
                TextSpan(
                  text: 'Nico e Sean Pellegrinelli\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
