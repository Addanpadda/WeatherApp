import 'package:WeatherApp/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String countrySharedPreferencesKey = 'country_key';
const String defaultCountry = 'Sweden';
const String citySharedPreferencesKey = 'city_key';
const String defaultCity = 'Stockholm';
Settings settings = Settings();
Location location;

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidget createState() => _SettingsWidget();
}

class _SettingsWidget extends State<SettingsWidget> {
  static const String title = 'Settings';

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController _countryTextFieldEditingController;
  TextEditingController _cityTextFieldEditingController;

  saveLocationSettings() {
    if (kIsWeb) {
      location = Location(
          country: _countryTextFieldEditingController.text,
          city: _cityTextFieldEditingController.text);
    }
    _prefs.then((SharedPreferences prefs) {
      prefs.setString(
          countrySharedPreferencesKey, _countryTextFieldEditingController.text);
      prefs.setString(
          citySharedPreferencesKey, _cityTextFieldEditingController.text);
    });
  }

  getLocationSetting() async {
    location = await settings.getLocationSetting();

    _countryTextFieldEditingController.text = location.country;
    _cityTextFieldEditingController.text = location.city;
    setState(() {});
  }

  @override
  void initState() {
    _countryTextFieldEditingController = TextEditingController();
    _cityTextFieldEditingController = TextEditingController();
    getLocationSetting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
                child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 40, horizontal: 100),
                    child: TextField(
                      controller: _countryTextFieldEditingController,
                      decoration:
                          InputDecoration(labelText: 'Country (Optional)'),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 100),
                    child: TextField(
                      controller: _cityTextFieldEditingController,
                      decoration: InputDecoration(labelText: 'City'),
                    ),
                  ),
                ],
              ),
            )),
            Container(
              margin: EdgeInsets.symmetric(vertical: 50),
              child: FlatButton(
                onPressed: () => saveLocationSettings(),
                child: Text(
                  'Save',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                color: Colors.blue,
              ),
            ),
          ],
        ));
  }
}

class Settings {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Location> _getLocationSettingFromMobile() async {
    return _prefs.then((SharedPreferences prefs) {
      return Location(
          country:
              prefs.getString(countrySharedPreferencesKey) ?? defaultCountry,
          city: prefs.getString(citySharedPreferencesKey) ?? defaultCity);
    });
  }

  Location _getLocationSettingFromWeb() {
    if (location == null) {
      return Location(country: defaultCountry, city: defaultCity);
    } else {
      return location;
    }
  }

  Future<Location> getLocationSetting() async {
    if (kIsWeb) {
      return _getLocationSettingFromWeb();
    } else {
      return await _getLocationSettingFromMobile();
    }
  }
}
