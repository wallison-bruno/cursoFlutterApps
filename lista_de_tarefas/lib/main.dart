import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class _HomeState extends State<Home> {
  final _controller = TextEditingController();
  List _toDoList = []; //-> Nessa aplicação será uma lista de mapas.
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos; //-> Para saber a posição que o item foi removido

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      // _readData() -> Retorna uma string futura e o 'then' pega essa string funtura chama uma função anônima.
      // O 'Future' poderia ser usado também desta forma => 'Future _readData()'
      setState(() {
        _toDoList = json.decode(data);
      });
    });

    /* setState(() {
      _readData().then((data) {
        _toDoList = json.decode(data);
      });
    }); */ //Não Funciona assim, o dado futuro não é eperado??? essa seria a respota??
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      // Geralmente quando é JSON o map é String e dynamic
      newTodo['title'] = _controller.text;
      _controller.text = '';
      //-> para apagar o texto da caixa de testo
      newTodo['ok'] = false;
      _toDoList.add(newTodo);
      // -> _toDolis está se tornando uma lista de mapas
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b) {
        //-> 'a' e 'b' são os mapas passados para comparação
        // -> 1 se "a < b" , 0 se "a = b", -1 se "a < b"| Afunção ler o numero 1,-1 ou 0 e ordena.
        if (a['ok'] && !b['ok']) {
          return 1;
        } else if (!a['ok'] && b['ok']) {
          return -1;
        } else {
          return 0;
        }
      });
      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('lista de Tarefas'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  // -> Tem que definir o tamanho de um dos elementos dessta Row
                  // -> Expanded define o tamnha como 'O máximo que puder na tela'
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nova tarefa',
                        labelStyle: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                      controller: _controller,
                      validator: (value) {
                        if (_controller.text.isEmpty) {
                          return 'Digite alguma tarefa';
                        }
                      },
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text('ADD'),
                  textColor: Colors.white,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        _addToDo();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              //-> widget que ao arastar para baixo executa o onRefash, e este inicia o método que vc passou
              onRefresh: _refresh,
              child: ListView.builder(
                //-> Vai ser renderizado apenas o que estiver na tela, ao rolar o scroll renderisa por demanda.
                //-> Atualisa sempre que adicionado ou removido intem na lista.
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                //-> Tem que especificar a quantidade de intens que terá na lista
                itemBuilder: _buildItem,
                //* -> O '_bildItem' tem que ter os mesmo tipos de parametros obrigatótios do 'itemBilder' para que este possa passar os valoes do parametro.
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<File> _getFile() async {
    final directory =
        await getApplicationSupportDirectory(); //-> Directory: '/data/user/0/com.example.lista_de_tarefas/files'
    // -> Pega o diretório onde pode armazenar os documentos do app.
    print(directory);
    return File('${directory.path}/data.json');
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    //-> Transformando o _toDoList (Tipo List) em Json.
    final file = await _getFile();
    // -> Espera o araquvo chegar para atribuir à variavel file.
    return file.writeAsString(data);
    // -> Escreve os dados no arquivo como texto e retorna o mesmo. Obs: Os dados em texto estão convertidos em formato JSON!
  }

  Future<String> _readData() async {
    try {
      final file =
          await _getFile(); //-> File: '/data/user/0/com.example.lista_de_tarefas/files/data.json'

      return file.readAsString();
      // -> Ler os dados e retona o arquivo em string futura.
      // Obs: Como pode ocorrer erro na leitura a atribuição da variavel _toDolist ocorre fora dessa função.
    } catch (e) {
      return null;
    }
  }

  Widget _buildItem(context, index) {
    // 'index' ->  O elemento (Ex: nome, numero...)que lisata que esta sendo desenhado no momento.
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      //-> Cada desmissible tem que ter uma chave. Essa é maneira é uma solução rápida para isso.
      background: Container(
        //-> Esse é o background da parte que está por trás do elemento com esse efeito de dismissible.
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        //-> É o filho que fica por cima do Dismissible.
        title: Text(_toDoList[index]['title']),
        //-> atribuindo o elemento da lista ao titulo da lista.
        value: _toDoList[index]['ok'],
        secondary: CircleAvatar(
          child: Icon(
            _toDoList[index]['ok'] ? Icons.check : Icons.error,
          ),
        ),
        onChanged: (c) {
          // -> É chamado quando clica no chackbox e execulta essa função com o parametro 'c' que é obrigatoriamente boolena, pois é o valor da caixinha de de marcação.
          setState(() {
            _toDoList[index]['ok'] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text('Tarefa \"${_lastRemoved["title"]}\" removida'),
            action: SnackBarAction(
                label: 'Desfazer',
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).showSnackBar(snack);
          //-> Comadno para a Snackbar aparecer na tela.
        });
      },
    );
  }
}
