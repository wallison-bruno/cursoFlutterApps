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
  Contact _editedContect;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.contato == null) {
      //?-> Atravez do 'widget' pode-se acessar 'ContactPage'
      _editedContect = Contact();
    } else {
      //_editedContect = Contact.fromMap(widget.contato.toMap());
      //?-> Duplica o contato, pois era retornado um novo contato e não o própio contato
      _editedContect = widget.contato;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(_editedContect.name ?? 'Sem nome'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        backgroundColor: Colors.red,
        onPressed: () {},
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            GestureDetector(), //!Parei aqui!!!
          ],
        ),
      ),
    );
  }
}
