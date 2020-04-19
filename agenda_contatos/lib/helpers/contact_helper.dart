import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/*  
É precisso fazer strigns com os nomes das colunas da tabela do banco de dados
para que evite erros na hora de digitar e o VsCode não deixe digitar errado. 
*/

// dica: Shift+Alt+A  -> /* */

final String contactTable = 'contactTable';
String idColumn = 'idColumn';
String nameColumn = 'nameColumn';
String emailColumn = 'emailColumn';
String phoneColumn = 'phoneColumn';
String imgComlumn = 'imgcolumn';

class ContactHelper {
  ContactHelper.internal();
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;

  Database _db;
  Future<Database> get db async {
    //-> 'get' é pra evitar ter que usar '()' na hora que precisar chamar o objeto.
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final dataBasePath = await getDatabasesPath();
    //-> Endereço onde onde está o banco de dados.
    final path = join(dataBasePath, "contacts.db");
    //-> o join ta juntando o endereço do banco de dados e com o nome que será o bd da aplicação
    //-> Obs: Se tiver um  arquivo db com o msm nome no projeto, pode dá errado.
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          'CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY,$nameColumn TEXT,$emailColumn TEXT,$phoneColumn TEXT,$imgComlumn TEXT)');
    });
  }

  //Obs: Para o await funcionar precisa colocar o async dps dome e dos parenteses da função.

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    //-> O 'insert' retorna o id(Primary Key) do objeto inserido na tabela
    return contact;
  }

  Future<int> deliteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
    //-> O 'delite' retorna um inteiro para dizer se a operção ocorreu ou não.
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: '$idColumn = ?', whereArgs: [contact.id]);
    //-> O 'update' retorna um inteiro para dizer se a operção ocorreu ou não.
  }

  Future<List> getAllcontacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery('SELECT * FROM $contactTable');
    //?-> o 'rawQuery' retorana uma lista de mapas.
    List<Contact> listContact = List();

    for (Map m in listMap) {
      //-> m é o mapa precorrido nos indices da ListMap
      listContact.add(Contact.fromMap(m));
      //-> adicionando a lista de contatos ao mesmo tempo que transforma em contato.
    }
    return await listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery('SELECT COUNT(*) FROM $contactTable'));
    // -> O 'rawQuery' tráz os resultados de uma Query em formato de uma lita de mapas.
    //-> O 'firstIntValue' tranforma o primeiro mapa  em um inteiro e retornar.
  }

  Future close() async {
    //future vasio para dizer que mesmo assim vai 'demorar' a fechar o banco
    Database dbContact = await db;
    dbContact.close();
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [nameColumn, emailColumn, phoneColumn, imgComlumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    // 'id' é colocado na primeiro ? que tiver na query, como so tem uma então é atribuida somente a essa.
    if (maps.length > 0) {
      //  se alista tiver mais de um elemento.
      return Contact.fromMap(maps.first);
      //'maps.first' é o primeiro mapa. Obs: Só  retorna um mapa mesmo.
      // Caso a carey retornasse outros mapas seria possivel escolher.
    } else {
      return null;
    }
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgComlumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgComlumn: img,
    };
    if (id != null) {
      map[idColumn] = id;
      // map = {idColumn: id};
    }
    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)';
  }
  //-> O toString sobre escrito é para quando qundo form chamado um objeto do tipo Contact em um print ele ser printado dessa
}
