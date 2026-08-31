// 1. Buat fungsi hitungLuasPersegiPanjang yang menerima panjang dan lebar bertipe double.
double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

// 2. Buat class Profil dengan properti nama, nim, dan email yang boleh kosong.
class Profil {
  String? nama;
  String? nim;
  String? email;
}

// 3. Panggil keduanya dari main(), lalu tangani email kosong dengan aman.
void main() {
  double luas = hitungLuasPersegiPanjang(10, 5);
  print(luas);

  Profil profil = Profil();
  profil.nama = 'Laksamana';
  profil.nim = '1234567890';
  profil.email = 'laksamana@sarana.ai';
  print(profil.email);
}
