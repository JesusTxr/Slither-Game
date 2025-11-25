import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shop_skin.dart';
import '../services/payment_service.dart';
import 'receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  final ShopSkin skin;
  
  const PaymentScreen({Key? key, required this.skin}) : super(key: key);
  
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _paymentService = PaymentService();
  
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  
  String _cardType = '';
  bool _isProcessing = false;
  
  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  
  void _onCardNumberChanged(String value) {
    setState(() {
      _cardType = _paymentService.detectCardType(value);
    });
  }
  
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final result = await _paymentService.processPayment(
        skinId: widget.skin.id,
        skinName: widget.skin.name,
        price: widget.skin.price,
        cardNumber: _cardNumberController.text,
        expiryDate: _expiryController.text,
        cvv: _cvvController.text,
        cardHolderName: _nameController.text,
      );
      
      if (result['success']) {
        // Navegar a pantalla de comprobante
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptScreen(
                paymentData: result['paymentData'],
                skin: widget.skin,
              ),
            ),
          );
        }
      } else {
        // Mostrar error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['error']}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Contenido con scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Información del producto
                        _buildProductInfo(),
                        SizedBox(height: 30),
                        
                        // Formulario de tarjeta
                        _buildCardForm(),
                        SizedBox(height: 30),
                        
                        // Botón de pago
                        _buildPayButton(),
                        SizedBox(height: 20),
                        
                        // Nota de seguridad
                        _buildSecurityNote(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 10),
          Text(
            '💳 Pago Seguro',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          // Preview de la skin
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.skin.skin.secondaryColor,
                  widget.skin.skin.primaryColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.skin.skin.primaryColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.skin.emoji} ${widget.skin.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Skin ${widget.skin.rarity}',
                  style: TextStyle(
                    color: Color(widget.skin.rarityColor),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Precio
          Text(
            '\$${widget.skin.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Número de tarjeta
        _buildLabel('Número de Tarjeta'),
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white, fontSize: 16),
          decoration: _buildInputDecoration(
            hint: '1234 5678 9012 3456',
            icon: Icons.credit_card,
            suffix: _cardType.isNotEmpty ? Text(
              _cardType,
              style: TextStyle(color: Colors.greenAccent, fontSize: 12),
            ) : null,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19),
            _CardNumberFormatter(),
          ],
          onChanged: _onCardNumberChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese número de tarjeta';
            }
            if (!_paymentService.validateCardNumber(value)) {
              return 'Número de tarjeta inválido';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        
        // Fecha de expiración y CVV (en fila)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Vencimiento'),
                  TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    decoration: _buildInputDecoration(
                      hint: 'MM/AA',
                      icon: Icons.calendar_today,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryDateFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      if (!_paymentService.validateExpiryDate(value)) {
                        return 'Inválido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('CVV'),
                  TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    obscureText: true,
                    decoration: _buildInputDecoration(
                      hint: '123',
                      icon: Icons.lock,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      if (!_paymentService.validateCVV(value, _cardType)) {
                        return 'Inválido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        
        // Nombre del titular
        _buildLabel('Nombre en la Tarjeta'),
        TextFormField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.characters,
          style: TextStyle(color: Colors.white, fontSize: 16),
          decoration: _buildInputDecoration(
            hint: 'JUAN PÉREZ',
            icon: Icons.person,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingrese nombre del titular';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white30),
      prefixIcon: Icon(icon, color: Colors.white54),
      suffixIcon: suffix != null ? Padding(
        padding: const EdgeInsets.all(12.0),
        child: suffix,
      ) : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.greenAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
  
  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Procesando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
                'Pagar \$${widget.skin.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
  
  Widget _buildSecurityNote() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.greenAccent, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pago 100% seguro. Tu información está protegida.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Formateador para número de tarjeta (XXXX XXXX XXXX XXXX)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Formateador para fecha de expiración (MM/AA)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length >= 2) {
      final month = text.substring(0, 2);
      final year = text.length > 2 ? text.substring(2) : '';
      
      final formatted = year.isEmpty ? month : '$month/$year';
      
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return newValue;
  }
}

