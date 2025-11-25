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
    
    // Obtener dimensiones de pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
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
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // 5% del ancho
              vertical: screenHeight * 0.02, // 2% del alto
            ),
            child: Column(
              children: [
                // Header con checkmark animado
                _buildHeader(context, screenHeight),
                SizedBox(height: screenHeight * 0.025), // 2.5% del alto
                
                // Ticket de comprobante
                _buildReceipt(dateFormat.format(createdAt), screenHeight, screenWidth),
                SizedBox(height: screenHeight * 0.035), // 3.5% del alto
                
                // Botones de acción
                _buildActionButtons(context, screenHeight),
                SizedBox(height: screenHeight * 0.025), // 2.5% del alto
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, double screenHeight) {
    return Column(
      children: [
        // Checkmark animado
        Container(
          width: screenHeight * 0.1, // 10% del alto
          height: screenHeight * 0.1,
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
            size: screenHeight * 0.06, // 6% del alto
            color: Colors.white,
          ),
        ),
        SizedBox(height: screenHeight * 0.025), // 2.5% del alto
        
        // Texto de éxito
        Text(
          '¡Pago Exitoso!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenHeight * 0.035, // 3.5% del alto
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.01), // 1% del alto
        Text(
          'Tu skin ha sido desbloqueada',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: screenHeight * 0.02, // 2% del alto
          ),
        ),
      ],
    );
  }
  
  Widget _buildReceipt(String formattedDate, double screenHeight, double screenWidth) {
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
            padding: EdgeInsets.all(screenHeight * 0.025), // 2.5% del alto
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
                Icon(
                  Icons.receipt_long, 
                  color: Colors.white, 
                  size: screenHeight * 0.037, // 3.7% del alto
                ),
                SizedBox(width: screenWidth * 0.04), // 4% del ancho
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COMPROBANTE DE COMPRA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.022, // 2.2% del alto
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005), // 0.5% del alto
                      Text(
                        'Slither Game Store',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenHeight * 0.015, // 1.5% del alto
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
            padding: EdgeInsets.all(screenHeight * 0.025), // 2.5% del alto
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Producto
                _buildInfoRow('Producto', '${skin.emoji} ${skin.name}', screenHeight),
                SizedBox(height: screenHeight * 0.015), // 1.5% del alto
                _buildInfoRow('Categoría', 'Skin ${skin.rarity}', screenHeight),
                SizedBox(height: screenHeight * 0.015), // 1.5% del alto
                Divider(color: Colors.grey.shade300),
                SizedBox(height: screenHeight * 0.015), // 1.5% del alto
                
                // Información de pago
                _buildInfoRow('Nº Comprobante', paymentData['numero_comprobante'], screenHeight),
                SizedBox(height: screenHeight * 0.015), // 1.5% del alto
                _buildInfoRow('Fecha', formattedDate, screenHeight),
                SizedBox(height: screenHeight * 0.015), // 1.5% del alto
                _buildInfoRow('Método de Pago', '${paymentData['tipo_tarjeta']} ****${paymentData['ultimos_4_digitos']}', screenHeight),
                SizedBox(height: screenHeight * 0.015), // 1.5% del alto
                _buildInfoRow('Titular', paymentData['nombre_titular'], screenHeight),
                SizedBox(height: screenHeight * 0.015), // 1.5% del alto
                _buildInfoRow('Estado', 
                  paymentData['estado'] == 'completado' ? '✅ Completado' : paymentData['estado'],
                  screenHeight,
                  valueColor: Colors.green.shade700,
                ),
                SizedBox(height: screenHeight * 0.015), // 1.5% del alto
                Divider(color: Colors.grey.shade300, thickness: 2),
                SizedBox(height: screenHeight * 0.015), // 1.5% del alto
                
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: screenHeight * 0.025, // 2.5% del alto
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${paymentData['precio'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: screenHeight * 0.03, // 3% del alto
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
            padding: EdgeInsets.all(screenHeight * 0.025), // 2.5% del alto
            child: Column(
              children: [
                Text(
                  'Tu nueva skin',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: screenHeight * 0.017, // 1.7% del alto
                  ),
                ),
                SizedBox(height: screenHeight * 0.018), // 1.8% del alto
                Container(
                  width: screenHeight * 0.1, // 10% del alto
                  height: screenHeight * 0.1,
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
  
  Widget _buildInfoRow(String label, String value, double screenHeight, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: screenHeight * 0.017, // 1.7% del alto
            ),
          ),
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontSize: screenHeight * 0.017, // 1.7% del alto
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
  
  Widget _buildActionButtons(BuildContext context, double screenHeight) {
    return Column(
      children: [
        // Botón: Usar skin ahora
        SizedBox(
          width: double.infinity,
          height: screenHeight * 0.07, // 7% del alto
          child: ElevatedButton.icon(
            onPressed: () {
              // Volver a la tienda y seleccionar la skin
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: Icon(
              Icons.check_circle_outline, 
              size: screenHeight * 0.03, // 3% del alto
            ),
            label: Text(
              'Usar Skin Ahora',
              style: TextStyle(
                fontSize: screenHeight * 0.022, // 2.2% del alto
                fontWeight: FontWeight.bold,
              ),
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
        SizedBox(height: screenHeight * 0.018), // 1.8% del alto
        
        // Botón: Volver a la tienda
        SizedBox(
          width: double.infinity,
          height: screenHeight * 0.07, // 7% del alto
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.store, 
              size: screenHeight * 0.03, // 3% del alto
            ),
            label: Text(
              'Volver a la Tienda',
              style: TextStyle(
                fontSize: screenHeight * 0.022, // 2.2% del alto
                fontWeight: FontWeight.bold,
              ),
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

