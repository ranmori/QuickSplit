
import 'package:shared_preferences/shared_preferences.dart';

class GroupService {
  static const String _key = 'recent_people';

  // Save a name to the recent list
  Future<void> savePerson(String name) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recents = prefs.getStringList(_key) ?? [];
    
    // Add if new, move to front if exists
    recents.remove(name);
    recents.insert(0, name);
    
    // Keep only the last 10 people
    if (recents.length > 10) recents = recents.sublist(0, 10);
    
    await prefs.setStringList(_key, recents);
  }

  // Get the list of recent people
  Future<List<String>> getRecentPeople() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}