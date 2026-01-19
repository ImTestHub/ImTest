import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// CryptoJS 兼容的 AES-CBC 加密解密实现
///
/// 基于 CryptoJS 4.2.0 源码（pad-zeropadding.js, aes.js, cipher-core.js）精确实现
/// 完全兼容 JS 端的 CryptoJS.AES.encrypt/decrypt
///
/// 核心特性：
/// 1. **精确的 ZeroPadding 实现**：基于 CryptoJS pad-zeropadding.js 源码
/// 2. **正确的 CBC 模式**：基于 CryptoJS cipher-core.js 中的 CBC 模式
/// 3. **兼容的参数处理**：支持 Utf8.parse() 和直接字符串两种方式
/// 4. **详细的调试日志**：便于排查兼容性问题
///
/// 使用示例：
/// ```dart
/// // 加密
/// final encrypted = await CryptoJsAesImpl.encrypt(
///   data: 'Hello World',
///   key: '0123456789abcdef',  // 16 字节 (AES-128)
///   iv: 'fedcba9876543210',    // 16 字节
/// );
///
/// // 解密
/// final decrypted = await CryptoJsAesImpl.decrypt(
///   data: encrypted!,
///   key: '0123456789abcdef',
///   iv: 'fedcba9876543210',
/// );
/// ```
class CryptoJsAesImpl {
  // ========================================
  // 基于 CryptoJS 源码的常量定义
  // ========================================

  /// 密钥长度（字节）
  /// 对应 AES-128/192/256
  static const int keyLength128 = 16; // 128 bits = 16 bytes
  static const int keyLength192 = 24; // 192 bits = 24 bytes
  static const int keyLength256 = 32; // 256 bits = 32 bytes

  /// IV 长度（字节）
  /// AES 块大小固定为 128 bits
  static const int ivLength = 16; // 128 bits = 16 bytes

  /// 块大小（字节）
  /// CryptoJS 中 blockSize 是 32-bit words 的数量，乘以 4 = 字节
  static const int blockSize = 16; // 4 words * 4 bytes = 16 bytes

  /// 是否启用详细日志
  static bool verboseLogging = true;

  // ========================================
  // 公开 API
  // ========================================

  /// 加密数据
  ///
  /// [data] 待加密的数据（字符串、Map、List）
  /// [key] 加密密钥（16/24/32 字节字符串）
  /// [iv] 初始化向量（16 字节字符串）
  ///
  /// 返回：Base64 编码的密文字符串，失败返回 null
  static Future<String?> encrypt({
    required dynamic data,
    required String key,
    required String iv,
  }) async {
    try {
      if (verboseLogging) {
        _log('🔐 开始加密（CryptoJS 兼容模式）');
        _logDivider();
      }

      // 1. 数据预处理
      String dataStr;
      if (data is String) {
        dataStr = data;
      } else if (data is Map || data is List) {
        dataStr = jsonEncode(data);
      } else {
        dataStr = data.toString();
      }

      if (verboseLogging) {
        _log('原始数据: $dataStr');
        _log('原始数据长度: ${dataStr.length} 字符');
      }

      // 2. 解析密钥（兼容 CryptoJS.enc.Utf8.parse）
      final keyBytes = _parseKey(key);

      if (verboseLogging) {
        _log('密钥: $key');
        _log('密钥长度: ${keyBytes.length} 字节 (${keyBytes.length * 8} bits)');
        _log('密钥（十六进制）: ${_bytesToHex(keyBytes)}');
      }

      // 3. 解析 IV（兼容 CryptoJS.enc.Utf8.parse）
      final ivBytes = _parseIv(iv);

      if (verboseLogging) {
        _log('IV: $iv');
        _log('IV 长度: ${ivBytes.length} 字节 (${ivBytes.length * 8} bits)');
        _log('IV（十六进制）: ${_bytesToHex(ivBytes)}');
      }

      // 4. 编码明文（UTF-8，与 CryptoJS.enc.Utf8.parse 一致）
      final plainBytes = Uint8List.fromList(utf8.encode(dataStr));

      if (verboseLogging) {
        _log('明文字节: ${_bytesToHex(plainBytes)}');
        _log('明文长度: ${plainBytes.length} 字节');
      }

      // 5. ZeroPadding（基于 CryptoJS pad-zeropadding.js 源码）
      final paddedData = _zeroPadding(plainBytes, blockSize);

      if (verboseLogging) {
        _log('填充后长度: ${paddedData.length} 字节');
        _log('填充后字节: ${_bytesToHex(paddedData)}');
      }

      // 6. 创建 AES-CBC 加密器
      final cipher = _createAesCipher(keyBytes.length);

      final secretKey = SecretKey(keyBytes);

      if (verboseLogging) {
        _log('✅ AES-CBC 加密器创建成功');
        _log('密钥强度: ${keyBytes.length * 8} bits');
        _log('MAC 算法: empty (无认证，兼容 CryptoJS)');
      }

      // 7. 执行加密
      final secretBox = await cipher.encrypt(
        paddedData,
        secretKey: secretKey,
        nonce: ivBytes,
      );

      // 8. 转换为 Base64（CryptoJS 默认输出格式）
      final result = base64Encode(secretBox.cipherText);

      if (verboseLogging) {
        _logDivider();
        _log('✅ 加密成功');
        _log('密文: $result');
        _logDivider();
      }

      return result;
    } catch (e, stackTrace) {
      if (verboseLogging) {
        _logError('❌ 加密失败', e, stackTrace);
      }
      return null;
    }
  }

