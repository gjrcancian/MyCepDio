import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:untitled/page/list_cep.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/cepList': (context) => CEPScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cepController = TextEditingController();
  String _result = '';
  String endereco ="";
  String cidade ="";
  String estado ="";
  get cepSalvar => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Digite o CEP:'),
            TextField(
              controller: _cepController,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _searchCEP,
              child: Text('Buscar'),
            ),
            SizedBox(height: 20.0),
            Text("$endereco"),
            Text("$cidade  $estado"),

            Text(_result),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/');
              break;
            case 1:
              Navigator.pushNamed(context, '/cepList');
              break;

          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista de CEPs',
          ),
        ],
      ),
    );
  }

  void _searchCEP() async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Parse-Application-Id': '7nrcVlVgXcaLbKQfxz1sgpEqeeqGKcnJh22vGSq3',
      'X-Parse-REST-API-Key': 'MhJpnmwzNEpBjJhVf94jJC4t9OdZabAhxExgCXRG',
    };

    try {
      final response = await http.get(
        Uri.parse('https://parseapi.back4app.com/classes/cep?where={"cep": "${_cepController.text}"}'),
        headers: headers,
      );

      if (jsonDecode(response.body)['results'].isEmpty) {

        final viaCepResponse = await http.get(Uri.parse('https://viacep.com.br/ws/${_cepController.text}/json/'));
        final cepData = jsonDecode(viaCepResponse.body);


        final saveResponse = await http.post(
          Uri.parse('https://parseapi.back4app.com/classes/cep'),
          headers: headers,
          body: jsonEncode({
            'cep': _cepController.text,
            'logradouro': cepData['logradouro'],
            'bairro': cepData['bairro'],
            'localidade': cepData['localidade'],
            'uf': cepData['uf'],
          }),

        );

        if (saveResponse.statusCode == 201) {

            setState(() {

              endereco =  cepData['logradouro'];
              estado =   cepData['uf'];
              cidade =  cepData['localidade'];


            _result = 'CEP salvo com sucesso no banco de dados';
          });
        } else {
          setState(() {
            _result = 'Erro ao salvar CEP no banco de dados';
          });
        }
      } else {
        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            Map<String, dynamic> cepData = data['results'][0];
            setState(() {
              _result = 'Logradouro: ${cepData['logradouro']}, '
                  'Bairro: ${cepData['bairro']}, '
                  'Município: ${cepData['localidade']}, '
                  'Estado: ${cepData['uf']}';

            });
          } else {
            setState(() {
              _result = 'CEP não encontrado';
            });
          }
        } else {
          setState(() {
            _result = 'Erro ao buscar CEP: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      setState(() {
        _result = 'Erro ao buscar CEP: $e';
      });
    }
  }
}

