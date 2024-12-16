import 'package:encrypt/encrypt.dart' as encrypt;

class CryptoUtils {
  static String encryptMessage(String plainText, String secretKey) {
    final key =
        encrypt.Key.fromUtf8(secretKey.padRight(32, '0').substring(0, 32));
    final iv = encrypt.IV.fromUtf8('abcdefghijklmnop');
    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decryptMessage(String encryptedText, String secretKey) {
    try {
      final key =
          encrypt.Key.fromUtf8(secretKey.padRight(32, '0').substring(0, 32));
      final iv = encrypt.IV.fromUtf8('abcdefghijklmnop');
      final encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      return decrypted;
    } catch (e) {
      print('❌ Eroare la decriptare: $e');
      return '*** Decrypt Error ***';
    }
  }
}
