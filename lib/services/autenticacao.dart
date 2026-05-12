import 'database.dart';

class AuthenticationService {

  //faz verificação de um usuário a partir de email e senha informados.
  //tendo true como  retorno se encontrar no banco, caso não, retorna false.
  Future<bool> login(String email, String senha) async {
    try {

      //acessa o banco de dados
      final db = await DatabaseService.instance.database;

      //faz a busca no banco de dados filtrando por email e senha.
      final result = await db.query(
        'usuarios',
        where: 'email = ? AND senha = ?',
        whereArgs: [email, senha],
      );

      return result.isNotEmpty;
    } catch (e) {
      print("Erro no login: $e");
      return false;
    }
  }

  //cria um novo usuaário  no banco de dados.
  //retorna true se salvou com sucesso ou false se falhou.
  Future<bool> register(String nome, String email, String senha) async {
    try {
      //método responsável por inserir dados no banco.
      await DatabaseService.instance.salvarUsuario(nome, email, senha);
      return true;
    } catch (e) {
      //caso dê errado na inserção.
      print("Erro no registro: $e");
      return false;
    }
  }
}