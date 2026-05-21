import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
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

  bool carregando = false;

  Future pegarCotacao() async {

    setState(() {
      carregando = true;
    });

    try {

      final response = await Dio().get(
        'https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL',
      );

      setState(() {

        dolar = response.data['USDBRL']['bid'];
        euro = response.data['EURBRL']['bid'];

      });

    } catch (e) {

      print("Erro: $e");

    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Cotação de Moedas"),
        backgroundColor: Colors.orange,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ElevatedButton(
              onPressed: pegarCotacao,
              child: Text("Buscar Cotação"),
            ),

            SizedBox(height: 30),

            carregando
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Real (BRL): R\$ $real",
                        style: TextStyle(fontSize: 22),
                      ),

                      SizedBox(height: 15),

                      Text(
                        "Dólar (USD): R\$ $dolar",
                        style: TextStyle(fontSize: 22),
                      ),

                      SizedBox(height: 15),

                      Text(
                        "Euro (EUR): R\$ $euro",
                        style: TextStyle(fontSize: 22),
                      ),

                    ],
                  ),

          ],
        ),
      ),
    );
  }
}
