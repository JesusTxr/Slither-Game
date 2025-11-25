import 'package:supabase_flutter/supabase_flutter.dart';

/// 💳 Servicio de Pagos - Simulación de procesamiento de tarjetas
/// Este servicio simula un sistema de pagos con validación de tarjetas
class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Validar número de tarjeta usando algoritmo de Luhn
  /// https://es.wikipedia.org/wiki/Algoritmo_de_Luhn
  bool validateCardNumber(String cardNumber) {
    // Eliminar espacios y guiones
    cardNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    // Verificar que solo contenga números
    if (!RegExp(r'^\d+$').hasMatch(cardNumber)) {
      return false;
    }
    
    // Verificar longitud (13-19 dígitos es válido)
    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return false;
    }
    
    // Algoritmo de Luhn
    int sum = 0;
    bool alternate = false;
    
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
  
  /// Detectar tipo de tarjeta
  String detectCardType(String cardNumber) {
    cardNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cardNumber.isEmpty) return 'desconocida';
    
    // Visa: empieza con 4
    if (cardNumber.startsWith('4')) {
      return 'Visa';
    }
    
    // Mastercard: empieza con 51-55 o 2221-2720
    if (cardNumber.startsWith(RegExp(r'^5[1-5]')) ||
        cardNumber.startsWith(RegExp(r'^2[2-7]'))) {
      return 'Mastercard';
    }
    
    // American Express: empieza con 34 o 37
    if (cardNumber.startsWith('34') || cardNumber.startsWith('37')) {
      return 'American Express';
    }
    
    // Discover: empieza con 6011, 622126-622925, 644-649, 65
    if (cardNumber.startsWith('6011') ||
        cardNumber.startsWith(RegExp(r'^62[2-9]')) ||
        cardNumber.startsWith(RegExp(r'^64[4-9]')) ||
        cardNumber.startsWith('65')) {
      return 'Discover';
    }
    
    return 'Otra';
  }
  
  /// Validar fecha de expiración (MM/AA)
  bool validateExpiryDate(String expiryDate) {
    // Formato esperado: MM/AA
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) {
      return false;
    }
    
    final parts = expiryDate.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) {
      return false;
    }
    
    // Validar mes (01-12)
    if (month < 1 || month > 12) {
      return false;
    }
    
    // Validar que no esté expirada
    final now = DateTime.now();
    final fullYear = 2000 + year; // Convertir AA a AAAA
    final expiryDateTime = DateTime(fullYear, month, 1);
    final currentMonthStart = DateTime(now.year, now.month, 1);
    
    return expiryDateTime.isAfter(currentMonthStart) || 
           expiryDateTime.isAtSameMomentAs(currentMonthStart);
  }
  
  /// Validar CVV
  bool validateCVV(String cvv, String cardType) {
    // American Express usa 4 dígitos, otros usan 3
    final expectedLength = cardType == 'American Express' ? 4 : 3;
    
    return RegExp(r'^\d{$expectedLength}$'.replaceAll('\$expectedLength', expectedLength.toString())).hasMatch(cvv);
  }
  
  /// 💰 Procesar pago (simulado)
  /// Registra la compra en Supabase
  Future<Map<String, dynamic>> processPayment({
    required String skinId,
    required String skinName,
    required double price,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
  }) async {
    try {
      // 1. Validar todos los datos
      if (!validateCardNumber(cardNumber)) {
        return {
          'success': false,
          'error': 'Número de tarjeta inválido',
        };
      }
      
      if (!validateExpiryDate(expiryDate)) {
        return {
          'success': false,
          'error': 'Fecha de expiración inválida o tarjeta expirada',
        };
      }
      
      final cardType = detectCardType(cardNumber);
      if (!validateCVV(cvv, cardType)) {
        return {
          'success': false,
          'error': 'CVV inválido para este tipo de tarjeta',
        };
      }
      
      if (cardHolderName.trim().isEmpty) {
        return {
          'success': false,
          'error': 'Nombre del titular requerido',
        };
      }
      
      // 2. Obtener datos del usuario actual
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'Usuario no autenticado',
        };
      }
      
      // 3. Simular procesamiento (delay de 1-2 segundos)
      await Future.delayed(Duration(milliseconds: 1500));
      
      // 4. Obtener últimos 4 dígitos
      final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
      final last4Digits = cleanCardNumber.substring(cleanCardNumber.length - 4);
      
      // 5. Generar número de comprobante único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final numeroComprobante = 'COMP-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${timestamp.toString().substring(timestamp.toString().length - 8)}';
      
      // 6. Registrar en Supabase
      final response = await _supabase.from('pagos_tienda').insert({
        'user_id': user.id,
        'email': user.email ?? 'sin-email@local.com',
        'skin_id': skinId,
        'skin_name': skinName,
        'precio': price,
        'ultimos_4_digitos': last4Digits,
        'tipo_tarjeta': cardType,
        'nombre_titular': cardHolderName.trim(),
        'estado': 'completado',
        'numero_comprobante': numeroComprobante,
      }).select().single();
      
      print('✅ Pago procesado exitosamente: $numeroComprobante');
      
      return {
        'success': true,
        'comprobante': numeroComprobante,
        'paymentData': response,
      };
      
    } catch (e) {
      print('❌ Error procesando pago: $e');
      return {
        'success': false,
        'error': 'Error al procesar el pago: ${e.toString()}',
      };
    }
  }
  
  /// 📋 Obtener historial de compras del usuario
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return [];
      }
      
      final response = await _supabase
          .from('pagos_tienda')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error obteniendo historial: $e');
      return [];
    }
  }
  
  /// 🎨 Verificar si el usuario ya compró una skin
  Future<bool> hasPurchasedSkin(String skinId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return false;
      }
      
      final response = await _supabase
          .from('pagos_tienda')
          .select('id')
          .eq('user_id', user.id)
          .eq('skin_id', skinId)
          .eq('estado', 'completado')
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      print('❌ Error verificando compra: $e');
      return false;
    }
  }
  
  /// 🎨 Obtener lista de skins compradas por el usuario
  Future<List<String>> getPurchasedSkins() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return [];
      }
      
      final response = await _supabase
          .from('pagos_tienda')
          .select('skin_id')
          .eq('user_id', user.id)
          .eq('estado', 'completado');
      
      return List<String>.from(
        response.map((item) => item['skin_id'] as String).toSet(),
      );
    } catch (e) {
      print('❌ Error obteniendo skins compradas: $e');
      return [];
    }
  }
  
  /// 📄 Obtener detalles de comprobante por número
  Future<Map<String, dynamic>?> getReceiptByNumber(String numeroComprobante) async {
    try {
      final response = await _supabase
          .from('pagos_tienda')
          .select()
          .eq('numero_comprobante', numeroComprobante)
          .single();
      
      return response;
    } catch (e) {
      print('❌ Error obteniendo comprobante: $e');
      return null;
    }
  }
}

