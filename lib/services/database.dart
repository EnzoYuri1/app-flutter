import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/transferencia_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('nexbank.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        saldo REAL NOT NULL DEFAULT 1500
      )
    ''');

    await db.execute('''
      CREATE TABLE transferencias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL,
        destinatario TEXT NOT NULL,
        valor REAL NOT NULL,
        data TEXT NOT NULL
      )
    ''');
  }

  Future<int> salvarUsuario(
    String nome,
    String email,
    String senha,
  ) async {
    final db = await instance.database;

    return await db.insert(
      'usuarios',
      {
        'nome': nome,
        'email': email,
        'senha': senha,
        'saldo': 1500.00,
      },
    );
  }

  Future<Map<String, dynamic>?> buscarUsuarioPorLogin({
    required String email,
    required String senha,
  }) async {
    final db = await instance.database;

    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
      limit: 1,
    );

    if (resultado.isNotEmpty) {
      return resultado.first;
    }

    return null;
  }

  Future<Map<String, dynamic>?> buscarUsuarioPorId(int id) async {
    final db = await instance.database;

    final resultado = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isNotEmpty) {
      return resultado.first;
    }

    return null;
  }

  Future<void> atualizarSaldo(int usuarioId, double novoSaldo) async {
    final db = await instance.database;

    await db.update(
      'usuarios',
      {'saldo': novoSaldo},
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }

  Future<int> salvarTransferencia(TransferenciaModel transferencia) async {
    final db = await instance.database;

    return await db.insert(
      'transferencias',
      transferencia.toMap(),
    );
  }

  Future<Map<String, dynamic>> registrarTransferencia({
    required int usuarioId,
    required double valor,
    required String destinatario,
  }) async {
    final db = await instance.database;

    final usuario = await buscarUsuarioPorId(usuarioId);

    if (usuario == null) {
      throw Exception('Usuário não encontrado.');
    }

    final saldoAtual = (usuario['saldo'] as num).toDouble();

    if (valor <= 0) {
      throw Exception('Digite um valor válido.');
    }

    if (valor > saldoAtual) {
      throw Exception('Saldo insuficiente.');
    }

    final novoSaldo = saldoAtual - valor;

    await db.update(
      'usuarios',
      {'saldo': novoSaldo},
      where: 'id = ?',
      whereArgs: [usuarioId],
    );

    final transferencia = TransferenciaModel(
      usuarioId: usuarioId,
      destinatario: destinatario,
      valor: valor,
      data: DateTime.now(),
    );

    await db.insert(
      'transferencias',
      transferencia.toMap(),
    );

    final usuarioAtualizado = await buscarUsuarioPorId(usuarioId);

    return usuarioAtualizado!;
  }

  Future<List<TransferenciaModel>> listarTransferencias(int usuarioId) async {
    final db = await instance.database;

    final resultado = await db.query(
      'transferencias',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'data DESC',
    );

    return resultado.map((map) {
      return TransferenciaModel.fromMap(map);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> buscarHistorico({int? usuarioId}) async {
    final db = await instance.database;

    if (usuarioId == null) {
      return [];
    }

    return await db.query(
      'transferencias',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'data DESC',
    );
  }

  Future<void> fecharBanco() async {
    final db = await instance.database;
    await db.close();
  }
}