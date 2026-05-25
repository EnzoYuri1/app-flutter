import 'package:dio/dio.dart';
import '../models/cotacao_model.dart';

class CotacaoService {
  Future<CotacaoModel> getData() async {
    var response = await Dio().get(
      'https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL',
    );

    double dolar = double.parse(response.data['USDBRL']['bid']);
    double euro = double.parse(response.data['EURBRL']['bid']);

    return CotacaoModel(dolar: dolar, euro: euro);
  }
}