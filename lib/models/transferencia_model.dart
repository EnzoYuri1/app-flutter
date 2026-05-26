class TransferenciaModel {
  final int usuarioId;
  final String destinatario;
  final String? nomeDestinatario;
  final double valor;
  final DateTime data;

  TransferenciaModel({
    required this.usuarioId,
    required this.destinatario,
    this.nomeDestinatario,
    required this.valor,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'destinatario': destinatario,
      'nomeDestinatario': nomeDestinatario,
      'valor': valor,
      'data': data.toIso8601String(),
    };
  }

  factory TransferenciaModel.fromMap(Map<String, dynamic> map) {
    return TransferenciaModel(
      usuarioId: map['usuarioId'],
      destinatario: map['destinatario'],
      nomeDestinatario: map['nomeDestinatario'],
      valor: (map['valor'] as num).toDouble(),
      data: DateTime.parse(map['data']),
    );
  }
}
