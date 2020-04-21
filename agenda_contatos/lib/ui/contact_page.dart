import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.contato == null) {
      //-> Atravez do 'widget' pode-se acessar 'ContactPage'
      _editedContect = Contact();
    } else {
      //*_editedContect = Contact.fromMap(widget.contato.toMap()); -> Duplica o contato, pois era retornado um novo contato e não o própio contato.
      _editedContect = widget.contato;
      _nameController.text = _editedContect.name;
      _emailController.text = _editedContect.email;
      _phoneController.text = _editedContect.phone;
      //-> A atribução ao controler só sofuncioa dentro de um State.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ),
            TextFormField(
              /* O 'controller:' server capturar o que esta no 
                campo digitado pelo usuário e para colocar da-
                dos nos campos. */
              controller: _nameController,
              focusNode: _nameFocus,
              onChanged: (text) {
                setState(() {
                  print(text);
                  nomeTitle = text;
                  _editedContect.name = text;
                });
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
                setState(() {
                  print(text);
                  _editedContect.email = text;
                });
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
                setState(() {
                  print(text);
                  _editedContect.phone = text;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
