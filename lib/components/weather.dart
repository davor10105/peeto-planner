import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:peeto_planner/main.dart';
import 'package:weather/weather.dart';

class WeatherView extends StatefulWidget {
  final PlannerState plannerState;
  const WeatherView({super.key, required this.plannerState});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final WeatherFactory wf =
      new WeatherFactory("da87af6a0182187d455aa63ef9a8d4de");

  Future<List<Weather>>? currentForecast;

  @override
  void initState() {
    currentForecast = getForecast();
    super.initState();
  }

  Future<List<Weather>> getForecast() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    return await wf.fiveDayForecastByLocation(
        position.latitude, position.longitude);
  }

  bool isSameDate(DateTime today, DateTime other) {
    return today.year == other.year &&
        today.month == other.month &&
        today.day == other.day;
  }

  List<List<Weather>> sortForecastByDate(List<Weather> forecast) {
    List<List<Weather>> sortedWeather = [];
    List<Weather> currentDayWeather = [];
    DateTime today = forecast.first.date!;
    for (Weather weather in forecast) {
      if (isSameDate(weather.date!, today)) {
        currentDayWeather.add(weather);
      } else {
        sortedWeather.add(currentDayWeather);
        today = weather.date!;
        currentDayWeather = [weather];
      }
    }
    if (currentDayWeather.isNotEmpty) {
      sortedWeather.add(currentDayWeather);
    }

    return sortedWeather;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: currentForecast,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<List<Weather>> sortedWeather =
                sortForecastByDate(snapshot.data!);
            return ListView.builder(
              itemCount: sortedWeather.length,
              itemBuilder: (BuildContext context, int index) {
                return ExpansionTile(
                  title: Text(sortedWeather[index].first.weatherDescription!),
                  subtitle: Text(sortedWeather[index].first.date.toString()),
                  children: [
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Text('MIU'),
                          Text('GRAF'),
                          Text('IC'),
                        ],
                      ),
                    )
                  ],
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Please enable location services');
          } else {
            return Text('KITA');
          }
        });
  }
}
