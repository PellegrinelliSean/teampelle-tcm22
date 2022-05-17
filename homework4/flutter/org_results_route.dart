import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './globals.dart';
import 'main.dart';

Future<List<Map<String, dynamic>>> fetchResults(
    String raceid, String orgid) async {
  final response =
      await http.get(Uri.parse('$apiUrl/org_results?id=$raceid&org=$orgid'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON
    return List<Map<String, dynamic>>.from(
        jsonDecode(response.body)["Results"]);
  } else {
    // If the server did not return a 200 OK response,
    // then return an empty list
    return List.empty();
  }
}

class OrgResultsRoute extends StatefulWidget {
  final String raceid;
  final String orgid;
  final String orgname;
  const OrgResultsRoute(this.raceid, this.orgid, this.orgname, {Key? key})
      : super(key: key);

  @override
  _OrgResultsRouteState createState() => _OrgResultsRouteState();
}

class _OrgResultsRouteState extends State<OrgResultsRoute> {
  late Future<List<Map<String, dynamic>>> futureResults;

  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    futureResults = fetchResults(widget.raceid, widget.orgid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orgname),
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
              final results = await fetchResults(widget.raceid, widget.orgid);
              setState(() {
                futureResults = Future.value(results);
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
                              title: Text('${results[index]["Person"]}'),
                              subtitle: results[index]["Position"] != null
                                  ? Text('Class: ${results[index]["Class"]}\n'
                                      'Position: ${results[index]["Position"]}\n'
                                      'Status: ${results[index]["Status"]}\n')
                                  : Text('Class: ${results[index]["Class"]}'
                                      'Position: -\n'
                                      'Status: ${results[index]["Status"]}'),
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
                                    builder: (context) => OrgResultsRoute(
                                        widget.raceid,
                                        widget.orgid,
                                        widget.orgname)),
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