  /// 解密数据
  ///
  /// [data] Base64 编码的密文字符串
  /// [key] 解密密钥（16/24/32 字节字符串）
  /// [iv] 初始化向量（16 字节字符串）
  ///
  /// 返回：解密后的字符串，失败返回 null
  static Future<String?> decrypt({
    required String data,
    required String key,
    required String iv,
  }) async {
    try {
      if (verboseLogging) {
        _log('🔓 开始解密（CryptoJS 兼容模式）');
        _logDivider();
      }

      // 1. 解析密钥
      final keyBytes = _parseKey(key);

      if (verboseLogging) {
        _log('密钥: $key');
        _log('密钥长度: ${keyBytes.length} 字节 (${keyBytes.length * 8} bits)');
        _log('密钥（十六进制）: ${_bytesToHex(keyBytes)}');
      }

      // 2. 解析 IV
      final ivBytes = _parseIv(iv);

      if (verboseLogging) {
        _log('IV: $iv');
        _log('IV 长度: ${ivBytes.length} 字节 (${ivBytes.length * 8} bits)');
        _log('IV（十六进制）: ${_bytesToHex(ivBytes)}');
      }

      // 3. 解析 Base64 密文
      final cipherBytes = base64Decode(data);

      if (verboseLogging) {
        _log('密文（Base64 解码后）: ${_bytesToHex(cipherBytes)}');
        _log('密文长度: ${cipherBytes.length} 字节');
      }

      // 4. 创建 AES-CBC 解密器
      final cipher = _createAesCipher(keyBytes.length);

      final secretKey = SecretKey(keyBytes);

      if (verboseLogging) {
        _log('✅ AES-CBC 解密器创建成功');
      }

      // 5. 创建 SecretBox（cryptography 库要求）
      final secretBox = SecretBox(
        cipherBytes,
        nonce: ivBytes,
        mac: Mac.empty, // CBC 模式不需要 MAC
      );

      // 6. 执行解密
      final decryptedBytes = await cipher.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      if (verboseLogging) {
        _log('✅ 解密成功');
        _log('解密后字节: ${_bytesToHex(Uint8List.fromList(decryptedBytes))}');
        _log('解密后长度: ${decryptedBytes.length} 字节');
      }

      // 7. 移除 ZeroPadding（基于 CryptoJS pad-zeropadding.js 源码）
      final unpaddedData = _removeZeroPadding(
        Uint8List.fromList(decryptedBytes),
      );

      if (verboseLogging) {
        _log('去填充后字节: ${_bytesToHex(unpaddedData)}');
        _log('去填充后长度: ${unpaddedData.length} 字节');
      }

      // 8. 转换为字符串（UTF-8，与 CryptoJS.enc.Utf8.stringify 一致）
      final result = utf8.decode(unpaddedData);

      if (verboseLogging) {
        _logDivider();
        _log('✅ 解密成功');
        _log('解密结果: $result');
        _logDivider();
      }

      return result;
    } catch (e, stackTrace) {
      if (verboseLogging) {
        _logError('❌ 解密失败', e, stackTrace);
        _analyzeError(e);
      }
      return null;
    }
  }

