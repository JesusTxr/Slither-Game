import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/snake_skins.dart';
import '../models/shop_skin.dart';
import '../services/payment_service.dart';
import 'payment_screen.dart';

class SkinShopScreen extends StatefulWidget {
  const SkinShopScreen({Key? key}) : super(key: key);

  @override
  State<SkinShopScreen> createState() => _SkinShopScreenState();
}

class _SkinShopScreenState extends State<SkinShopScreen> with SingleTickerProviderStateMixin {
  String _selectedSkinId = 'classic';
  final _paymentService = PaymentService();
  List<String> _purchasedSkins = [];
  bool _isLoading = true;
  late TabController _tabController;
  
  // Filtros
  String _selectedRarity = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _loadSelectedSkin();
    await _loadPurchasedSkins();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSelectedSkin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSkinId = prefs.getString('selected_skin') ?? 'classic';
    });
  }

  Future<void> _loadPurchasedSkins() async {
    final skins = await _paymentService.getPurchasedSkins();
    setState(() {
      _purchasedSkins = skins;
    });
  }

  Future<void> _selectSkin(ShopSkin skin) async {
    // Verificar si es gratis o ya la compró
    final canUse = skin.isFree || _purchasedSkins.contains(skin.id);
    
    if (!canUse) {
      // Mostrar diálogo de compra
      _showPurchaseDialog(skin);
      return;
    }
    
    // Seleccionar la skin
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_skin', skin.id);
    setState(() {
      _selectedSkinId = skin.id;
    });
    
    // Mostrar mensaje de confirmación con haptic feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '✅ ${skin.name} equipada',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  void _showPurchaseDialog(ShopSkin skin) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40), // Más espacio
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(skin.rarityColor).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: SingleChildScrollView( // ⚡ SCROLLABLE para evitar overflow
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono de la skin (más pequeño)
                Container(
                  width: 80, // 100 → 80
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
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      skin.emoji,
                      style: TextStyle(fontSize: 40), // 50 → 40
                    ),
                  ),
                ),
                SizedBox(height: 16), // 20 → 16
                
                // Nombre
                Text(
                  skin.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // 24 → 22
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6), // 8 → 6
                
                // Badge de rareza
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(skin.rarityColor).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(skin.rarityColor),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    skin.rarity.toUpperCase(),
                    style: TextStyle(
                      color: Color(skin.rarityColor),
                      fontSize: 11, // 12 → 11
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: 18), // 24 → 18
                
                // Precio
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_money, color: Colors.greenAccent, size: 28), // 32 → 28
                      Text(
                        '${skin.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 28, // 32 → 28
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20), // 24 → 20
                
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14), // 16 → 14
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white30),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15, // 16 → 15
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // 12 → 10
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(skin: skin),
                            ),
                          ).then((_) => _loadData());
                        },
                        icon: Icon(Icons.shopping_cart, size: 18), // 20 → 18
                        label: Text(
                          'Comprar',
                          style: TextStyle(
                            fontSize: 15, // 16 → 15
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 14), // 16 → 14
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ShopSkin> _getFilteredSkins() {
    if (_selectedRarity == 'all') {
      return SkinCatalog.allSkins;
    }
    return SkinCatalog.getSkinsByRarity(_selectedRarity);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'Cargando tienda...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
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
              // Header mejorado
              _buildEnhancedHeader(),
              
              // Tabs de filtros
              _buildFilterTabs(),
              
              // Grid de skins (MÁS compacto: 3 columnas)
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columnas
                    childAspectRatio: 0.68, // MÁS compacto (0.72 → 0.68)
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: _getFilteredSkins().length,
                  itemBuilder: (context, index) {
                    final skin = _getFilteredSkins()[index];
                    final isSelected = skin.id == _selectedSkinId;
                    final isPurchased = skin.isFree || _purchasedSkins.contains(skin.id);
                    
                    return _buildEnhancedSkinCard(skin, isSelected, isPurchased);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    final totalSkins = SkinCatalog.allSkins.length;
    final ownedSkins = _purchasedSkins.length + 1; // +1 por la gratis
    
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), // Menos padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '🎨 ',
                          style: TextStyle(fontSize: 24),
                        ),
                        Text(
                          'Tienda de Skins',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, color: Colors.greenAccent, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '$ownedSkins/$totalSkins skins',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.verified, color: Colors.blue.shade300, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '${((ownedSkins / totalSkins) * 100).toStringAsFixed(0)}% completado',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 42, // 48 → 42 (más compacto)
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Menos padding
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Todas', 'all', Icons.grid_view),
          _buildFilterChip('Legendarias', 'legendary', Icons.star, color: Color(0xFFFFD700)),
          _buildFilterChip('Épicas', 'epic', Icons.auto_awesome, color: Color(0xFFAA00FF)),
          _buildFilterChip('Raras', 'rare', Icons.diamond, color: Color(0xFF0099FF)),
          _buildFilterChip('Comunes', 'common', Icons.circle, color: Color(0xFF666666)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, {Color? color}) {
    final isSelected = _selectedRarity == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 16, 
              color: isSelected 
                  ? Colors.black87 
                  : (color ?? Colors.white70),
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedRarity = value;
          });
        },
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: color ?? Colors.greenAccent,
        checkmarkColor: Colors.black87,
        side: BorderSide(
          color: isSelected 
              ? (color ?? Colors.greenAccent)
              : Colors.white.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildEnhancedSkinCard(ShopSkin skin, bool isSelected, bool isPurchased) {
    return GestureDetector(
      onTap: () => _selectSkin(skin),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    Colors.greenAccent.withOpacity(0.3),
                    Colors.greenAccent.withOpacity(0.1),
                  ]
                : [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Colors.greenAccent 
                : (isPurchased 
                    ? Colors.white.withOpacity(0.2) 
                    : Color(skin.rarityColor).withOpacity(0.4)),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Contenido principal
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji (más pequeño)
                Text(
                  skin.emoji,
                  style: TextStyle(fontSize: 24), // 28 → 24
                ),
                SizedBox(height: 3), // 4 → 3
                
                // Preview del color (más pequeño)
                Container(
                  width: 36, // 42 → 36
                  height: 36,
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
                        color: skin.skin.primaryColor.withOpacity(0.4),
                        blurRadius: 6, // 8 → 6
                        spreadRadius: 0.5, // 1 → 0.5
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5), // 6 → 5
                
                // Nombre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3), // 4 → 3
                  child: Text(
                    skin.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11, // 12 → 11
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 3), // 4 → 3
                
                // Estado/Precio
                if (isSelected)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 12, color: Colors.black87),
                        SizedBox(width: 2),
                        Text(
                          'EN USO',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (skin.isFree)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.greenAccent, width: 1),
                    ),
                    child: Text(
                      'GRATIS',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isPurchased)
                  Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 18,
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, color: Colors.white54, size: 11),
                      SizedBox(width: 3),
                      Text(
                        '\$${skin.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            
            // Badge de rareza (esquina superior derecha - más pequeño)
            if (!skin.isFree)
              Positioned(
                top: 4, // 6 → 4
                right: 4, // 6 → 4
                child: Container(
                  padding: EdgeInsets.all(3), // 4 → 3
                  decoration: BoxDecoration(
                    color: Color(skin.rarityColor).withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(skin.rarityColor).withOpacity(0.4),
                        blurRadius: 4, // 6 → 4
                        spreadRadius: 0.5, // 1 → 0.5
                      ),
                    ],
                  ),
                  child: Icon(
                    _getRarityIcon(skin.rarity),
                    size: 8, // 10 → 8
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getRarityIcon(String rarity) {
    switch (rarity) {
      case 'legendary':
        return Icons.star;
      case 'epic':
        return Icons.auto_awesome;
      case 'rare':
        return Icons.diamond;
      default:
        return Icons.circle;
    }
  }
}

