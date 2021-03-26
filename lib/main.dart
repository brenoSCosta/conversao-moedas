import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=ad8eeb0e";
void main() {
  runApp(MaterialApp(
    title: "Conversor de moedas",
    theme: ThemeData(
        primarySwatch: Colors.green,
        hintColor: Colors.green,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
        )),
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;
  final moneyDolar = TextEditingController();
  final moneyReal = TextEditingController();
  final moneyEuro = TextEditingController();

  Future<Map> getData() async {
    var response = await Dio().get(request);
    return jsonDecode(response.toString());
  }

  void _clearAll() {
    moneyDolar.text = "";
    moneyReal.text = "";
    moneyEuro.text = "";
  }

  void euroOnChange(String text) async {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euroTemp = double.parse(text);
    moneyReal.text = (euroTemp * this.euro).toStringAsFixed(2);
    moneyDolar.text = (euroTemp * this.euro / dolar).toStringAsFixed(2);
  }

  void dolarOnChange(String text) async {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolarTemp = double.parse(text);
    moneyReal.text = (dolarTemp * this.dolar).toStringAsFixed(2);
    moneyEuro.text = (dolarTemp * this.dolar / euro).toStringAsFixed(2);
  }

  void realOnChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    moneyDolar.text = (real / dolar).toStringAsFixed(2);
    moneyEuro.text = (real / euro).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.greenAccent.shade100,
        appBar: AppBar(
          title: Text("Conversor de moedas"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.help), onPressed: () {})
          ],
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando dados...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar dados! :(",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 120,
                          color: Colors.green,
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 20.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        0.0, 20.0, 0.0, 20.0),
                                    child: buildTextField(moneyDolar,
                                        dolarOnChange, "Dólar", "US\$ ")),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        0.0, 20.0, 0.0, 20.0),
                                    child: buildTextField(
                                      moneyEuro,
                                      euroOnChange,
                                      "Euro",
                                      "€ ",
                                    )),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        0.0, 20.0, 0.0, 20.0),
                                    child: buildTextField(
                                      moneyReal,
                                      realOnChange,
                                      "Real",
                                      "R\$ ",
                                    )),
                              ],
                            )),
                      ],
                    ),
                  );
                }
            }
          },
        ));
  }
}

Widget buildTextField(
    TextEditingController controller, Function f, String label, String prefix) {
  return TextField(
    controller: controller,
    onChanged: (value) {
      f(value);
    },
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      prefixText: prefix,
      labelText: label,
      labelStyle: TextStyle(fontSize: 20, color: Colors.green),
    ),
  );
}
