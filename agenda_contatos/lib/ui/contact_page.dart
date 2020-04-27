import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  //?-> Essa 'camada' fica 'exposta' para que possa receber ou entrgar informações.
  final Contact contato;
  ContactPage({this.contato});
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  Contact _editedContect;
  String nomeTitle = "Sem nome";
  ContactHelper helper = ContactHelper();
  bool _userEdited = false;

  @override
  void initState() {
    super.initState();
    if (widget.contato == null) {
      //-> Atravez do 'widget' pode-se acessar 'ContactPage'
      _editedContect = Contact();
    } else {
      _editedContect = Contact.fromMap(widget.contato.toMap());
      //-> Duplica o contato, pois será retornado um novo contato e não o própio contato em si(instância original).
      //? duoplicando a instância do contato, ao retornar para paǵina de início, os valores instanciados não resram mostrados pois quem foi setado foi o contato duplicado.
      // _editedContect = widget.contato; // Contato único para fazer o teste do estádo.
      _nameController.text = _editedContect.name;
      _emailController.text = _editedContect.email;
      _phoneController.text = _editedContect.phone;
      //-> A atribução ao controler só sofuncioa dentro de um State.
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // -> 'WillPopScope' chama uma função quando a appBar apresenta 'pop' altomático.
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContect.name ?? nomeTitle),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
          onPressed: () {
            if (_editedContect.name != null && _editedContect.name.isNotEmpty) {
              Navigator.pop(context, _editedContect);
              //O segundo paremetro do pop() permite enviar para a pagina anterior um objeto.
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              GestureDetector(
                //? Quando coloca o TextFormField, estica a "caixa da coluna" e os itens se alinham.
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContect.img != null
                          ? FileImage(File(_editedContect.img))
                          : AssetImage('images/person.png'),
                    ),
                  ),
                ),
                onTap: () {
                  ImagePicker.pickImage(source: ImageSource.camera)
                      .then((file) {
                    if (file == null) return;
                    setState(() {
                      _editedContect.img = file.path;
                    });
                  });
                },
              ),
              TextFormField(
                /* O 'controller:' server capturar o que esta no 
                  campo digitado pelo usuário e para colocar da-
                  dos nos campos. */
                controller: _nameController,
                focusNode: _nameFocus,
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    nomeTitle = text;
                  }); //-> para atualizar toda vez que digitado uma letra

                  _editedContect.name = text;
                },
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
                maxLines: 1,
                keyboardType: TextInputType.text,
                autofocus: false,
                decoration: new InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Ex: Ana Lívia',
                  labelStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              TextFormField(
                controller: _emailController,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                decoration: new InputDecoration(
                  labelText: 'Email',
                  hintText: 'nome@agenda.com',
                  labelStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContect.email = text;
                },
              ),
              TextFormField(
                controller: _phoneController,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
                maxLines: 1,
                keyboardType: TextInputType.phone,
                autofocus: false,
                decoration: new InputDecoration(
                  labelText: 'Telefone',
                  hintText: '(00) 000-000-000',
                  labelStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContect.phone = text;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('Descartar Alterações?'),
                content: Text('Se sair as alterações seram perdias.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      Navigator.pop(context); // Saida manual
                    },
                  ),
                  FlatButton(
                    child: Text('Sim'),
                    onPressed: () {
                      Navigator.pop(context); // Saida manual
                      Navigator.pop(context); // Saida manual
                      //Para poder voltar duas telas
                    },
                  ),
                ]);
          });

      return Future.value(false); // Para não sair altomaticamente da tela
    } else {
      return Future.value(true); // Para sair altomaticamente da tela
    }
  }
}
