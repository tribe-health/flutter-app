import 'package:flutter_app/db/mixin_database.dart';
import 'package:moor/moor.dart';

part 'apps_dao.g.dart';

@UseDao(tables: [Apps])
class AppsDao extends DatabaseAccessor<MixinDatabase> with _$AppsDaoMixin {
  AppsDao(MixinDatabase db) : super(db);

  Future<int> insert(App app) => into(db.apps).insert(app);

  Future deleteApp(App app) => delete(db.apps).delete(app);
}