import 'dart:convert';

import 'package:buscador_de_giphys/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;
  //-> _offset é a quantidade dá proxima remeça de gifs tragos da Api.
  //-> Obs: Isso é uma regra de entrega de dados da própia Api.
  @override
  _getGif() async {
    //-> As funçoes de requisição são assincronas.
    http.Response _response;

    if (_search == null || _search.isEmpty) {
      _response = await http.get(
          'https://api.giphy.com/v1/gifs/trending?api_key=d8Xj1UlXK8MVGVfigzatsVVO2rGSh8lO&limit=20&rating=G');
    } else {
      _response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=d8Xj1UlXK8MVGVfigzatsVVO2rGSh8lO&q=$_search&limit=19&offset=$_offset&rating=G&lang=pt');
    }
    return json.decode(_response.body);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      //-> Obs: Fica entre appBar e body. O background é aplicado ao corpo da aplicação e não está declarado no própio body.
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Pesquise aqui',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                //-> Esse text  é o texto em forma de string digitado pelo usuário.
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
              //-> Pega o que foi digitado dps que o usuário para de difitar e clica em ok do teclado nativo do sistema.
            ),
          ),
          Expanded(
            child: FutureBuilder(
              //-> Vai receber dados que virão no futuro.
              future: _getGif(),
              //-> declara o future que serar recebido.
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Container(
                      alignment: Alignment.center,
                      //-> Os itens alinhado no centro faz com que o circulo animado declarado a abaixofique pequeo e no tamanho certo.
                      child: CircularProgressIndicator(
                        //-> É um widget que coloca um circulo animado na tela
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        //-> Significa que está com uma cor no CircularProgressIndicator e essa cor animada não vai mudar.
                        //-> Essa cor pode ir mudando.
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Sem internet...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
      //retrona tamanho do array de gifs.
    } else {
      return data.length + 1;
      //-> Uma vaga na contagem sem gif.
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data['data']), // conta os 20 ou 19 (+1).
      // "napshot.data['data']" -> Esta sendo passada uma lsita para o metodo "_getCount" acessar a o length dessa lista e retorna o resultado da regra.
      itemBuilder: (context, index) {
        //index é própio do Widgt. O elemnto serar colocado no indece de cada Widget.
        if (_search == null || index < snapshot.data['data'].length) {
          //Quando for 19, que é o quantidade declarada na Url, a vigésima (vaga na contagem sem gif) será rendereisada no 'else' em seguida.
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              //-> Tipo de widget que faz a imagem ser apresentada de forma mais 'suave'.
              placeholder: kTransparentImage,
              //-> Uma imagem que vica 'por tras' da imgaem que sera carregada.
              //-> 'kTransparentImage' ->  É uma miagem tranparende de uma biblioteca instalada.
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (contex) => GifPage(
                    snapshot.data['data'][index],
                  ),
                ),
              );
            },
            onLongPress: () {
              Share.share(
                snapshot.data['data'][index]['images']['fixed_height']['url'],
              );
            },
          );
        } else {
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add, color: Colors.white, size: 70.0),
                Text(
                  'Carregar mais...',
                  style: TextStyle(color: Colors.white, fontSize: 22.0),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _offset += 19;
                //-> Vai passar na Url para que a api traga os próximos 19.
                //Obs: lembrando que se inicia com 0, pois indica que seram tragos os primeiros 19 que a Api trouxer.
              });
            },
          );
        }
      },
    );
  }
}
