import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './settings.dart';

void main() {
  const String title = 'Weather App';

  runApp(MaterialApp(title: title, initialRoute: '/', routes: {
    '/': (context) => WeatherApp(),
    '/settings': (context) => SettingsWidget()
  }));
}

class WeatherApp extends StatelessWidget {
  WeatherApp({Key key}) : super(key: key);

  static const String title = 'Weather App';
  final WeatherWidget weatherWidget = WeatherWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      body: Container(
          margin: EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: weatherWidget,
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          weatherWidget._weatherWidget.updateWeatherOnWidget();
        },
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class WeatherWidget extends StatefulWidget {
  final _WeatherWidget _weatherWidget = _WeatherWidget();

  @override
  _WeatherWidget createState() => _weatherWidget;
}

class _WeatherWidget extends State<WeatherWidget> {
  OpenWeatherAPI _weatherAPI;

  Future updateWeatherOnWidget() async {
    location = await settings.getLocationSetting();

    _weatherAPI = OpenWeatherAPI(
        location: location, apiKey: 'd5a71b1e4d89e292033555f7abbfce00');

    await _weatherAPI.fetchApi();

    setState(() {});
    return Future;
  }

  @override
  void initState() {
    updateWeatherOnWidget();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_weatherAPI == null || _weatherAPI.weather == null) {
      return Column(children: [
        Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              'Loading...',
            ))
      ]);
    } else {
      return Column(children: [
        Text('${location.city}:',
            style:
                TextStyle(decoration: TextDecoration.underline, fontSize: 40)),
        SizedBox(
          height: 30,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hot_tub, color: Colors.red, size: 60),
              SizedBox(width: 15),
              Text(
                _weatherAPI.weather.temperature.celcius.toString() + '°C',
                style: Theme.of(context).textTheme.headline6,
              )
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wb_sunny,
                  color: Colors.yellow,
                  size: 60,
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  _weatherAPI.weather.description,
                  style: Theme.of(context).textTheme.headline6,
                )
              ],
            )),
        Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud,
                  color: Colors.blue,
                  size: 60,
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  _weatherAPI.weather.windSpeed.toString() + ' M/S',
                  style: Theme.of(context).textTheme.headline6,
                )
              ],
            )),
      ]);
    }
  }
}

abstract class API {
  API({this.apiKey});

  final String apiKey;
  String get apiUrl;

  dynamic fetchApi();
}

class Temperature {
  Temperature({this.exactkelvin});

  final double exactkelvin;
  double get kelvin {
    return roundOneDecimalPoint(exactkelvin);
  }

  double get celcius {
    return roundOneDecimalPoint(kelvinToCelcius(exactkelvin));
  }

  static double kelvinToCelcius(double temp) {
    return temp - 273.15;
  }

  static roundOneDecimalPoint(double val) {
    return (val * 10).toInt().toDouble() / 10;
  }
}

class Weather {
  final Temperature temperature;
  final double windSpeed;
  final String description;

  Weather({this.temperature, this.windSpeed, this.description});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
        description: json['weather'][0]['description'],
        windSpeed: json['wind']['speed'],
        temperature: Temperature(exactkelvin: json['main']['temp']));
  }
}

class Location {
  Location({this.country, this.city});

  final String country, city;
}

class OpenWeatherAPI implements API {
  OpenWeatherAPI({this.apiKey, this.location});

  final String apiKey;
  final Location location;
  String get apiUrl {
    return 'http://api.openweathermap.org/data/2.5/weather?q=${location.city},${location.country}&appid=$apiKey';
  }

  Weather weather;

  Future fetchApi() async {
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      weather = Weather.fromJson(json.decode(response.body));
      return Future;
    } else {
      throw Exception('Failed to fetch weather.');
    }
  }
}
