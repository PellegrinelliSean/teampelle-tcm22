import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './globals.dart';
import './classes_route.dart';

Future<List<Map<String, dynamic>>> fetchRaces() async {
  final response = await http.get(Uri.parse('$apiUrl/list_races'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return List<Map<String, dynamic>>.from(jsonDecode(response.body)["races"]);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load classes');
  }
}

void main() {
  runApp(const MaterialApp(
    title: 'Ori Live Results',
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Map<String, dynamic>>> futureRaces;

  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    futureRaces = fetchRaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available races'),
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
              final results = await fetchRaces();
              setState(() {
                futureRaces = Future.value(results);
              });
            },
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureRaces,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var races = snapshot.data!;
                  return ListView.builder(
                    itemCount: races.length,
                    itemBuilder: ((context, index) => ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassesRoute(
                                    races[index]["race_id"].toString(),
                                    races[index]["race_name"]),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.amber[800],
                              textStyle:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          child: Text(
                              "${races[index]["race_name"]} - ${races[index]["race_date"]}"),
                        )),
                  );
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
