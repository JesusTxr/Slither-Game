import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/snake_skins.dart';

class SkinShopScreen extends StatefulWidget {
  const SkinShopScreen({Key? key}) : super(key: key);

  @override
  State<SkinShopScreen> createState() => _SkinShopScreenState();
}

class _SkinShopScreenState extends State<SkinShopScreen> {
  String _selectedSkinId = 'classic';
  
  // Lista de todas las skins disponibles
  final List<Map<String, dynamic>> _availableSkins = [
    {'id': 'classic', 'skin': SnakeSkins.classic, 'name': 'Clásico', 'emoji': '🐍'},
    {'id': 'fire', 'skin': SnakeSkins.fire, 'name': 'Fuego', 'emoji': '🔥'},
    {'id': 'ocean', 'skin': SnakeSkins.ocean, 'name': 'Océano', 'emoji': '🌊'},
    {'id': 'toxic', 'skin': SnakeSkins.toxic, 'name': 'Tóxico', 'emoji': '☢️'},
    {'id': 'golden', 'skin': SnakeSkins.golden, 'name': 'Dorado', 'emoji': '👑'},
    {'id': 'shadow', 'skin': SnakeSkins.shadow, 'name': 'Sombra', 'emoji': '🌑'},
    {'id': 'rainbow', 'skin': SnakeSkins.rainbow, 'name': 'Arcoíris', 'emoji': '🌈'},
    {'id': 'candy', 'skin': SnakeSkins.candy, 'name': 'Dulce', 'emoji': '🍭'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedSkin();
  }

  Future<void> _loadSelectedSkin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSkinId = prefs.getString('selected_skin') ?? 'classic';
    });
  }

  Future<void> _saveSkin(String skinId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_skin', skinId);
    setState(() {
      _selectedSkinId = skinId;
    });
    
    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Skin seleccionada: ${_availableSkins.firstWhere((s) => s['id'] == skinId)['name']}'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '🎨 Tienda de Skins',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Grid de skins
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _availableSkins.length,
                  itemBuilder: (context, index) {
                    final skinData = _availableSkins[index];
                    final isSelected = skinData['id'] == _selectedSkinId;
                    
                    return _buildSkinCard(
                      skinData['id'],
                      skinData['skin'],
                      skinData['name'],
                      skinData['emoji'],
                      isSelected,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkinCard(String id, SnakeSkin skin, String name, String emoji, bool isSelected) {
    return GestureDetector(
      onTap: () => _saveSkin(id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.white.withOpacity(0.3),
            width: isSelected ? 4 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji
            Text(
              emoji,
              style: TextStyle(fontSize: 50),
            ),
            SizedBox(height: 10),
            
            // Preview del color
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    skin.secondaryColor,
                    skin.primaryColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: skin.primaryColor.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: skin.eyeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            
            // Nombre
            Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            
            // Estado
            if (isSelected)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✓ Seleccionada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: () => _saveSkin(id),
                child: Text(
                  'Seleccionar',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