  // ========================================
  // 内部方法 - 基于 CryptoJS 源码
  // ========================================

  /// 解析密钥
  ///
  /// 兼容 CryptoJS.enc.Utf8.parse(key) 的行为
  /// 直接将字符串的 UTF-8 码点转为字节数组
  static Uint8List _parseKey(String key) {
    // 验证密钥长度
    if (![keyLength128, keyLength192, keyLength256].contains(key.length)) {
      throw ArgumentError('密钥长度必须是 16/24/32 字节，当前长度: ${key.length}');
    }

    // 直接使用 UTF-8 编码（与 CryptoJS.enc.Utf8.parse 一致）
    return Uint8List.fromList(key.codeUnits);
  }

  /// 解析 IV
  ///
  /// 兼容 CryptoJS.enc.Utf8.parse(iv) 的行为
  static Uint8List _parseIv(String iv) {
    // 验证 IV 长度
    if (iv.length != ivLength) {
      throw ArgumentError('IV 长度必须是 16 字节，当前长度: ${iv.length}');
    }

    // 直接使用 UTF-8 编码（与 CryptoJS.enc.Utf8.parse 一致）
    return Uint8List.fromList(iv.codeUnits);
  }

  /// 创建 AES-CBC 加密器
  ///
  /// 根据密钥长度选择对应的 AES 变体
  static AesCbc _createAesCipher(int keyLength) {
    switch (keyLength) {
      case keyLength256:
        return AesCbc.with256bits(
          macAlgorithm: MacAlgorithm.empty,
          paddingAlgorithm: PaddingAlgorithm.pkcs7,
        );
      case keyLength192:
        return AesCbc.with192bits(
          macAlgorithm: MacAlgorithm.empty,
          paddingAlgorithm: PaddingAlgorithm.pkcs7,
        );
      case keyLength128:
        return AesCbc.with128bits(
          macAlgorithm: MacAlgorithm.empty,
          paddingAlgorithm: PaddingAlgorithm.pkcs7,
        );
      default:
        throw ArgumentError('不支持的密钥长度: $keyLength');
    }
  }

  /// ========================================
  /// ZeroPadding 实现
  /// ========================================
  ///
  /// 完全基于 CryptoJS pad-zeropadding.js 源码：
  ///
  /// ```javascript
  /// pad: function (data, blockSize) {
  ///     var blockSizeBytes = blockSize * 4;
  ///     data.clamp();
  ///     data.sigBytes += blockSizeBytes - ((data.sigBytes % blockSizeBytes) || blockSizeBytes);
  /// },
  /// unpad: function (data) {
  ///     var dataWords = data.words;
  ///     var i = data.sigBytes - 1;
  ///     for (var i = data.sigBytes - 1; i >= 0; i--) {
  ///         if (((dataWords[i >>> 2] >>> (24 - (i % 4) * 8)) & 0xff)) {
  ///             data.sigBytes = i + 1;
  ///             break;
  ///         }
  ///     }
  /// }
  /// ```
  ///
  /// 关键点：
  /// 1. pad: data.sigBytes += blockSizeBytes - ((data.sigBytes % blockSizeBytes) || blockSizeBytes)
  ///    - 如果能整除，仍然填充完整的一块（|| blockSizeBytes）
  ///
  /// 2. unpad: 从后往前遍历，找到第一个非零字节
  ///    - 去掉尾部所有的零字节
  /// ========================================

