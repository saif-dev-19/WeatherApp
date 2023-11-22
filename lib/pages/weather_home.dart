import 'package:day12/pages/settings.dart';
import 'package:day12/providers/weather_provider.dart';
import 'package:day12/utils/constants.dart';
import 'package:day12/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  @override
  void didChangeDependencies() {
    Provider.of<WeatherProvider>(context, listen: false).getData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showSearch(
                  context: context, delegate: _CitySearchDelegate()) as String;
              if (result.isNotEmpty) {
                EasyLoading.show(status: 'Please wait');
                final status =
                    await Provider.of<WeatherProvider>(context, listen: false)
                        .convertCityToLatLng(result);
                EasyLoading.dismiss();
                if (status == LocationConversionStatus.failed) {
                  showMsg(context, 'Could not find data');
                }
              }
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<WeatherProvider>(
          builder: (context, provider, child) {
            return provider.hasDataLoaded
                ? Stack(
                    children: [
                      Image.network(
                        backgroundImage,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _currentWeatherSection(provider, context),
                            _forecastWeatherSection(provider, context),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
      ),
    );
  }

  Widget _currentWeatherSection(
      WeatherProvider provider, BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80,),
        Text(
          getFormattedDateTime(provider.currentWeather!.dt!),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          '${provider.currentWeather!.name}, ${provider.currentWeather!.sys!.country}',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                  '$iconUrlPrefix${provider.currentWeather!.weather![0].icon}$iconUrlSuffix'),
              TweenAnimationBuilder(
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                tween: IntTween(begin: 0, end: provider.currentWeather!.main!.temp!.toInt()),
                builder: (context, value, child) => Text(
                  '$value$degree${provider.unitSymbol}',
                  style: const TextStyle(
                    fontSize: 80,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'feels like: ${provider.currentWeather!.main!.feelsLike!.toStringAsFixed(0)}$degree$celsius',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        Text(
          provider.currentWeather!.weather![0].description!,
          style: const TextStyle(
            fontSize: 25,
          ),
        ),
      ],
    );
  }

  Widget _forecastWeatherSection(
      WeatherProvider provider, BuildContext context) {
    final forecastItemList = provider.forecastWeather!.list!;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastItemList.length,
        itemBuilder: (context, index) {
          final item = forecastItemList[index];
          return Card(
            color: Colors.blue.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(getFormattedDateTime(item.dt!, pattern: 'EEE HH:mm')),
                  Image.network(
                      '$iconUrlPrefix${item.weather![0].icon}$iconUrlSuffix'),
                  Text(
                      '${item.main!.tempMax!.toStringAsFixed(0)}/${item.main!.tempMin!.toStringAsFixed(0)}$degree${provider.unitSymbol}'),
                  Text(item.weather![0].description!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, query);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: () {
        close(context, query);
      },
      title: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? cities
        : cities
            .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = filteredList[index];
          close(context, query);
        },
        title: Text(filteredList[index]),
      ),
    );
  }
}
