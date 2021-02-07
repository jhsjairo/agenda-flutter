import 'package:flutter/material.dart';

enum ListTileOrdenar { codigo, nome }

class ContatoOrdenar extends StatefulWidget {
  @override
  _ContatoOrdenarState createState() => _ContatoOrdenarState();
}

class _ContatoOrdenarState extends State<ContatoOrdenar> {
  ListTileOrdenar _character = ListTileOrdenar.codigo;

  void _ordernar(BuildContext context) {
    String sql = "";
    switch (_character) {
      case ListTileOrdenar.codigo:
        sql = " ORDER BY id ASC";
        break;

      case ListTileOrdenar.nome:
        sql = " ORDER BY UPPER(nome) ASC";
        break;

      default:
        sql = " ORDER BY UPPER(nome) ASC";
    }
    Navigator.pop(context, sql);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // iconTheme: IconThemeData(color: widget.config.corTextoAppBar),
        title: Text(
          'Ordenar Contatos',
          style: TextStyle(color: Colors.white),
        ),
        // backgroundColor: widget.config.corAppBar,
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: const Text('Codigo'),
              leading: Radio(
                activeColor: Colors.grey,
                value: ListTileOrdenar.codigo,
                groupValue: _character,
                onChanged: (ListTileOrdenar value) {
                  setState(() {
                    _character = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Nome'),
              leading: Radio(
                activeColor: Colors.grey,
                value: ListTileOrdenar.nome,
                groupValue: _character,
                onChanged: (ListTileOrdenar value) {
                  setState(() {
                    _character = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: RaisedButton.icon(
                  onPressed: () {
                    _ordernar(context);
                  },
                  elevation: 2.0,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                  color: Colors.blue,
                  icon: Icon(
                    Icons.filter_list,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Ordenar",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
