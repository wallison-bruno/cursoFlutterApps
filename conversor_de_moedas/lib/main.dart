import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
// requisição assincrona, para não "reavar" o app.

const request = 'https://api.hgbrasil.com/finance?format=jason&key=	8fe0dfb9';
// request ->  Tem o os dados da Api com os valores baseados em rais, logo o valor de compra é com é em Real
void main() async {
  // print(await getData()); -> Para printar o Mapa que o metodo retorna
  // o "await" é importante para dizer que vai esperar um dado vim no futuro

  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        // hintColor: Colors.amber,
        // primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          hintStyle: TextStyle(color: Colors.amber),
          //-> Cor do Prefix do bildTextField
        ),
      ),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realControler = TextEditingController();
  final euroControler = TextEditingController();
  final dolarControler = TextEditingController();

  // TextEditingController(); -> Pega o que é passado pelo campo do textField

  double euro_Api;
  double dolar_Api;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    } else {
      double real = double.parse(text);
      euroControler.text = (real / euro_Api).toStringAsFixed(2);
      dolarControler.text = (real / dolar_Api).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    } else {
      double euro = double.parse(text);
      realControler.text = (euro * euro_Api).toStringAsFixed(2);
      dolarControler.text = (euro * euro_Api / dolar_Api).toStringAsFixed(2);
    }
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    } else {
      double dolar = double.parse(text);
      realControler.text = (dolar * dolar_Api).toStringAsFixed(2);
      euroControler.text = (dolar * dolar_Api / euro_Api).toStringAsFixed(2);
    }
  }
  //O caratere passado no input do 'TextField" entra como parametro nessa função e a mesma é executada

  void _clearAll() {
    realControler.text = '';
    euroControler.text = '';
    dolarControler.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '\$Conversor\$',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: _getData(),
        builder: (context, snapshot) {
          // snapshot -> entraga ao app como os dasdos estao entragados no momento
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              // Se "Não está conectanto ainda" ou "Está esperando dados" retorna o code. abaixo
              return Center(
                child: Text(
                  'Carregando Dados...',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                ),
              );

            default:
              if (snapshot.hasError) {
                //-> hasErro é quando da um erro de conexão de internet
                return Center(
                  child: Text(
                    'Precisamos de que você esteja\n conectado a internet!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                  ),
                );
              } else {
                euro_Api = snapshot.data['results']['currencies']['EUR']['buy'];
                dolar_Api =
                    snapshot.data['results']['currencies']['USD']['buy'];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // stretch cobre todo espaço da coluna, tudo fica centralisado
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      bildTextField(
                          'Reais', 'R\$', realControler, _realChanged),
                      Divider(),
                      bildTextField('Euro', '€', euroControler, _euroChanged),
                      Divider(),
                      bildTextField(
                          'Dolares', 'US\$', dolarControler, _dolarChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

bildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    controller: c,
    onChanged: f,
    //onChanged: f -> Executa afunção passada no parametro f doda vez que digitado algum caractere
    keyboardType: TextInputType.number,
  );
}

Future<Map> _getData() async {
  // Future<Map> -> É pra dizer que vai retornado um mapa no 'futuro'.

  http.Response response = await http.get(request);

  //print(response.body); // -> printa o recebimento da requisição
  //http.get(request) //-> solicitando os dados
  //await -> esperando o dado chegar
  //async ->  Tem que declara que a função 'main()' é assincrona

  return json.decode(response.body);

  //'.body' -> corpo da nossa respota
  //json.decode(response.body); -> tranforma em um map
}
