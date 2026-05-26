import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        saldo REAL NOT NULL DEFAULT 1500,
        numeroConta TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE transferencias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL,
        destinatario TEXT NOT NULL,
        nomeDestinatario TEXT,
        valor REAL NOT NULL,
        data TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final usuarioColumns = await db.rawQuery('PRAGMA table_info(usuarios)');
      final usuarioColumnNames = usuarioColumns.map((c) => c['name']).toSet();

      if (!usuarioColumnNames.contains('numeroConta')) {
        await db.execute('ALTER TABLE usuarios ADD COLUMN numeroConta TEXT');
      }

      final usuarios = await db.query('usuarios');

      for (final usuario in usuarios) {
        final id = usuario['id'] as int;
        final contaAtual = usuario['numeroConta'];

        if (contaAtual == null || contaAtual.toString().trim().isEmpty) {
          final numeroConta = await gerarNumeroContaUnico(db);

          await db.update(
            'usuarios',
            {'numeroConta': numeroConta},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }

      final transferenciaColumns = await db.rawQuery(
        'PRAGMA table_info(transferencias)',
      );

      final transferenciaColumnNames = transferenciaColumns
          .map((c) => c['name'])
          .toSet();

      if (!transferenciaColumnNames.contains('nomeDestinatario')) {
        await db.execute(
          'ALTER TABLE transferencias ADD COLUMN nomeDestinatario TEXT',
        );
      }
    }
  }

  Future<String> gerarNumeroContaUnico([Database? database]) async {
    final db = database ?? await instance.database;
    final random = Random();

    while (true) {
      final numero = (10000 + random.nextInt(90000)).toString();

      final resultado = await db.query(
        'usuarios',
        where: 'numeroConta = ?',
        whereArgs: [numero],
        limit: 1,
      );

      if (resultado.isEmpty) {
        return numero;
      }
    }
  }

  Future<int> salvarUsuario(String nome, String email, String senha) async {
    final db = await instance.database;
    final numeroConta = await gerarNumeroContaUnico(db);

    return await db.insert('usuarios', {
      'nome': nome,
      'email': email,
      'senha': senha,
      'saldo': 1500.00,
      'numeroConta': numeroConta,
    });
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

  Future<Map<String, dynamic>?> buscarUsuarioPorConta(
    String numeroConta,
  ) async {
    final db = await instance.database;

    final resultado = await db.query(
      'usuarios',
      where: 'numeroConta = ?',
      whereArgs: [numeroConta.trim()],
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

    return await db.insert('transferencias', transferencia.toMap());
  }

  Future<Map<String, dynamic>> registrarTransferencia({
    required int usuarioId,
    required double valor,
    required String destinatario,
    required String contaDestinatario,
  }) async {
    final db = await instance.database;

    final usuario = await buscarUsuarioPorId(usuarioId);

    if (usuario == null) {
      throw Exception('Usuário não encontrado.');
    }

    final conta = contaDestinatario.trim();
    final nome = destinatario.trim();

    if (conta.isEmpty || nome.isEmpty) {
      throw Exception('Informe a conta e o nome do destinatário.');
    }

    if (conta.length != 5) {
      throw Exception('A conta deve ter 5 dígitos.');
    }

    if (valor <= 0) {
      throw Exception('Digite um valor válido.');
    }

    final saldoAtual = (usuario['saldo'] as num).toDouble();

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

    await db.insert('transferencias', {
      'usuarioId': usuarioId,
      'destinatario': conta,
      'nomeDestinatario': nome,
      'valor': valor,
      'data': DateTime.now().toIso8601String(),
    });

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