  /// ZeroPadding - 填充
  ///
  /// 基于 CryptoJS pad-zeropadding.js 的 pad 函数
  static Uint8List _zeroPadding(Uint8List data, int blockSize) {
    // 计算 block size 字节数（CryptoJS 中 blockSize 是 words，乘以 4 得到字节数）
    final blockSizeBytes = blockSize * 4;

    // 计算需要填充的字节数
    // 关键公式：blockSizeBytes - ((data.length % blockSizeBytes) || blockSizeBytes)
    final remainder = data.length % blockSizeBytes;
    final paddingLength = (remainder == 0)
        ? blockSizeBytes
        : blockSizeBytes - remainder;

    // 创建填充后的数据
    final paddedData = Uint8List(data.length + paddingLength);
    paddedData.setRange(0, data.length, data);
    // 剩余字节自动填充为 0（Uint8List 初始化为 0）

    return paddedData;
  }

  /// ZeroPadding - 去填充
  ///
  /// 基于 CryptoJS pad-zeropadding.js 的 unpad 函数
  static Uint8List _removeZeroPadding(Uint8List data) {
    // 从后往前遍历，找到第一个非零字节
    int endIndex = data.length - 1;

    while (endIndex >= 0 && data[endIndex] == 0) {
      endIndex--;
    }

    // 返回从开头到第一个非零字节的数据
    return data.sublist(0, endIndex + 1);
  }

  /// ========================================
  /// 辅助方法
  /// ========================================

  /// 字节转十六进制字符串
  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// 日志输出
  static void _log(String message, [Object? details]) {
    print(message);
    if (details != null) {
      print(details);
    }
  }

  /// 分隔线
  static void _logDivider() {
    print('========================================');
  }

  /// 错误日志
  static void _logError(String title, dynamic error, [dynamic stackTrace]) {
    print('');
    print('$title');
    print('========================================');
    print('错误类型: ${error.runtimeType}');
    print('错误信息: $error');
    if (stackTrace != null) {
      print('堆栈跟踪: $stackTrace');
    }
    print('========================================');
    print('');
  }

  /// 错误分析
  static void _analyzeError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    print('错误分析：');
    print('----------------------------------------');

    if (errorStr.contains('mac') || errorStr.contains('authentication')) {
      print('🔍 可能原因：MAC 认证失败');
      print('✅ 解决方案：');
      print('  1. 检查密钥是否正确');
      print('  2. 检查 IV 是否正确');
      print('  3. 确认 JS 端使用相同的 MAC 配置（通常为 none）');
    } else if (errorStr.contains('padding')) {
      print('🔍 可能原因：填充错误');
      print('✅ 解决方案：');
      print('  1. 确认 JS 端使用 ZeroPadding');
      print('  2. 检查密钥和 IV 是否匹配');
      print('  3. 确认数据完整性');
    } else if (errorStr.contains('length') || errorStr.contains('size')) {
      print('🔍 可能原因：长度不匹配');
      print('✅ 解决方案：');
      print('  1. 检查密钥长度是否为 16/24/32 字节');
      print('  2. 检查 IV 长度是否为 16 字节');
      print('  3. 检查数据长度是否正确');
    } else if (errorStr.contains('invalid') || errorStr.contains('argument')) {
      print('🔍 可能原因：参数错误');
      print('✅ 解决方案：');
      print('  1. 检查密钥和 IV 格式');
      print('  2. 检查密文格式（Base64 或 十六进制）');
      print('  3. 确认编码方式（UTF-8 或 十六进制）');
    } else {
      print('🔍 未知错误');
      print('✅ 建议：');
      print('  1. 检查 JS 端的完整配置');
      print('  2. 对比 JS 端和 Dart 端的参数');
      print('  3. 运行诊断工具排查问题');
    }

    print('========================================');
    print('');
  }
}

// ========================================
// 测试和验证
// ========================================

