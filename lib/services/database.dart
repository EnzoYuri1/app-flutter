import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {

  //garante que exista apenas 1 instância do banco no no app.
  static final DatabaseService instance = DatabaseService._init();

  //instância privada do banco.
  static Database? _database;

  //construtor.
  DatabaseService._init();

  //faz o retorno do banco já aberto ou inicializa caso não exista.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('banco_digital.db');
    return _database!;
  }

  //cria ou abre o caminho do arquivo do banco.
  Future<Database> _initDB(String filePath) async {

    //caminho padrão onde o banco fica salvo no dispositivo.
    final dbPath = await getDatabasesPath();

    //faz a junção do caminho com o nome do aquivo do banco(caminho+nome).
    final path = join(dbPath, filePath);

    //abre o banco ou cria caso não exista.
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {

    //cria a tabela de usuários.
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        senha TEXT NOT NULL
      )
    ''');

    //cria a tabela de transferências.
    await db.execute('''
      CREATE TABLE transferencias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        destinatario TEXT NOT NULL,
        valor REAL NOT NULL,
        data TEXT NOT NULL
      )
    ''');
  }

  //insere um novo usuário no banco.
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

  //verifica há um usuário com o email e senha que foram fornecidos.
  Future<bool> verificarUsuario(String email, String senha) async {
    final db = await instance.database;

    final result = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );

    //caso tenha encontrado alguma registro, o login é válido.
    return result.isNotEmpty;
  }

  //registra uma nova transferência.
  Future<void> registrarTransferencia(
    double valor,
    String destinatario,
  ) async {

    final db = await instance.database;

    await db.insert(
      'transferencias',
      {
        'destinatario': destinatario,
        'valor': valor,
        'data': DateTime.now().toString(),
      },
    );
  }

  //busca o histórico de transferências.
  Future<List<Map<String, dynamic>>> buscarHistorico() async {

    final db = await instance.database;

    return await db.query(
      'transferencias',
      orderBy: 'id DESC',
    );
  }
}