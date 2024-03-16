import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countries of the World',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Country> countries = [];
  List<Country> filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  void _fetchCountries() async {
    final response =
        await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

    if (response.statusCode == 200) {
      final List<dynamic> countriesJson = jsonDecode(response.body);

      setState(() {
        countries = countriesJson
            .map((countryJson) => Country.fromJson(countryJson))
            .toList();
        filteredCountries =
            List.from(countries); // Copy countries to filteredCountries
        filteredCountries.sort((a, b) => a.name.compareTo(b.name));
      });
    } else {
      // Handle error
    }
  }

  void showCountryDetails(BuildContext context, Country country) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(country.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Capital: ${country.capital}'),
                Text('Population: ${country.population.toString()}'),
                Text('Currency: ${country.currencyCode}'), // แสดงหน่วยเงิน
                SizedBox(height: 20),
                country.flagUrl != null
                    ? Image.network(
                        country.flagUrl!,
                        height: 100,
                        width: 150,
                      )
                    : Container(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Countries of the World'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Countries',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  filteredCountries = countries
                      .where((country) => country.name
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                final country = filteredCountries[index];

                return ListTile(
                  title: Text(country.name),
                  subtitle: country.abbr != null
                      ? Text(country.abbr!)
                      : SizedBox.shrink(),
                  trailing: country.flagUrl != null
                      ? Image.network(
                          country.flagUrl!,
                          height: 50.0,
                          width: 50.0,
                        )
                      : null,
                  onTap: () => showCountryDetails(context, country),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Country {
  final String name;
  final String capital;
  final int population;
  final String? abbr;
  final String? flagUrl;
  final String? currencyCode;
  final LatLng? latLng; // เพิ่มฟิลด์เก็บพิกัดละติจูดและลองจิจูด

  Country({
    required this.name,
    required this.capital,
    required this.population,
    this.abbr,
    this.flagUrl,
    required this.currencyCode,
    this.latLng, 
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'],
      capital: json['capital'] != null ? json['capital'][0] : 'N/A',
      population: json['population'] != null ? json['population'] : 0,
      abbr: json['cca2'],
      flagUrl: json['flags'] != null ? json['flags']['png'] : null,
      currencyCode: json['currencies'] != null
          ? json['currencies'].values.first['name']
          : 'N/A',
      latLng: json['latlng'] != null
          ? LatLng(json['latlng'][0], json['latlng'][1])
          : null, // ดึงข้อมูลพิกัดละติจูดและลองจิจูดจาก JSON แล้วสร้าง LatLng object
    );
  }
}