import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './globals.dart';
import 'main.dart';
import 'org_results_route.dart';

Future<List<Map<String, dynamic>>> fetchResults(
    String raceid, String classid) async {
  final response =
      await http.get(Uri.parse('$apiUrl/results?id=$raceid&class=$classid'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return List<Map<String, dynamic>>.from(
        jsonDecode(response.body)["Results"]);
  } else {
    // If the server did not return a 200 OK response,
    // then return an empty list
    return List.empty();
  }
}

class ResultsRoute extends StatefulWidget {
  final String raceid;
  final String classid;
  final String classname;
  const ResultsRoute(this.raceid, this.classid, this.classname, {Key? key})
      : super(key: key);

  @override
  _ResultsRouteState createState() => _ResultsRouteState();
}

class _ResultsRouteState extends State<ResultsRoute> {
  late Future<List<Map<String, dynamic>>> futureResults;

  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    futureResults = fetchResults(widget.raceid, widget.classid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classname),
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
              List<Map<String, dynamic>> old_results = await futureResults;
              List<Map<String, dynamic>> new_results =
                  await fetchResults(widget.raceid, widget.classid);
              for (int i = 0; i < new_results.length; i++) {
                new_results[i]["new"] = 1;
                for (int j = 0; j < old_results.length; j++) {
                  // necessary to check if are equals
                  old_results[j]["new"] = 1;
                  if (mapEquals(old_results[j], new_results[i])) {
                    new_results[i]["new"] = 0;
                  }
                }
              }
              setState(() {
                futureResults = Future.value(new_results);
              });
            },
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureResults,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> results = snapshot.data!;
                  if (results.isNotEmpty) {
                    return ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemBuilder: ((context, index) => ListTile(
                              title: results[index]["Position"] != null
                                  ? results[index]["new"] == 1
                                      ? RichText(
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text:
                                                  '${results[index]["Position"]} - ${results[index]["Person"]} ',
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: 'NEW!',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ]),
                                        )
                                      : Text(
                                          '${results[index]["Position"]} - ${results[index]["Person"]}')
                                  : results[index]["new"] == 1
                                      ? RichText(
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text:
                                                  '- - ${results[index]["Person"]} ',
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: 'NEW!',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ]),
                                        )
                                      : Text('- - ${results[index]["Person"]}'),
                              subtitle: results[index]["Status"] !=
                                      "DidNotStart"
                                  ? RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text:
                                              "Start time: ${results[index]["Start"]}\n"
                                              "End time: ${results[index]["End"]}\n"
                                              "Time: ${results[index]["Time"]}\n"
                                              "Status: ${results[index]["Status"]}\n"
                                              "Organisation: ",
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${results[index]["Org"]}',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrgResultsRoute(
                                                    widget.raceid.toString(),
                                                    results[index]["Orgid"]
                                                        .toString(),
                                                    results[index]["Org"],
                                                  ),
                                                ),
                                              );
                                            },
                                        ),
                                        TextSpan(
                                          text:
                                              ' (${results[index]["Country"]})',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                    )
                                  : RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text:
                                              'Status: ${results[index]["Status"]}\nOrganisation: ',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${results[index]["Org"]}',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrgResultsRoute(
                                                    widget.raceid.toString(),
                                                    results[index]["Orgid"]
                                                        .toString(),
                                                    results[index]["Org"],
                                                  ),
                                                ),
                                              );
                                            },
                                        ),
                                        TextSpan(
                                          text:
                                              ' (${results[index]["Country"]})',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                    ),
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
                                    builder: (context) => ResultsRoute(
                                        widget.raceid,
                                        widget.classid,
                                        widget.classname)),
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
