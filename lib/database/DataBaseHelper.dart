import 'dart:async';
import 'dart:io';

import 'package:agenda/database/DataTables.dart';
import 'package:agenda/database/DataTablesColumn.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:agenda/Config.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;
  DatabaseHelper.createInstance();

  List<DataTablesModel> listTabelas = new List<DataTablesModel>();
  List<String> listTabelasExist = new List<String>();
  List<DataTablesModel> listTabelasExistCol = new List<DataTablesModel>();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper.createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();

    String path = directory.path + Config().nomeBanco;
    //para funcionar ios dipositivo fisico descomentar essa linha, e comentar a lisnha de cima
    //String path = p.join(directory.toString(),Config().nomeBanco);

    var clienteDatabase = await openDatabase(path, version: 1, onCreate: _createDb, onUpgrade: _onUpgrade);
    return clienteDatabase;
  }

  Future _configTabelas() async {
    listTabelas.clear();

    String sqlContato = "CREATE TABLE contato "
        "("
        " id INTEGER PRIMARY KEY AUTOINCREMENT, "
        " nome TEXT,"
        " fone TEXT,"
        " data_cadastro DATE,"
        " email TEXT "
        ")";

    //Código para futuras atualização no banco, com app ja em produção
    DataTablesModel tb = new DataTablesModel();
    tb.nome = "contato";
    tb.sql = sqlContato;
    List<String> cols = new List<String>();
    //Exemplo
    //cols.add("nome_coluna|Tipo")
    for (var item in cols) {
      DataTablesColumnModel tdCol = new DataTablesColumnModel();
      var sqlCol = "ALTER TABLE " + tb.nome + " ADD COLUMN " + item.split("|")[0] + " " + item.split("|")[1] + ";";

      tdCol.nome = item.split("|")[0];
      tdCol.sql = sqlCol;

      tb.cols.add(tdCol);
    }

    listTabelas.add(tb);

    /* */

     String sqlEnderecos = "CREATE TABLE enderecos "
        "("
        " id INTEGER PRIMARY KEY AUTOINCREMENT, "
         " contato_id INTEGER ,"
        " logradouro TEXT,"
        " numero TEXT,"
        " complemento TEXT,"
        " bairro TEXT,"
        " cidade TEXT,"
        " uf TEXT,"
        " cep TEXT "
        
        ")";

    //Código para futuras atualização no banco, com app ja em produção
    tb = new DataTablesModel();
    tb.nome = "enderecos";
    tb.sql = sqlEnderecos;
    cols = new List<String>();

    for (var item in cols) {
      DataTablesColumnModel tdCol = new DataTablesColumnModel();
      var sqlCol = "ALTER TABLE " + tb.nome + " ADD COLUMN " + item.split("|")[0] + " " + item.split("|")[1] + ";";

      tdCol.nome = item.split("|")[0];
      tdCol.sql = sqlCol;

      tb.cols.add(tdCol);
    }

    listTabelas.add(tb);

    /* */


  }

  void _createDb(Database db, int newVersion) async {
    await _configTabelas();

    for (DataTablesModel item in listTabelas) {
      try {
        await db.execute(item.sql);
      } catch (e) {}
    }

    await listarTab(db);
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _configTabelas();
    await listarTab(db);

    for (DataTablesModel item in listTabelas) {
      if (!listTabelasExist.contains(item.nome)) {
        try {
          await db.execute(item.sql);
        } catch (e) {}
      } else {
        DataTablesModel obCol = listTabelasExistCol.singleWhere((element) => element.nome == item.nome);

        List<String> listCols = new List<String>();
        for (var item in obCol.cols) {
          listCols.add(item.nome);
        }

       
        for (var col in item.cols) {
          if (!listCols.contains(col.nome)) {
            try {
              await db.execute(col.sql);
            } catch (e) {}
          }
        }
      }
    }
  }

  Future listarTab(Database db) async {
    listTabelasExist.clear();
    listTabelasExistCol.clear();

    List map = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    for (var item in map) {
      listTabelasExist.add(item["name"].toString());
      await listarCol(db, item["name"].toString());
    }
  }

  Future listarCol(Database db, String tabname) async {
    try {
      var _tabname = tabname;
      List map = await db.rawQuery("SELECT name FROM PRAGMA_TABLE_INFO('" + _tabname + "')");

      DataTablesModel dt = new DataTablesModel();
      dt.nome = tabname;
      for (var item in map) {
        DataTablesColumnModel col = new DataTablesColumnModel();
        col.nome = item["name"].toString();
        dt.cols.add(col);
      }

      listTabelasExistCol.add(dt);
    } catch (e) {}
  }
}
