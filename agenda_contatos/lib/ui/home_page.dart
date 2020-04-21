import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> listContacts = List();
  /* -> A forma de pegar uma lista futura e atribulia a uma variavel para defini
  r o seu tipo é usando o 'then'. */
  @override
  void initState() {
    super.initState();
    _getAllContact();
  }

  _getAllContact() {
    helper.getAllcontacts().then((list) {
      setState(() {
        //-> 'SetState' atualiza na tela do app.
        listContacts = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: listContacts.length,
        itemBuilder: (contex, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: listContacts[index].img != null
                        ? FileImage(File(listContacts[index].img))
                        : AssetImage('images/person.png'),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      listContacts[index].name ?? ' Sem nome',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      listContacts[index].email ?? ' Sem email',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      listContacts[index].phone ?? ' Sem phone',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showContactPage(contact: listContacts[index]);
      },
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContactPage(
          contato: contact,
        ),
      ),
    );
    //? Espera retornar um contato.
    if (recContact != null) {
      //-> Se for 'true' então , ou salva ou atualiza o contato.
      //-> se não veio contato então não faz nada.
      if (contact != null) {
        // Se eu mandei um contato, então ele veio editado.
        await helper.updateContact(recContact);
      } else {
        // Se eu não mandei um tanto, então esse que veio é novo.
        await helper.saveContact(recContact);
      }
      setState(() {
        _getAllContact();
      });
    }
  }
}
