import '../config/snake_skins.dart';

/// 🎨 Modelo de Skin para la tienda
class ShopSkin {
  final String id;
  final String name;
  final String emoji;
  final SnakeSkin skin;
  final double price;
  final bool isFree;
  final String rarity; // common, rare, epic, legendary
  
  const ShopSkin({
    required this.id,
    required this.name,
    required this.emoji,
    required this.skin,
    required this.price,
    this.isFree = false,
    this.rarity = 'common',
  });
  
  /// Obtener color de rareza
  int get rarityColor {
    switch (rarity) {
      case 'legendary':
        return 0xFFFFD700; // Dorado
      case 'epic':
        return 0xFFAA00FF; // Morado
      case 'rare':
        return 0xFF0099FF; // Azul
      default:
        return 0xFF666666; // Gris
    }
  }
}

/// 📋 Catálogo de skins disponibles en la tienda
class SkinCatalog {
  static const List<ShopSkin> allSkins = [
    ShopSkin(
      id: 'classic',
      name: 'Clásico',
      emoji: '🐍',
      skin: SnakeSkins.classic,
      price: 0.0,
      isFree: true,
      rarity: 'common',
    ),
    ShopSkin(
      id: 'fire',
      name: 'Fuego',
      emoji: '🔥',
      skin: SnakeSkins.fire,
      price: 4.99,
      isFree: false,
      rarity: 'rare',
    ),
    ShopSkin(
      id: 'ocean',
      name: 'Océano',
      emoji: '🌊',
      skin: SnakeSkins.ocean,
      price: 3.99,
      isFree: false,
      rarity: 'rare',
    ),
    ShopSkin(
      id: 'toxic',
      name: 'Tóxico',
      emoji: '☢️',
      skin: SnakeSkins.toxic,
      price: 5.99,
      isFree: false,
      rarity: 'epic',
    ),
    ShopSkin(
      id: 'golden',
      name: 'Dorado',
      emoji: '👑',
      skin: SnakeSkins.golden,
      price: 9.99,
      isFree: false,
      rarity: 'legendary',
    ),
    ShopSkin(
      id: 'shadow',
      name: 'Sombra',
      emoji: '🌑',
      skin: SnakeSkins.shadow,
      price: 6.99,
      isFree: false,
      rarity: 'epic',
    ),
    ShopSkin(
      id: 'candy',
      name: 'Dulce',
      emoji: '🍭',
      skin: SnakeSkins.candy,
      price: 2.99,
      isFree: false,
      rarity: 'common',
    ),
    ShopSkin(
      id: 'royal',
      name: 'Real',
      emoji: '💜',
      skin: SnakeSkins.royal,
      price: 7.99,
      isFree: false,
      rarity: 'epic',
    ),
  ];
  
  /// Obtener skin por ID
  static ShopSkin? getSkinById(String id) {
    try {
      return allSkins.firstWhere((skin) => skin.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Obtener skins gratuitas
  static List<ShopSkin> get freeSkins {
    return allSkins.where((skin) => skin.isFree).toList();
  }
  
  /// Obtener skins de pago
  static List<ShopSkin> get premiumSkins {
    return allSkins.where((skin) => !skin.isFree).toList();
  }
  
  /// Obtener skins por rareza
  static List<ShopSkin> getSkinsByRarity(String rarity) {
    return allSkins.where((skin) => skin.rarity == rarity).toList();
  }
}

