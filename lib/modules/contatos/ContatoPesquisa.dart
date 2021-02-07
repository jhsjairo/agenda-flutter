import 'package:flutter/material.dart';

class ContatoPesquisa extends StatefulWidget {
  @override
  _ContatoPesquisaState createState() => _ContatoPesquisaState();
}

class _ContatoPesquisaState extends State<ContatoPesquisa> {
  TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();

    _descricaoController = TextEditingController();
  }

  void _filtrar(BuildContext context) {
    String sql = "WHERE contato.id > 0 ";
    sql += _descricaoController.text != null
        ? " AND ( contato.id like '%" +
            _descricaoController.text +
            "%' OR " +
            " nome like '%" +
            _descricaoController.text +
            "%' ) "
        : "";

    Navigator.pop(context, sql);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pesquisar Clientes',
        ),
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 16),
              child: Container(
                // height: 70,
                child: TextFormField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: "Digite o Nome ou Código",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton.icon(
                  onPressed: () {
                    _filtrar(context);
                  },
                  elevation: 2.0,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                  color: Colors.blue,
                  icon: Icon(
                    Icons.search,
                    color: Colors.blue,
                  ),
                  label: Text(
                    "Buscar",
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
