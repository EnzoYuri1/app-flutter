import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String dolar = "";
  String euro = "";
  String real = "1.00";
  bool loading = false;
  
  pegar() async {
    loading = true;
    setState(() {});

    try {
      var resposta = await Dio().get(
        "https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL"
      );

      dolar = resposta.data["USDBRL"]["bid"];
      euro = resposta.data["EURBRL"]["bid"];

    } catch (e) {
      print(e);
    }

    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Cotação"),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              pegar();
            },
            child: Text("Buscar"),
          ),

          SizedBox(height: 20),

          loading
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    Text(
                      "Real: $real",
                      style: TextStyle(fontSize: 20),
                    ),

                    SizedBox(height: 10),
                    Text(
                      "Dólar: $dolar",
                      style: TextStyle(fontSize: 20),
                    ),
                    
                    SizedBox(height: 10),
                    Text(
                      "Euro: $euro",
                      style: TextStyle(fontSize: 20),
                    ),

                  ],
                )

        ],
      ),
    );
  }
}
