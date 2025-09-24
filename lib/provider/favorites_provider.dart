import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  List<String> _favorites = [];

  List<String> get favorites => _favorites;
  int get favoritesCount => _favorites.length;

  FavoritesProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList('favourites') ?? [];
    notifyListeners();
  }

  Future<void> addFavorite(String city) async {
    if (!_favorites.contains(city)) {
      _favorites.add(city);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String city) async {
    _favorites.remove(city);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favourites', _favorites);
  }

  bool isFavorite(String city) {
    return _favorites.contains(city);
  }
}
