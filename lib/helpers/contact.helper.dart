import 'package:moor/moor.dart';

import '../database/platforms/shared.dart' as SharedDb;
import '../database/database.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    return SharedDb.constructDb();
  }

  Future<Contact> saveContact(ContactsCompanion contact) async {
    Database dbContact = await db;

    int rowId = await dbContact.into(dbContact.contacts).insert(contact);
    return Contact(
        id: rowId,
        name: contact.name.value,
        email: contact.email.value,
        phone: contact.phone.value,
        img: contact.img.value);
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    Contact contact = await (dbContact.select(dbContact.contacts)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();
    return contact;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await (dbContact.delete(dbContact.contacts)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<int> upadateContact(ContactsCompanion contact) async {
    Database dbContact = await db;
    return await (dbContact.update(dbContact.contacts)
          ..where((tbl) => tbl.id.equals(contact.id.value)))
        .write(contact);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;

    List<Contact> listMaps = await dbContact.select(dbContact.contacts).get();

    return listMaps;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    var counterExpresssion = dbContact.contacts.id.count();
    final query = dbContact.selectOnly(dbContact.contacts)
      ..addColumns([counterExpresssion]);
    return await query.map((row) => row.read(counterExpresssion)).getSingle();
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}
