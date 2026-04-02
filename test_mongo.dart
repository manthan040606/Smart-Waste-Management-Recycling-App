import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  print('Starting connection test...');
  const uri = "mongodb+srv://verified3737_db_user:manthan%401543@23it007.khzjsrh.mongodb.net/smart_waste?appName=23IT007";
  Db? db;
  try {
    db = await Db.create(uri);
    await db.open();
    print('Connected successfully to MongoDB!');
    
    final collection = db.collection('waste_logs');
    await collection.insert({'id': 'test_id', 'message': 'System verification connection'});
    print('Successfully created the database and inserted a test document into waste_logs!');
    
    await db.close();
  } catch (e) {
    print('Error connecting or inserting: $e');
  }
}
