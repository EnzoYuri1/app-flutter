import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Garante que exista apenas 1 instância do banco no app.
  static final DatabaseService instance = DatabaseService._init();

  // Instância privada do banco.
  static Database? _database;

  // Construtor privado.
  DatabaseService._init();

  // Retorna o banco aberto ou inicializa caso não exista.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('banco_digital.db');
    return _database!;
  }

  // Cria ou abre o caminho do arquivo do banco.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Criação das tabelas (Pessoa 1 e Pessoa 4)
  Future _createDB(Database db, int version) async {
    // Tabela de usuários (Pessoa 1)
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        senha TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transferencias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        valor REAL NOT NULL,
        destinatario TEXT NOT NULL,
        data TEXT NOT NULL
      )
    ''');
  }


  Future<void> salvarUsuario(String nome, String email, String senha) async {
    final db = await instance.database;
    await db.insert(
      'usuarios',
      {
        'nome': nome,
        'email': email,
        'senha': senha,
      },
    );
  }

  Future<bool> verificarUsuario(String email, String senha) async {
    final db = await instance.database;
    final result = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    return result.isNotEmpty;
  }


  // Salva uma nova transferência no banco
  Future<int> registrarTransferencia(double valor, String destino) async {
    final db = await instance.database;
    return await db.insert('transferencias', {
      'valor': valor,
      'destinatario': destino,
      'data': DateTime.now().toString().substring(0, 16), // Salva "AAAA-MM-DD HH:MM"
    });
  }

  // Busca todas as transferências para exibir no histórico
  Future<List<Map<String, dynamic>>> buscarHistorico() async {
    final db = await instance.database;
    // Retorna as transações da mais recente para a mais antiga
    return await db.query('transferencias', orderBy: 'id DESC');
  }
}
