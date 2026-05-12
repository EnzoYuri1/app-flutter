class Usuario {
  
  //atributos.
  int? id;
  String email;
  String senha;

  //construtor.
  Usuario({
    this.id,
    required this.email,
    required this.senha,
  });

  // conversao do objeto para Map.
  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'email': email,
      'senha': senha,
    };
  }

  //conversao do Map para objeto.
  factory Usuario.fromMap(Map<String, dynamic> map) {

    return Usuario(
      id: map['id'],
      email: map['email'],
      senha: map['senha'],
    );
  }
}