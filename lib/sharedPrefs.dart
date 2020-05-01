import 'package:shared_preferences/shared_preferences.dart';

class Setting {
  double iso;
  double aperture;
  String speed;

  Setting(this.iso, this.aperture, this.speed);
}

class SharedPrefs {
  static final String _isoPrefs = "isoValue";
  static final String _settingsPrefs = "savedSettings";

  static Future<double> getIsoValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    return prefs.getDouble(_isoPrefs) ?? 200.0;
  }

  static Future<bool> setIsoValue(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setDouble(_isoPrefs, value);
  }

  static Future<List> getSavedSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("SHAREDPREFT - getSavedSettings");
    var a = prefs.getStringList(_settingsPrefs) ?? false;
    print("SHAREDPREFT - getSavedSettings ${a}");
    return a;
  }

  static Future<bool> addSavedSettings(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> settingsList =
        prefs.getStringList(_settingsPrefs) ?? List<String>();
    print("LLLLLLLLLLLLLL");
    print(settingsList);
    List<String> newList = [];
    newList = settingsList;
    //settingsList.map((_) => newList.add(_));
    print(newList);
    newList.add(value);
    return prefs.setStringList(_settingsPrefs, newList);
  }

  static Future<bool> deleteSettings(String time) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> settingsList =
        prefs.getStringList(_settingsPrefs) ?? List<String>();
    List<String> newList = [];

    for (var setting in settingsList) {
      if (!setting.contains(time)) {
        newList.add(setting);
      }
    }
    return prefs.setStringList(_settingsPrefs, newList);
  }

  static Future<bool> deleteAllSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_settingsPrefs, []);
  }

  static Future<bool> updateSettings(String newSetting) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> settingsList =
        prefs.getStringList(_settingsPrefs) ?? List<String>();
    List<String> newList = [];
    print("new setting: ${newSetting}");
    String time = newSetting.split(";")[0];

    for (var setting in settingsList) {
      if (!setting.contains(time)) {
        newList.add(setting);
      } else {
        newList.add(newSetting);
        print("UPDATE SETTING: ${newSetting}");
      }
    }
    print("SHAREDPREFT - updateSettings");
    return prefs.setStringList(_settingsPrefs, newList);
  }
}
