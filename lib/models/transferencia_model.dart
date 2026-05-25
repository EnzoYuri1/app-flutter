class TransferenciaModel {

  final int usuarioId;
  final String destinatario;
  final double valor;
  final DateTime data;

  TransferenciaModel({
    required this.usuarioId,
    required this.destinatario,
    required this.valor,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'destinatario': destinatario,
      'valor': valor,
      'data': data.toIso8601String(),
    };
  }

  factory TransferenciaModel.fromMap(Map<String, dynamic> map) {
    return TransferenciaModel(
      usuarioId: map['usuarioId'],
      destinatario: map['destinatario'],
      valor: map['valor'],
      data: DateTime.parse(map['data']),
    );
  }
}