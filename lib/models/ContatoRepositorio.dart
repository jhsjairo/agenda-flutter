import 'dart:async';


import 'package:agenda/models/Contato.dart';
import 'package:sqflite/sqflite.dart';

import 'package:agenda/database/DataBaseHelper.dart';


class ContatoRepositorio {
  var dbHelper = DatabaseHelper();

  String tabela = 'contato';

  int ret = 0;

  Future<int> inserir(ContatoModel ob) async {
    Database db = await dbHelper.initializeDatabase();

    var map = <String, dynamic>{
      'id': ob.id,
      'nome': ob.nome,
      'fone': ob.fone,
      'email': ob.email,
      'data_cadastro': ob.dataCadastro,
    };

    if (ob.id == null || ob.id == 0) {
      ret = await db.insert(tabela, map);
    } else {
      await db.update(tabela, map, where: "id = ?", whereArgs: [ob.id]);
      ret = ob.id;
    }

    return ret;
  }

  Future listar( {String filtro: "", String order: ""}) async {
    try {
      Database db = await dbHelper.initializeDatabase();
      String sql = "SELECT * FROM " + tabela + " " + filtro + " " + order;

      List map = await db.rawQuery(sql);

      return map;
    } catch (e) {}
  }

  Future<int> excluir(int id) async {
    var db = await dbHelper.initializeDatabase();

    var resultado = await db.delete(tabela, where: "id = ?", whereArgs: [id]);
    //db.close();
    return resultado;
  }

    

}
