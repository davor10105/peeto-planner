import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:peeto_planner/main.dart';
import 'package:weather/weather.dart';

List<String> weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

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
            /*return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedWeather.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      
                    },
                  ),
                ),
              ],
            );*/
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 16.0,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(83, 0, 0, 0),
                            blurRadius: 8,
                            spreadRadius: 2),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(sortedWeather.first.first.areaName.toString()),
                          Text(
                            sortedWeather.first.first.country.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: sortedWeather.length,
                      itemBuilder: (context, index) {
                        Weather middleOfCurrentDay = sortedWeather[index]
                            [(sortedWeather[index].length / 2).floor()];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromARGB(83, 0, 0, 0),
                                    blurRadius: 8,
                                    spreadRadius: 2),
                              ],
                            ),
                            child: ExpansionTile(
                              leading: Image.asset(getWeatherImagePath(
                                  middleOfCurrentDay.weatherConditionCode!)),
                              title: Text(weekdays[
                                  middleOfCurrentDay.date!.weekday - 1]),
                              subtitle: Row(
                                children: [
                                  Text(
                                    middleOfCurrentDay.temperature!.celsius!
                                            .round()
                                            .toString() +
                                        '°',
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  Text(
                                    'Real',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Text(
                                    middleOfCurrentDay.tempFeelsLike!.celsius!
                                            .round()
                                            .toString() +
                                        '°',
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  Text(
                                    'Feel',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                              children:
                                  getSingleWeatherTiles(sortedWeather[index]),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Please enable location services',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Loading weather data...',
                  style: TextStyle(color: Colors.blueGrey),
                )
              ],
            ));
          }
        });
  }

  String getWeatherImagePath(int weatherCode) {
    String imagePath = 'lib/images/sun.gif';

    if (weatherCode >= 200 && weatherCode < 300) {
      imagePath = 'lib/images/storm.gif';
    }
    if (weatherCode >= 300 && weatherCode < 400) {
      imagePath = 'lib/images/drizzle.gif';
    }
    if (weatherCode >= 500 && weatherCode < 502) {
      imagePath = 'lib/images/light_rain.gif';
    }
    if (weatherCode >= 502 && weatherCode < 600) {
      imagePath = 'lib/images/rain.gif';
    }
    if (weatherCode >= 600 && weatherCode < 700) {
      imagePath = 'lib/images/snow.gif';
    }
    if (weatherCode >= 700 && weatherCode < 800) {
      imagePath = 'lib/images/foggy.gif';
    }
    if (weatherCode >= 700 && weatherCode < 800) {
      imagePath = 'lib/images/sun.gif';
    }
    if (weatherCode >= 800 && weatherCode < 803) {
      imagePath = 'lib/images/cloudy.gif';
    }
    if (weatherCode >= 803 && weatherCode < 900) {
      imagePath = 'lib/images/clouds.gif';
    }
    return imagePath;
  }

  List<Widget> getSingleWeatherTiles(List<Weather> dayWeathers) {
    List<Widget> weatherTiles = [];
    for (var dayWeather in dayWeathers) {
      int weatherCode = dayWeather.weatherConditionCode!;
      String imagePath = getWeatherImagePath(weatherCode);
      weatherTiles.add(Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: ListTile(
          tileColor: Colors.white,
          title: Text(dayWeather.weatherDescription!),
          leading: Image.asset(imagePath),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayWeather.date!.hour.toString() + 'h',
                style: TextStyle(fontSize: 22),
              ),
              Text(
                'Time',
                style: TextStyle(fontSize: 8, color: Colors.grey),
              ),
            ],
          ), //Text(dayWeather.temperature!.celsius!.round().toString()),
          subtitle: Row(
            children: [
              Text(
                dayWeather.temperature!.celsius!.round().toString() + '°',
                style: TextStyle(fontSize: 25),
              ),
              Text(
                'Real',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(
                width: 50,
              ),
              Text(
                dayWeather.tempFeelsLike!.celsius!.round().toString() + '°',
                style: TextStyle(fontSize: 25),
              ),
              Text(
                'Feel',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ));
    }

    return weatherTiles;
  }
}
