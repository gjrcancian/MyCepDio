import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditCep extends StatefulWidget {
final String cepId;

EditCep({required this.cepId});

@override
_EditCepState createState() => _EditCepState();
}

class _EditCepState extends State<EditCep> {
  TextEditingController _logradouroController = TextEditingController();
  TextEditingController _bairroController = TextEditingController();
  TextEditingController _localidadeController = TextEditingController();
  TextEditingController _ufController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCepData();
  }

  Future<void> fetchCepData() async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Parse-Application-Id': '7nrcVlVgXcaLbKQfxz1sgpEqeeqGKcnJh22vGSq3',
      'X-Parse-REST-API-Key': 'MhJpnmwzNEpBjJhVf94jJC4t9OdZabAhxExgCXRG',
    };

    final response = await http.get(
      Uri.parse('https://parseapi.back4app.com/classes/cep/${widget.cepId}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _logradouroController.text = data['logradouro'];
        _bairroController.text = data['bairro'];
        _localidadeController.text = data['localidade'];
        _ufController.text = data['uf'];
      });
    } else {
      print('Erro ao buscar os dados do CEP: ${response.statusCode}');
    }
  }

  Future<void> updateCep() async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Parse-Application-Id': '7nrcVlVgXcaLbKQfxz1sgpEqeeqGKcnJh22vGSq3',
      'X-Parse-REST-API-Key': 'MhJpnmwzNEpBjJhVf94jJC4t9OdZabAhxExgCXRG',
    };

    final Map<String, dynamic> cepData = {
      'logradouro': _logradouroController.text,
      'bairro': _bairroController.text,
      'localidade': _localidadeController.text,
      'uf': _ufController.text,
    };

    try {
      final response = await http.put(
        Uri.parse('https://parseapi.back4app.com/classes/cep/${widget.cepId}'),
        headers: headers,
        body: jsonEncode(cepData),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);

      } else {
        print('Erro ao atualizar o CEP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição HTTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _logradouroController,
              decoration: InputDecoration(labelText: 'Logradouro'),
            ),
            TextField(
              controller: _bairroController,
              decoration: InputDecoration(labelText: 'Bairro'),
            ),
            TextField(
              controller: _localidadeController,
              decoration: InputDecoration(labelText: 'Localidade'),
            ),
            TextField(
              controller: _ufController,
              decoration: InputDecoration(labelText: 'UF'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateCep();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dados salvos com sucesso'),
                  ),
                );
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
