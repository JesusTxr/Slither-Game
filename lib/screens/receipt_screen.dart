import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shop_skin.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> paymentData;
  final ShopSkin skin;
  
  const ReceiptScreen({
    Key? key,
    required this.paymentData,
    required this.skin,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(paymentData['created_at']);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
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
              // Header con checkmark animado
              _buildHeader(context),
              
              // Comprobante
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Ticket de comprobante
                      _buildReceipt(dateFormat.format(createdAt)),
                      SizedBox(height: 30),
                      
                      // Botones de acción
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          // Checkmark animado
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.greenAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          
          // Texto de éxito
          Text(
            '¡Pago Exitoso!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tu skin ha sido desbloqueada',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReceipt(String formattedDate) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del comprobante
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.white, size: 30),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COMPROBANTE DE COMPRA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Slither Game Store',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Línea punteada
          _buildDashedLine(),
          
          // Detalles del producto
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Producto
                _buildInfoRow('Producto', '${skin.emoji} ${skin.name}'),
                SizedBox(height: 12),
                _buildInfoRow('Categoría', 'Skin ${skin.rarity}'),
                SizedBox(height: 12),
                Divider(color: Colors.grey.shade300),
                SizedBox(height: 12),
                
                // Información de pago
                _buildInfoRow('Nº Comprobante', paymentData['numero_comprobante']),
                SizedBox(height: 12),
                _buildInfoRow('Fecha', formattedDate),
                SizedBox(height: 12),
                _buildInfoRow('Método de Pago', '${paymentData['tipo_tarjeta']} ****${paymentData['ultimos_4_digitos']}'),
                SizedBox(height: 12),
                _buildInfoRow('Titular', paymentData['nombre_titular']),
                SizedBox(height: 12),
                _buildInfoRow('Estado', 
                  paymentData['estado'] == 'completado' ? '✅ Completado' : paymentData['estado'],
                  valueColor: Colors.green.shade700,
                ),
                SizedBox(height: 12),
                Divider(color: Colors.grey.shade300, thickness: 2),
                SizedBox(height: 12),
                
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${paymentData['precio'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Línea punteada
          _buildDashedLine(),
          
          // Footer con preview de la skin
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Tu nueva skin',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        skin.skin.secondaryColor,
                        skin.skin.primaryColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: skin.skin.primaryColor.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDashedLine() {
    return Container(
      height: 1,
      child: CustomPaint(
        painter: DashedLinePainter(),
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Botón: Usar skin ahora
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              // Volver a la tienda y seleccionar la skin
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: Icon(Icons.check_circle_outline, size: 24),
            label: Text(
              'Usar Skin Ahora',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
          ),
        ),
        SizedBox(height: 15),
        
        // Botón: Volver a la tienda
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.store, size: 24),
            label: Text(
              'Volver a la Tienda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.5), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Painter para línea punteada
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    
    const dashWidth = 5;
    const dashSpace = 5;
    double startX = 0;
    
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

