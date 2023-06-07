import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:untitled/page/edit_cep.dart';

class CEPScreen extends StatefulWidget {
  @override
  _CEPScreenState createState() => _CEPScreenState();
}

class _CEPScreenState extends State<CEPScreen> {
  List<dynamic> cepList = [];

  @override
  void initState() {
    super.initState();
    fetchCEPData();
  }

  Future<void> fetchCEPData() async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Parse-Application-Id': '7nrcVlVgXcaLbKQfxz1sgpEqeeqGKcnJh22vGSq3',
      'X-Parse-REST-API-Key': 'MhJpnmwzNEpBjJhVf94jJC4t9OdZabAhxExgCXRG',
    };

    final response = await http.get(
      Uri.parse('https://parseapi.back4app.com/classes/cep'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cepList = data['results'];
      });
    } else {
      print('Erro ao buscar os dados do CEP: ${response.statusCode}');
    }
  }
  Future<void> deleteCEP(String objectId) async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Parse-Application-Id': '7nrcVlVgXcaLbKQfxz1sgpEqeeqGKcnJh22vGSq3',
      'X-Parse-REST-API-Key': 'MhJpnmwzNEpBjJhVf94jJC4t9OdZabAhxExgCXRG',
    };

    try {
      final response = await http.delete(
        Uri.parse('https://parseapi.back4app.com/classes/cep/$objectId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          cepList.removeWhere((cepData) => cepData['objectId'] == objectId);
        });
      } else {
        print('Erro ao excluir o CEP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição HTTP: $e');
    }
  }



  @override

  Widget build(BuildContext context) {
    fetchCEPData();
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de CEPs'),
      ),
      body: ListView.builder(
        itemCount: cepList.length,
        itemBuilder: (context, index) {
          final cepData = cepList[index];
          final String logradouro = cepData['logradouro'];
          final String bairro = cepData['bairro'];
          final String localidade = cepData['localidade'];
          final String uf = cepData['uf'];
          final String cep = cepData['cep'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logradouro: $logradouro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Bairro: $bairro'),
                    Text('Localidade: $localidade'),
                    Text('UF: $uf'),
                    SizedBox(height: 8),
                    Text(
                      'CEP: $cep',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCep(cepId: cepData['objectId']),
                              ),
                            );                          },
                          child: Text('Editar'),
                        ),
                        SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  deleteCEP(cepData['objectId']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cep excluído com sucesso'),
                    ),
                  );
                },
                child: Text('Excluir'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
              ),


                      ],
                    ),
                  ],

                ),

              ),
            ),
          );
        },
      ),
    );
  }
}

