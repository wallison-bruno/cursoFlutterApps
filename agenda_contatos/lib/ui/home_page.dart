import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza } //* -> Contantes

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
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordernar de A-Z'),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordernar de Z-A'),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
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
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            //Funsao que é executada quando o BottomSheet fecha
            builder: (context) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  //-> Ocupar o mínimo de espaço porssível no eixo principal da coluna
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          'Ligar',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        onPressed: () {
                          launch('tel:${listContacts[index].phone}');
                          //-> Uma url com comandos predeterminados para serem utilizados.
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          'Editar',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.pop(context); //-> sai do 'BottomSheet'
                          _showContactPage(contact: listContacts[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        onPressed: () {
                          helper.deliteContact(listContacts[index].id);
                          //-> remove primeiro do banco d.
                          setState(() {
                            listContacts.removeAt(index);
                            //-> depois remove da lista setada para mostrar os contatos.
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
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

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        listContacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        listContacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
