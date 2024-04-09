
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
      title: 'Foreign currency trading',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: Icon(Icons.monetization_on, size: 150, color: Color.fromARGB(255, 245, 46, 112)),
            ),
            SizedBox(height: 20),
            Text(
              'C U R R E N T R A D',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 245, 46, 112)),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefixIcon: Icon(Icons.key),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 245, 46, 112),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            List.from(countries);
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
                Text('Currency: ${country.currencyCode}'),
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
              onPressed: () {
                Navigator.pop(context);
                _navigateToCurrencyExchangePage(context, country);
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 245, 46, 112), // เปลี่ยนสีพื้นหลังของปุ่ม
              ),
              child: Text(
                'Exchange Currency',
                style: TextStyle(color: Colors.white), // เปลี่ยนสีของข้อความในปุ่ม
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 245, 46, 112), // เปลี่ยนสีพื้นหลังของปุ่ม
              ),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.white), // เปลี่ยนสีของข้อความในปุ่ม
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCurrencyExchangePage(BuildContext context, Country country) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencyExchangePage(country: country),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(
    'Foreign Currency Trading',
    style: TextStyle(
      color: const Color.fromARGB(255, 255, 255, 255),fontWeight: FontWeight.bold, // เปลี่ยนสีของตัวหนังสือเป็นสีดำ
    ),
  ),
  backgroundColor: Color.fromARGB(255, 245, 46, 112),
  centerTitle: true,
),
      body: Column(
        children: [
          SizedBox(height: 20),
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
  final LatLng? latLng;
  final String accountNumber; // เพิ่มฟิลด์เก็บเลขบัญชี
  final double amount; // เพิ่มฟิลด์เก็บจำนวนเงิน

  Country({
    required this.name,
    required this.capital,
    required this.population,
    this.abbr,
    this.flagUrl,
    required this.currencyCode,
    this.latLng,
    required this.accountNumber,
    required this.amount,
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
          : null,
      accountNumber: 'xxx-xx-xx135', // กำหนดเลขบัญชี
      amount: 50000.0, // กำหนดจำนวนเงิน
    );
  }
}

class CurrencyExchangePage extends StatelessWidget {
  final Country country;
  TextEditingController amountController = TextEditingController(); 
  CurrencyExchangePage({required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(
    'Currency Exchange',
    style: TextStyle(
      color: const Color.fromARGB(255, 255, 255, 255),fontWeight: FontWeight.bold, 
    ),
  ),
  backgroundColor: Color.fromARGB(255, 245, 46, 112),
  centerTitle: true,
),
      body: Center(
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            country.flagUrl != null
                ? Image.network(
                    country.flagUrl!,
                    height: 100,
                    width: 150,
                  )
                : Container(),
                SizedBox(height: 20),
            Text('Exchange currency for ${country.name}',
              style: TextStyle(fontSize: 20),),
            Text('Account number : xxx-xx-xx135'),
            Text('Name : Jirapat Pinthong'),
            SizedBox(height: 5),
            
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 20.0),
              child: TextField(
                controller: amountController, // กำหนด controller ให้กับ TextField
                keyboardType: TextInputType.number, // กำหนดให้กรอกได้เฉพาะตัวเลข
                decoration: InputDecoration(
                  hintText: 'Required amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _confirmExchange(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 245, 46, 112), // เปลี่ยนสีพื้นหลังของปุ่ม
              ),
              child: Text(
                'Next',
                style: TextStyle(color: Colors.white), // เปลี่ยนสีของข้อความในปุ่ม
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExchange(BuildContext context) {
    // ดึงจำนวนเงินที่ผู้ใช้กรอกมาใช้ในการคำนวณ
    double thaiBahtAmount = double.tryParse(amountController.text) ?? 0;
    double exchangedAmount = thaiBahtAmount * 30; // สมมติว่าอัตราแลกเปลี่ยนคือ 1 บาทไทย เท่ากับ 30 สกุลเงินประเทศนั้นๆ

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          
          content: Text(
              'Do you want to change ${thaiBahtAmount.toString()} Bath to ${exchangedAmount.toString()} ${country.currencyCode}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Perform currency exchange action here
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 245, 46, 112), // เปลี่ยนสีพื้นหลังของปุ่ม
              ),
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.white), // เปลี่ยนสีของข้อความในปุ่ม
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 245, 46, 112), // เปลี่ยนสีพื้นหลังของปุ่ม
              ),
              child: Text(
                'Cancle',
                style: TextStyle(color: Colors.white), // เปลี่ยนสีของข้อความในปุ่ม
              ),
            ),
          ],
        );
      },
    );
  }
}
