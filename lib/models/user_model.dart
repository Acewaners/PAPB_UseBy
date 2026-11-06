// Model data User untuk aplikasi UseBy sesuai ERD.png
// Entitas USER: id_user (PK), nama, email, password, token (dari REST API)

class UserModel {
  final int idUser;
  final String nama;
  final String email;
  final String password;
  final DateTime? tanggalBergabung;
  final String? token; // Token autentikasi dari response server REST API

  UserModel({
    required this.idUser,
    required this.nama,
    required this.email,
    required this.password,
    this.tanggalBergabung,
    this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'nama': nama,
      'email': email,
      'password': password,
      'tanggal_bergabung': tanggalBergabung?.toIso8601String(),
      'token': token,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map['id_user'] as int? ?? 1,
      nama: map['nama'] as String? ?? 'Pengguna',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      tanggalBergabung: map['tanggal_bergabung'] != null
          ? DateTime.tryParse(map['tanggal_bergabung'] as String)
          : null,
      token: map['token'] as String?,
    );
  }

  UserModel copyWith({
    int? idUser,
    String? nama,
    String? email,
    String? password,
    DateTime? tanggalBergabung,
    String? token,
  }) {
    return UserModel(
      idUser: idUser ?? this.idUser,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      password: password ?? this.password,
      tanggalBergabung: tanggalBergabung ?? this.tanggalBergabung,
      token: token ?? this.token,
    );
  }
}
