import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'package:agenda/database/DataBaseHelper.dart';


import 'Enderecos.dart';

class EnderecosRepositorio {
  var dbHelper = DatabaseHelper();

  String tabela = 'enderecos';

  int ret = 0;

  Future<int> inserir(EnderecosModel ob) async {
    Database db = await dbHelper.initializeDatabase();

    var map = <String, dynamic>{
      'id': ob.id,
      'contato_id': ob.contatoId,
      'logradouro': ob.logradouro,
      'numero': ob.numero,
      'complemento': ob.complemento,
      'bairro': ob.bairro,
      'cidade': ob.cidade,
      'uf': ob.uf,
      'cep': ob.cep,
    };

    if (ob.id == null || ob.id == 0) {
      ret = await db.insert(tabela, map);
    } else {
      ret = await db.update(tabela, map, where: "id = ?", whereArgs: [ob.id]);
      ret = ob.id;
    }

    //db.close();

    return ret;
  }

  Future listar( {String filtro: "", String order: ""}) async {
    try {
      Database db = await dbHelper.initializeDatabase();
      String sql = "SELECT * FROM " + tabela + " " + filtro + " " + order;

      List map = await db.rawQuery(sql);

      //db.close();

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