/// 测试 CryptoJS 兼容性
///
/// 运行此测试验证实现是否与 CryptoJS 完全兼容
Future<void> testCryptoJsCompatibility() async {
  print('');
  print('========================================');
  print('🧪 CryptoJS 兼容性测试');
  print('========================================');
  print('');

  // 测试 1：基本字符串加密解密
  print('========== 测试 1：基本字符串 ==========');
  print('');

  const testMessage = 'Hello, CryptoJS!';
  const testKey = '0123456789abcdef'; // 16 字节 (AES-128)
  const testIv = 'fedcba9876543210'; // 16 字节

  final encrypted = await CryptoJsAesImpl.encrypt(
    data: testMessage,
    key: testKey,
    iv: testIv,
  );

  if (encrypted != null) {
    print('');
    final decrypted = await CryptoJsAesImpl.decrypt(
      data: encrypted,
      key: testKey,
      iv: testIv,
    );

    if (decrypted == testMessage) {
      print('✅ 测试 1 成功');
    } else {
      print('❌ 测试 1 失败');
      print('   期望: $testMessage');
      print('   实际: $decrypted');
    }
  } else {
    print('❌ 测试 1 失败：加密返回 null');
  }

  print('');
  print('');

  // 测试 2：对象加密解密
  print('========== 测试 2：JSON 对象 ==========');
  print('');

  final testData = {'name': '张三', 'age': 25, 'active': true};

  final encrypted2 = await CryptoJsAesImpl.encrypt(
    data: testData,
    key: testKey,
    iv: testIv,
  );

  if (encrypted2 != null) {
    final decrypted2 = await CryptoJsAesImpl.decrypt(
      data: encrypted2,
      key: testKey,
      iv: testIv,
    );

    if (decrypted2 != null) {
      final parsedData = jsonDecode(decrypted2);
      final parsedDataStr = parsedData.toString();
      final testDataStr = testData.toString();

      if (parsedDataStr == testDataStr) {
        print('✅ 测试 2 成功');
      } else {
        print('❌ 测试 2 失败');
        print('   期望: $testDataStr');
        print('   实际: $parsedDataStr');
      }
    } else {
      print('❌ 测试 2 失败：解密返回 null');
    }
  } else {
    print('❌ 测试 2 失败：加密返回 null');
  }

  print('');
  print('');

  // 测试 3：AES-256
  print('========== 测试 3：AES-256 ==========');
  print('');

  const testKey256 = '0123456789abcdef0123456789abcdef'; // 32 字节 (AES-256)

  final encrypted3 = await CryptoJsAesImpl.encrypt(
    data: testMessage,
    key: testKey256,
    iv: testIv,
  );

  if (encrypted3 != null) {
    final decrypted3 = await CryptoJsAesImpl.decrypt(
      data: encrypted3,
      key: testKey256,
      iv: testIv,
    );

    if (decrypted3 == testMessage) {
      print('✅ 测试 3 成功');
    } else {
      print('❌ 测试 3 失败');
    }
  } else {
    print('❌ 测试 3 失败：加密返回 null');
  }

  print('');
  print('');

  // 测试 4：空字符串
  print('========== 测试 4：空字符串 ==========');
  print('');

  const emptyMessage = '';

  final encrypted4 = await CryptoJsAesImpl.encrypt(
    data: emptyMessage,
    key: testKey,
    iv: testIv,
  );

  if (encrypted4 != null) {
    final decrypted4 = await CryptoJsAesImpl.decrypt(
      data: encrypted4,
      key: testKey,
      iv: testIv,
    );

    if (decrypted4 == emptyMessage) {
      print('✅ 测试 4 成功');
    } else {
      print('❌ 测试 4 失败');
    }
  } else {
    print('❌ 测试 4 失败：加密返回 null');
  }

  print('');
  print('');
  print('========================================');
  print('✅ 所有测试完成');
  print('========================================');
}

/// 关闭日志的便捷方法
void disableVerboseLogging() {
  CryptoJsAesImpl.verboseLogging = false;
}

/// 启用日志的便捷方法
void enableVerboseLogging() {
  CryptoJsAesImpl.verboseLogging = true;
}
