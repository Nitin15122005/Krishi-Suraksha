import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class AuthService {
  // Generate a random salt
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  // Hash password with salt
  String hashPassword(String password, String salt) {
    const codec = Utf8Codec();
    final key = codec.encode(password);
    final saltBytes = codec.encode(salt);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(saltBytes);
    return digest.toString();
  }

  // Verify password
  bool verifyPassword(String password, String hashedPassword, String salt) {
    final newHash = hashPassword(password, salt);
    return newHash == hashedPassword;
  }

  // Create password hash with salt
  Map<String, String> createPasswordHash(String password) {
    final salt = _generateSalt();
    final hashedPassword = hashPassword(password, salt);
    return {
      'password': hashedPassword,
      'salt': salt,
    };
  }
}
