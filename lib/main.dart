import 'package:flutter/material.dart';
import 'package:palette_extractor/k_means.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var colorList1 = [];
  var colorList2 = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Palette Extractor"),
        actions: [
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: () async {
              var kmeans = KMeansRunner();
              var image1 = await kmeans.run('assets/test.jpg');
              var image2 = await kmeans.run('assets/test2.jpg');

              setState(() {
                colorList1 = image1;
                colorList2 = image2;
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/test.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              Wrap(
                children: [
                  ...colorList1.map(
                    (color) => Container(
                      height: MediaQuery.of(context).size.width / 5,
                      width: MediaQuery.of(context).size.width / 5,
                      color: color,
                      alignment: Alignment.center,
                      child: Text(
                        color.toString(),
                        style: TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                ],
              ),
              Image.asset('assets/test2.jpg'),
              Wrap(
                children: [
                  ...colorList2.map(
                    (color) => Container(
                      height: MediaQuery.of(context).size.width / 5,
                      width: MediaQuery.of(context).size.width / 5,
                      color: color,
                      alignment: Alignment.center,
                      child: Text(
                        color.toString(),
                        style: TextStyle(fontSize: 8, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
