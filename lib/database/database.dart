import 'package:contatos_flutter/database/model/contacts.dart';
import 'package:moor/moor.dart';

part 'database.g.dart';

@UseMoor(tables: [Contacts])
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
