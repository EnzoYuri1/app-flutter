import 'database.dart';

class AuthenticationService {
  // Faz login e retorna os dados do usuário encontrado.
  // Se não encontrar, retorna null.
  Future<Map<String, dynamic>?> login(String email, String senha) async {
    try {
      final db = await DatabaseService.instance.database;

      final result = await db.query(
        'usuarios',
        where: 'email = ? AND senha = ?',
        whereArgs: [email, senha],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first;
      }

      return null;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  Future<bool> register(String nome, String email, String senha) async {
    try {
      await DatabaseService.instance.salvarUsuario(nome, email, senha);
      return true;
    } catch (e) {
      print('Erro no registro: $e');
      return false;
    }
  }
}
